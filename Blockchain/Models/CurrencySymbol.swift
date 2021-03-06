//
//  CurrencySymbol.swift
//  Blockchain
//
//  Created by Paulo on 14/09/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import UIKit
import PlatformKit
import ToolKit

class CurrencySymbol: NSObject {
    @objc let conversion: Double
    @objc let code: String
    @objc let symbol: String
    let name: String

    init?(dict: [AnyHashable: Any]) {
        guard let code = dict["code"] as? String else {
            return nil
        }
        guard let fiatCurrency = FiatCurrency(code: code) else {
            return nil
        }
        guard let symbol = dict["symbol"] as? String else {
            return nil
        }
        guard let last: Double = dict["last"] as? Double, last > 0 else {
            return nil
        }
        let satoshi: NSDecimalNumber = NSDecimalNumber(value: Constants.Conversions.satoshi)
        let lastDecimal: NSDecimalNumber = NSDecimalNumber(value: last)
        let conversion = satoshi.dividing(by: lastDecimal)
        self.conversion = conversion.doubleValue
        self.code = code
        self.symbol = symbol
        self.name = fiatCurrency.name
        super.init()
    }

    /// Supported FiatCurrency map of 'currency code' : 'currency localised name'
    @objc static let currencyNames: [String: String] = {
        FiatCurrency.supported.reduce(into: [String: String]()) { (result, fiat) in
            result[fiat.code] = fiat.name
        }
    }()
}
