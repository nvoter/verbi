//
//  AccountViewFactory.swift
//  VerbiFrontend
//
//  Created by Анастасия Манушкина on 25.01.2025.
//

import UIKit
import Swinject

final class AccountViewFactory {
    static func build() -> UIViewController {
        let container = Container()

        container.register(AuthApiWorkerProtocol.self) { _ in
            return ApiWorker()
        }

        let router = AccountRouter()

        container.register(AccountInteractorInput.self) { resolver in
            guard let apiWorker = resolver.resolve(AuthApiWorkerProtocol.self) else {
                fatalError("Could not resolve apiWorker")
            }
            let interactor = AccountInteractor(apiWorker: apiWorker)
            return interactor
        }

        container.register(AccountViewOutput.self) { resolver in
            guard let interactor = resolver.resolve(AccountInteractorInput.self) as? AccountInteractor else {
                fatalError("Could not resolve accountPresenter dependencies")
            }
            let presenter = AccountPresenter(interactor: interactor, router: router)
            interactor.output = presenter
            return presenter
        }

        container.register(AccountViewInput.self) { resolver in
            guard let presenter = resolver.resolve(AccountViewOutput.self) as? AccountPresenter else {
                fatalError("Could not resolve accountView dependencies")
            }
            let view = AccountView(presenter: presenter)
            presenter.view = view
            return view
        }

        container.register(UIViewController.self, name: "AccountView") { resolver in
            guard let view = resolver.resolve(AccountViewInput.self)! as? AccountView else {
                fatalError("Could not resolve accountView")
            }
            return view
        }

        guard let viewController = container.resolve(UIViewController.self, name: "AccountView") else {
            fatalError("Could not resolve accountView")
        }

        router.viewController = viewController
        return viewController
    }
}
