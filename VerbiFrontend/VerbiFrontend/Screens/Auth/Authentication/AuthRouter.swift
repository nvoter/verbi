//
//  AuthRouter.swift
//  VerbiFrontend
//
//  Created by Анастасия Манушкина on 17.01.2025.
//

import UIKit

final class AuthRouter: AuthRouterInput {
    // MARK: - Properties
    weak var viewController: UIViewController?

    // MARK: - LifeCycle
    init(viewController: UIViewController) {
        self.viewController = viewController
    }

    // MARK: - AuthRouterInput
    func navigateToMainScreen() {
        let mainViewController = LibraryView()
        viewController?.navigationController?.setViewControllers([mainViewController], animated: true)
    }

    func navigateToConfirmationScreen() {
        let confirmationViewController = ConfirmationView()
        viewController?.navigationController?.pushViewController(confirmationViewController, animated: true)
    }
}
