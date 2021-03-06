//
//  CheckoutPageInteractor.swift
//  BuySellUIKit
//
//  Created by Dimitrios Chatzieleftheriou on 29/10/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import BuySellKit
import DIKit
import PlatformKit
import RIBs
import RxCocoa
import RxSwift

protocol CheckoutPageRouting: AnyObject {
    func route(to type: CheckoutRoute)
}

protocol CheckoutPageListener: AnyObject {
    func closeFlow()
    func checkoutDidTapBack()
}

protocol CheckoutPagePresentable: Presentable {
    var continueButtonTapped: Signal<Void> { get }
    func connect(action: Driver<CheckoutPageInteractor.Action>) -> Driver<CheckoutPageInteractor.Effects>
}

final class CheckoutPageInteractor: PresentableInteractor<CheckoutPagePresentable>,
                                    CheckoutPageInteractable {
    weak var router: CheckoutPageRouting?
    weak var listener: CheckoutPageListener?

    private let checkoutData: WithdrawalCheckoutData
    private let withdrawalService: WithdrawalServiceAPI

    init(presenter: CheckoutPagePresentable,
         checkoutData: WithdrawalCheckoutData,
         withdrawalService: WithdrawalServiceAPI = resolve()) {
        self.checkoutData = checkoutData
        self.withdrawalService = withdrawalService
        super.init(presenter: presenter)
    }

    override func didBecomeActive() {
        super.didBecomeActive()

        let checkoutDataAction = Driver.deferred { [weak self] () -> Driver<Action> in
            guard let self = self else { return .empty() }
            return .just(.load(self.checkoutData))
        }

        presenter.continueButtonTapped
            .asObservable()
            .flatMapLatest(weak: self) { (self, _) -> Observable<Result<FiatValue, Error>> in
                self.withdrawalService.withdrawal(for: self.checkoutData)
                    .asObservable()
                    .observeOn(MainScheduler.asyncInstance)
                    .do(onSubscribe: {
                        self.router?.route(to: .loading(amount: self.checkoutData.amount))
                    })
            }
            .subscribe(onNext: { result in
                switch result {
                case .success(let amount):
                    self.router?.route(to: .confirmation(amount: amount))
                case .failure:
                    self.router?.route(to: .failure(self.checkoutData.currency.currency))
                }
            })
            .disposeOnDeactivate(interactor: self)

        presenter.connect(action: checkoutDataAction)
            .drive(onNext: handle(effect:))
            .disposeOnDeactivate(interactor: self)
    }

    func handle(effect: Effects) {
        switch effect {
        case .close:
            listener?.closeFlow()
        case .back:
            listener?.checkoutDidTapBack()
        }
    }

    func confirmationRequested(to route: WithdrawalConfirmationRoute) {
        switch route {
        case .closeFlow:
            handle(effect: .close)
        }
    }
}

extension CheckoutPageInteractor {
    enum Action: Equatable {
        case load(WithdrawalCheckoutData)
        case empty
    }

    enum Effects: Equatable {
        case close
        case back
    }
}
