//
//  AuthViewFactory.swift
//  VerbiFrontend
//
//  Created by Анастасия Манушкина on 20.01.2025.
//

import UIKit
import Swinject

final class AuthViewFactory {
    static func build() -> UIViewController {
        let container = Container()

        container.register(ApiWorkerProtocol.self) { _ in
            return ApiWorker()
        }

        let router = AuthRouter()

        container.register(AuthInteractorInput.self) { resolver in
            guard let apiWorker = resolver.resolve(ApiWorkerProtocol.self) else {
                fatalError("Could not resolve apiWorker")
            }
            let interactor = AuthInteractor(apiWorker: apiWorker)
            return interactor
        }

        container.register(AuthViewOutput.self) { resolver in
            guard let interactor = resolver.resolve(AuthInteractorInput.self) as? AuthInteractor else {
                fatalError("Could not resolve authPresenter dependencies")
            }
            let presenter = AuthPresenter(interactor: interactor, router: router)
            interactor.output = presenter
            return presenter
        }

        container.register(AuthViewInput.self) { resolver in
            guard let presenter = resolver.resolve(AuthViewOutput.self) as? AuthPresenter else {
                fatalError("Could not resolve authView dependencies")
            }
            let view = AuthView(presenter: presenter)
            presenter.view = view
            return view
        }

        container.register(UIViewController.self, name: "AuthView") { resolver in
            guard let view = resolver.resolve(AuthViewInput.self)! as? AuthView else {
                fatalError("Could not resolve authView")
            }
            return UINavigationController(rootViewController: view)
        }

        guard let viewController = container.resolve(UIViewController.self, name: "AuthView") else {
            fatalError("Could not resolve authView")
        }

        router.viewController = viewController
        return viewController
    }
}
