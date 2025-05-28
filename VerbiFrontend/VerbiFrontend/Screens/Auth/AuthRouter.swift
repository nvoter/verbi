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

    // MARK: - AuthRouterInput
    func navigateToMainScreen() {
        let mainViewController = LibraryViewFactory.build()

        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first else {
            print("Failed to get window")
            return
        }

        window.rootViewController = mainViewController
        window.makeKeyAndVisible()
    }
}
