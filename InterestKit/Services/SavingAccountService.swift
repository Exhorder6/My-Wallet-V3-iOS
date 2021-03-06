//
//  InterestAccountService.swift
//  PlatformKit
//
//  Created by Daniel Huri on 18/05/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import DIKit
import PlatformKit
import RxSwift
import ToolKit

public protocol SavingAccountServiceAPI: AnyObject {
    var balances: Single<CustodialAccountBalanceStates> { get }
    func fetchBalances() -> Single<CustodialAccountBalanceStates>
    func details(for currency: CryptoCurrency) -> Single<ValueCalculationState<SavingsAccountBalanceDetails>>
    func balance(for currency: CryptoCurrency) -> Single<CustodialAccountBalanceState>
    func rate(for currency: CryptoCurrency) -> Single<Double>
    func limits(for currency: CryptoCurrency) -> Single<SavingsAccountLimits?>
}

class SavingAccountService: SavingAccountServiceAPI {
    
    // MARK: - Properties
    
    var balances: Single<CustodialAccountBalanceStates> {
        _ = setup
        return cachedValue.valueSingle
    }

    // MARK: - Private Properties
    
    private let client: SavingsAccountClientAPI
    private let fiatCurrencyService: FiatCurrencyServiceAPI
    private let custodialFeatureFetcher: CustodialFeatureFetching
    private let cachedValue: CachedValue<CustodialAccountBalanceStates>

    private lazy var setup: Void = {
        cachedValue.setFetch(weak: self) { (self) in
            self.fetchBalancesResponse()
                .map { CustodialAccountBalanceStates(response: $0) }
        }
    }()
    
    // MARK: - Setup

    init(client: SavingsAccountClientAPI = resolve(),
         fiatCurrencyService: FiatCurrencyServiceAPI = resolve(),
         custodialFeatureFetcher: CustodialFeatureFetching = resolve()) {
        self.client = client
        self.fiatCurrencyService = fiatCurrencyService
        self.custodialFeatureFetcher = custodialFeatureFetcher
        self.cachedValue = CachedValue(configuration: .onSubscription())
    }

    // MARK: - Methods
    
    func limits(for currency: CryptoCurrency) -> Single<SavingsAccountLimits?> {
        fiatCurrencyService
            .fiatCurrency
            .flatMap(weak: self) { (self, fiatCurrency) in
                self.client.limits(fiatCurrency: fiatCurrency)
            }
            .map { $0[currency] }
    }
    
    func details(for currency: CryptoCurrency) -> Single<ValueCalculationState<SavingsAccountBalanceDetails>> {
        fetchBalancesResponse()
            .map { (response) -> ValueCalculationState<SavingsAccountBalanceDetails> in
                guard let details = response[currency] else { return .invalid(.empty) }
                return .value(details)
            }
    }

    func balance(for currency: CryptoCurrency) -> Single<CustodialAccountBalanceState> {
        balances.map { $0[currency.currency] }
    }

    private func fetchBalancesResponse() -> Single<SavingsAccountBalanceResponse> {
        Single.zip(
                custodialFeatureFetcher
                    .featureEnabled(for: .interestAccountEnabled),
                fiatCurrencyService.fiatCurrency
            )
            .flatMap(weak: self) { (self, values) in
                let interestAccountEnabled = values.0
                let fiatCurrency = values.1
                guard interestAccountEnabled else {
                    return Single.just(.empty)
                }
                return self.client.balance(with: fiatCurrency).map { balance in
                    guard let balance = balance else {
                        return .empty
                    }
                    return balance
                }
            }
            .catchErrorJustReturn(.empty)
    }

    func fetchBalances() -> Single<CustodialAccountBalanceStates> {
        _ = setup
        return cachedValue.fetchValue
    }
    
    func rate(for currency: CryptoCurrency) -> Single<Double> {
        client.rate(for: currency.rawValue)
            .map { $0.rate }
    }
}
