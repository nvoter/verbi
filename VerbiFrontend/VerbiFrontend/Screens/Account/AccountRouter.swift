//
//  AccountRouter.swift
//  VerbiFrontend
//
//  Created by Анастасия Манушкина on 25.01.2025.
//

import UIKit

final class AccountRouter: AccountRouterInput {
    // MARK: - Properties
    weak var viewController: UIViewController?

    // MARK: - AccountRouterInput
    func navigateToAuthScreen() {
        UIView.animate(withDuration: 0.3) {
            let authViewController = AuthViewFactory.build()

            guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                  let window = windowScene.windows.first else {
                print("Failed to get windowscene")
                return
            }

            window.rootViewController = authViewController
            window.makeKeyAndVisible()
        }
    }

    func navigateToMainScreen() {
        UIView.animate(withDuration: 0.3) {
            let mainViewController = LibraryViewFactory.build()

            guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                  let window = windowScene.windows.first else {
                print("Failed to get windowscene")
                return
            }

            window.rootViewController = mainViewController
            window.makeKeyAndVisible()
        }
    }
}
