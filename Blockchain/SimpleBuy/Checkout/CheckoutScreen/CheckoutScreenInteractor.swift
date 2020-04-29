//
//  CheckoutScreenInteractor.swift
//  Blockchain
//
//  Created by AlexM on 1/23/20.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift
import PlatformKit

final class CheckoutScreenInteractor {
    
    // MARK: - Types
    
    enum InteractionError: Error {
        case missingOrder
        case missingInternalOrderData
        case impossibleState
    }
    
    struct InteractionData {
        let time: Date
        let fee: FiatValue
        let amount: CryptoValue
        let exchangeRate: FiatValue
        let card: CardData?
        let orderId: String
    }
    
    // MARK: - Properties
    
    var isCancellable: Bool {
        !checkoutData.hasCheckoutMade
    }
    
    private(set) var checkoutData: SimpleBuyCheckoutData
        
    // MARK: - Services
    
    private let cardListService: CardListServiceAPI
    private let creationService: SimpleBuyPendingOrderCreationServiceAPI
    private let cancellationService: SimpleBuyOrderCancellationServiceAPI
    private let confirmationService: SimpleBuyOrderConfirmationServiceAPI

    // MARK: - Setup
    
    init(cardListService: CardListServiceAPI,
         creationService: SimpleBuyPendingOrderCreationServiceAPI,
         confirmationService: SimpleBuyOrderConfirmationServiceAPI,
         cancellationService: SimpleBuyOrderCancellationServiceAPI,
         checkoutData: SimpleBuyCheckoutData) {
        self.cardListService = cardListService
        self.creationService = creationService
        self.confirmationService = confirmationService
        self.cancellationService = cancellationService
        self.checkoutData = checkoutData
    }
    
    /// Performs a setup of the data
    func setup() -> Single<InteractionData> {
        guard let order = checkoutData.detailType.order else {
            return recreateOrder()
        }
        
        /// Pending 3DS on card for this order
        if order.isPendingConfirmation {
            return recreateOrder()
        } else if order.is3DSConfirmedCardOrder || order.isPending3DSCardOrder {
            /// 3DS was confirmed on this order - just fetch the details
            guard let fee = order.fee else { return .error(InteractionError.missingInternalOrderData ) }
            guard let price = order.price else { return .error(InteractionError.missingInternalOrderData ) }
            
            return cardListService
                .card(by: order.paymentMethodId ?? "")
                .map { card in
                    InteractionData(
                        time: order.creationDate,
                        fee: fee,
                        amount: order.cryptoValue,
                        exchangeRate: price,
                        card: card,
                        orderId: order.identifier
                    )
                }            
        } else {
            return .error(InteractionError.impossibleState)
        }
    }
    
    /// Confirms the order if needed and then continue
    func `continue`() -> Observable<SimpleBuyCheckoutData> {
        guard let order = checkoutData.detailType.order else {
            return .error(InteractionError.missingOrder)
        }
        
        if order.isPendingConfirmation {
            return confirmationService
                .confirm(checkoutData: checkoutData)
                .flatMap(weak: self) { (self, data) -> Single<SimpleBuyCheckoutData> in
                    self.set(data: data)
                }
                .asObservable()
        } else {
            return .just(checkoutData)
        }
    }
    
    /// Cancels the order if possible
    func cancelIfPossible() -> Single<Bool> {
        guard let order = checkoutData.detailType.order else {
            return .error(InteractionError.missingOrder)
        }
        if order.isPendingConfirmation {
            return cancellationService
                .cancel(order: order.identifier)
                .andThen(.just(true))
        } else {
            return .just(false)
        }
    }
    
    private func recreateOrder() -> Single<InteractionData> {
        creationService
            .create(using: checkoutData)
            .flatMap(weak: self) { (self, data) in
                self.set(data: data.checkoutData)
                    .map { checkoutData in
                        (quote: data.quote, order: checkoutData.detailType.order!)
                    }
            }
            .flatMap(weak: self) { (self, data) in
                self.cardListService
                    .card(by: data.order.paymentMethodId ?? "")
                    .map { card in
                        InteractionData(
                            time: data.quote.time,
                            fee: data.quote.fee,
                            amount: data.quote.estimatedAmount,
                            exchangeRate: data.quote.rate,
                            card: card,
                            orderId: data.order.identifier
                        )
                    }
            }
    }

    private func set(data: SimpleBuyCheckoutData) -> Single<SimpleBuyCheckoutData> {
        Single
            .create(weak: self) { (self, observer) -> Disposable in
                self.checkoutData = data
                observer(.success(data))
                return Disposables.create()
            }
    }
}
