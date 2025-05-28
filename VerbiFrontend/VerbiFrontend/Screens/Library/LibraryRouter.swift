//
//  LibraryRouter.swift
//  VerbiFrontend
//
//  Created by Анастасия Манушкина on 22.01.2025.
//

import UIKit

final class LibraryRouter: LibraryRouterProtocol {
    weak var view: UIViewController?

    func navigateToReader(with preview: DocumentPreview) {
        let viewController = DocumentViewFactory.build(with: preview)

        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first else {
            print("Failed to get window")
            return
        }

        window.rootViewController = viewController
        window.makeKeyAndVisible()
    }

    func navigateToProfile() {
        let viewController = AccountViewFactory.build()

        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first else {
            print("Failed to get window")
            return
        }

        window.rootViewController = viewController
        window.makeKeyAndVisible()
    }
}
