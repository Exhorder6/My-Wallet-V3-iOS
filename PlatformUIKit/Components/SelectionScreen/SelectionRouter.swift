//
//  SelectionRouter.swift
//  PlatformUIKit
//
//  Created by Daniel Huri on 31/03/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

public protocol SelectionRouterAPI: class {
    func showSelectionScreen(screenTitle: String,
                             searchBarPlaceholder: String,
                             using service: SelectionServiceAPI)
}

public final class SelectionRouter: SelectionRouterAPI {
    
    // MARK: - Properties
    
    private let parent: ViewControllerAPI
    
    // MARK: - Setup
    
    public init(parent: ViewControllerAPI) {
        self.parent = parent
    }
    
    // MARK: - API
    
    public func showSelectionScreen(screenTitle: String,
                                    searchBarPlaceholder: String,
                                    using service: SelectionServiceAPI) {
        let interactor = SelectionScreenInteractor(service: service)
        let presenter = SelectionScreenPresenter(
            title: screenTitle,
            searchBarPlaceholder: searchBarPlaceholder,
            interactor: interactor
        )
        let viewController = SelectionScreenViewController(presenter: presenter)
        let navigationController = UINavigationController(rootViewController: viewController)
        parent.present(navigationController, animated: true, completion: nil)
    }
}
