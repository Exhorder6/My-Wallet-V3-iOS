//
//  WalletBalanceViewInteractor.swift
//  PlatformUIKit
//
//  Created by Alex McGregor on 5/14/20.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import DIKit
import PlatformKit
import RxRelay
import RxSwift

public final class WalletBalanceViewInteractor {
    
    typealias InteractionState = LoadingState<WalletBalance>
    
    public struct WalletBalance {
        
        /// The wallet's balance in fiat
        let fiatValue: FiatValue
        /// The wallet's fiat currency code
        var fiatCurrency: FiatCurrency {
            fiatValue.currencyType
        }
        
        public init(fiatValue: FiatValue) {
            self.fiatValue = fiatValue
        }
    }
    
    // MARK: - Public Properties
    
    var state: Observable<InteractionState> {
        _ = setup
        return stateRelay.asObservable()
    }
    
    // MARK: - Private Properties
    
    private let stateRelay = BehaviorRelay<InteractionState>(value: .loading)
    private let disposeBag = DisposeBag()
    private let stateObservableProvider: () -> Observable<InteractionState>
    private lazy var setup: Void = {
        stateObservableProvider()
            .bindAndCatch(to: self.stateRelay)
                .disposed(by: self.disposeBag)
    }()

    // MARK: - Setup

    public init(balanceProviding: BalanceProviding) {
        stateObservableProvider = {
            balanceProviding
                .fiatBalance
                .map { state -> InteractionState in
                    switch state {
                    case .calculating, .invalid:
                        return .loading
                    case .value(let result):
                        return .loaded(
                            next: WalletBalance(fiatValue: result)
                        )
                    }
                }
        }
    }

    public init(account: BlockchainAccount,
                fiatCurrencyService: FiatCurrencyServiceAPI = resolve()) {
        stateObservableProvider = {
            fiatCurrencyService.fiatCurrencyObservable
                .flatMap { fiatCurrency in
                    account.fiatBalance(fiatCurrency: fiatCurrency).asObservable()
                }
                .map { moneyValue -> InteractionState in
                    .loaded(next: WalletBalance(fiatValue: moneyValue.fiatValue!))
                }
                .startWith(.loading)
                .catchErrorJustReturn(.loading)
        }
    }
}
