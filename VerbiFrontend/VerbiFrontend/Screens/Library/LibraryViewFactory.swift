//
//  LibraryViewFactory.swift
//  VerbiFrontend
//
//  Created by Анастасия Манушкина on 24.01.2025.
//

import UIKit
import Swinject

final class LibraryViewFactory {
    static func build() -> UIViewController {
        let container = Container()

        container.register(LibraryApiWorkerProtocol.self) { _ in
            ApiWorker()
        }

        container.register(SFTPWorkerProtocol.self) { _ in
            SFTPWorker()
        }

        let router = LibraryRouter()
        container.register(LibraryRouterProtocol.self) { _ in
            router
        }

        container.register(LibraryInteractorInput.self) { resolver in
            guard let api = resolver.resolve(LibraryApiWorkerProtocol.self),
                  let sftp = resolver.resolve(SFTPWorkerProtocol.self) else {
                fatalError("Could not resolve ApiWorker or SFTPWorker for LibraryInteractor")
            }
            let interactor = LibraryInteractor(api: api, sftp: sftp)
            return interactor
        }

        container.register(LibraryViewOutput.self) { resolver in
            guard let interactor = resolver.resolve(LibraryInteractorInput.self) as? LibraryInteractor,
                  let router = resolver.resolve(LibraryRouterProtocol.self) else {
                fatalError("Could not resolve LibraryInteractor or Router for LibraryPresenter")
            }
            let presenter = LibraryPresenter()
            presenter.interactor = interactor
            presenter.router = router
            interactor.output = presenter
            return presenter
        }

        container.register(LibraryViewInput.self) { resolver in
            guard let presenter = resolver.resolve(LibraryViewOutput.self) as? LibraryPresenter else {
                fatalError("Could not resolve LibraryPresenter for LibraryView")
            }
            let view = LibraryView(presenter: presenter)
            presenter.view = view
            return view
        }

        container.register(UIViewController.self, name: "LibraryView") { resolver in
            guard let view = resolver.resolve(LibraryViewInput.self) as? LibraryView else {
                fatalError("Could not resolve LibraryView")
            }
            let nav = UINavigationController(rootViewController: view)
            router.view = nav
            return nav
        }

        guard let viewController = container.resolve(UIViewController.self, name: "LibraryView") else {
            fatalError("Could not resolve LibraryView from container")
        }

        return viewController
    }
}
