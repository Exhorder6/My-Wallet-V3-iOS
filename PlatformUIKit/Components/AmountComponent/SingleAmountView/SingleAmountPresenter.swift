//
//  SingleAmountInteractor.swift
//  PlatformUIKit
//
//  Created by Dimitrios Chatzieleftheriou on 12/10/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import DIKit
import Localization
import PlatformKit
import RxCocoa
import RxSwift
import ToolKit

public final class SingleAmountPresenter {

    // MARK: - Types

    public enum Input {
        case input(String)
        case delete
    }

    public enum State {
        case showLimitButton(CurrencyLabeledButtonViewModel)
        case empty
    }

    private typealias LocalizedString = LocalizationConstants.SimpleBuy.BuyCryptoScreen.LimitView
    private typealias AccessibilityId = Accessibility.Identifier.Amount

    let amountPresenter: InputAmountLabelPresenter

    // MARK: - Injected
    private let interactor: SingleAmountInteractor

    // MARK: - Accessors
    private let stateRelay = BehaviorRelay<State>(value: .empty)

    private let disposeBag = DisposeBag()

    public init(interactor: SingleAmountInteractor) {
        self.interactor = interactor

        self.amountPresenter = InputAmountLabelPresenter(interactor: interactor.currencyInteractor,
                                                         currencyCodeSide: .leading)
    }

    func connect(input: Driver<SingleAmountPresenter.Input>) -> Driver<State> {
        let input = input.filter { !$0.isEmpty }
        return interactor.connect(input: input.map(\.toInteractorInput))
            .map { [weak self] state -> State in
                guard let self = self else { return .empty }
                return self.setupButton(by: state)
            }
    }

    // MARK: - Private

    private func setupButton(by state: SingleAmountInteractor.State) -> State {
        let viewModel: CurrencyLabeledButtonViewModel
        switch state {
        case .empty, .inBounds:
            return .empty
        case .maxLimitExceeded(let maxValue):
            viewModel = CurrencyLabeledButtonViewModel(
                amount: maxValue.value,
                suffix: LocalizedString.Max.useMax,
                style: .currencyOutOfBounds,
                accessibilityId: AccessibilityId.max
            )
            viewModel.elementOnTap
                .map { "\($0)" }
                .emit(onNext: { [weak self] amount in
                    guard let self = self else { return }
                    self.interactor.set(amount: amount)
                })
                .disposed(by: disposeBag)
            return .showLimitButton(viewModel)
        }
    }
}

extension SingleAmountPresenter.Input {
    internal var toInteractorInput: SingleAmountInteractor.Input {
        switch self {
        case .input(let value):
            return .insert(value)
        case .delete:
            return .remove
        }
    }

    internal var isEmpty: Bool {
        switch self {
        case .input(let value):
            return value.isEmpty
        case .delete:
            return false
        }
    }
}
