//
//  KYCSettingsAPI.swift
//  KYCKit
//
//  Created by Paulo on 05/10/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

public protocol KYCSettingsAPI: AnyObject {

    var didTapOnDocumentResubmissionDeepLink: Bool { get set }

    var documentResubmissionLinkReason: String? { get set }

    var didTapOnKycDeepLink: Bool { get set }

    var isCompletingKyc: Bool { get set }

    var latestKycPage: KYCPageType? { get set }

    func reset()
}
