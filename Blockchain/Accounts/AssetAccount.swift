//
//  AssetAccount.swift
//  Blockchain
//
//  Created by Chris Arriola on 9/13/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import PlatformKit

/// Describes a Blockchain account for a specific `AssetType`
struct AssetAccount {

    /// The index of this account in the wallet metadata (always 0 for ether)
    let index: Int32

    /// The AssetAddress for this account
    let address: AssetAddress

    /// The balance in this account
    let balance: CryptoValue

    /// The name of this account
    let name: String
}

extension AssetAccount: Equatable {
    static func == (lhs: AssetAccount, rhs: AssetAccount) -> Bool {
        lhs.index == rhs.index &&
        lhs.address.publicKey == rhs.address.publicKey &&
        lhs.balance == rhs.balance &&
        lhs.name == rhs.name
    }
}
