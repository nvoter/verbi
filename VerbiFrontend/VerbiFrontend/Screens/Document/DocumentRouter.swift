//
//  DocumentRouter.swift
//  VerbiFrontend
//
//  Created by Анастасия Манушкина on 27.04.2025.
//

import UIKit

final class DocumentRouter: DocumentRouterProtocol {
    // MARK: - Properties
    weak var view: UIViewController?

    // MARK: - DocumentRouterProtocol
    func navigateToMainScreen() {
        let viewController = LibraryViewFactory.build()

        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first else {
            print("Failed to get window")
            return
        }

        window.rootViewController = viewController
        window.makeKeyAndVisible()
    }
}
