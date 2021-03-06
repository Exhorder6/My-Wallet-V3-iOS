//
//  LocalizationConstants+Receive.swift
//  Localization
//
//  Created by Paulo on 25/08/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

extension LocalizationConstants {
    public enum Receive {
        public enum Header { }
        public enum Text { }
        public enum Button { }
    }
}

extension LocalizationConstants.Receive.Header {

    public static let receiveCryptoNow = NSLocalizedString(
        "Receive Crypto Now",
        comment: "Section header where wallet address is displayed."
    )

    public static let chooseAWalletToReceiveTo = NSLocalizedString(
        "Choose a Wallet to receive crypto to.",
        comment: "Choose a Wallet to receive crypto to."
    )
}

extension LocalizationConstants.Receive.Text {

    public static let request = NSLocalizedString(
        "Request",
        comment: "Screen title."
    )

    public static let receive = NSLocalizedString(
        "Receive",
        comment: "Screen title."
    )

    public static let walletAddress = NSLocalizedString(
        "Wallet Address",
        comment: "Section header where wallet address is displayed."
    )

    public static let copiedToClipboard = NSLocalizedString(
        "Copied to clipboard",
        comment: "Text displayed when a crypto address has been copied to the users clipboard."
    )

    public static let pleaseSendXTo = NSLocalizedString(
        "Please send %@ to",
        comment: "Message when requesting payment to a given asset."
    )

    public static let xPaymentRequest = NSLocalizedString(
        "%@ payment request.",
        comment: "Subject when requesting payment for a given asset."
    )
}

extension LocalizationConstants.Receive.Button {
    public static let copy = NSLocalizedString(
        "Copy Address",
        comment: "Button CTA to copy address to pasteboard."
    )
    public static let copied = NSLocalizedString(
        "Copied!",
        comment: "Copy address button title after copy was made"
    )
    public static let share = NSLocalizedString(
        "Share Address",
        comment: "Button CTA to share address."
    )
}
