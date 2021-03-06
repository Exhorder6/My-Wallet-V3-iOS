//
//  LocalizationConstants+Send.swift
//  Localization
//
//  Created by Paulo on 03/09/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

extension LocalizationConstants {
    public enum Send {
        public enum Header { }
        public enum Text { }
    }
}

extension LocalizationConstants.Send.Header {

    public static let sendCryptoNow = NSLocalizedString(
        "Send Crypto Now",
        comment: "Send Crypto Now"
    )

    public static let chooseAWalletToSendFrom = NSLocalizedString(
        "Choose a Wallet to send crypto from.",
        comment: "Choose a Wallet to send crypto from."
    )
}

extension LocalizationConstants.Send.Text {

    public static let send = NSLocalizedString(
        "Send",
        comment: "Screen title."
    )
}

extension LocalizationConstants.Send {
    public struct Source {
        public static let subject = NSLocalizedString(
            "From",
            comment: "Transfer screen: source address / account subject"
        )
    }

    public struct Destination {
        public static let subject = NSLocalizedString(
            "To",
            comment: "Transfer screen: destination address / account subject"
        )
        public static let placeholder = NSLocalizedString(
            "Enter %@ address",
            comment: "Transfer screen: destination address / account placeholder"
        )
        public static let exchangeCover = NSLocalizedString(
            "Exchange %@ Address",
            comment: "Exchange address for a wallet"
        )
    }

    public struct Fees {
        public static let subject = NSLocalizedString(
            "Fees",
            comment: "Transfer screen: fees subject"
        )
    }

    public struct SpendableBalance {
        public static let prefix = NSLocalizedString(
            "Use total spendable balance: ",
            comment: "String displayed to the user when they want to send their full balance to an address."
        )
    }

    public static let primaryButton = NSLocalizedString(
        "Continue",
        comment: "Transfer screen: primary CTA button"
    )

    public struct Error {
        public struct Balance {
            public static let title = NSLocalizedString(
                "Not Enough %@",
                comment: "Prefix for alert title when there is not enough balance"
            )
            public static let description = NSLocalizedString(
                "You will need %@ to send the transaction",
                comment: "Prefix for alert description when there is not enough balance"
            )
            public static let descriptionERC20 = NSLocalizedString(
                "You will need ETH to send your ERC20 Token",
                comment: "Prefix for alert description when there is not enough balance"
            )
        }
        public struct DestinationAddress {
            public static let title = NSLocalizedString(
                "Invalid %@ Address",
                comment: "Prefix for alert title when the destination address is invalid"
            )
            public static let description = NSLocalizedString(
                "You must enter a valid %@ address to send the transaction",
                comment: "Prefix for alert description when the destination address is invalid"
            )
            public static let descriptionERC20 = NSLocalizedString(
                "You must enter a valid %@ address to send your ERC20 Token",
                comment: "Prefix for alert description when the destination address is invalid"
            )
        }
        public struct PendingTransaction {
            public static let title = NSLocalizedString(
                "Waiting for Payment",
                comment: "Alert title when transaction cannot be sent because there is another in progress"
            )
            public static let description = NSLocalizedString(
                "Please wait until your last ETH transaction confirms",
                comment: "Alert description when transaction cannot be sent because there is another in progress"
            )
        }
    }
}
