//
//  DocumentViewFactory.swift
//  VerbiFrontend
//
//  Created by Анастасия Манушкина on 27.04.2025.
//

import UIKit
import Swinject

final class DocumentViewFactory {
    static func build(with preview: DocumentPreview) -> UIViewController {
        let container = Container()

        container.register(LibraryApiWorkerProtocol.self) { _ in
            ApiWorker()
        }

        container.register(SFTPWorkerProtocol.self) { _ in
            SFTPWorker()
        }

        let router = DocumentRouter()
        container.register(DocumentRouterProtocol.self) { _ in
            router
        }

        container.register(DocumentInteractorInput.self) { resolver in
            guard let api = resolver.resolve(LibraryApiWorkerProtocol.self),
                  let sftp = resolver.resolve(SFTPWorkerProtocol.self) else {
                fatalError("Could not resolve ApiWorker or SFTPWorker for DocumentInteractor")
            }
            guard let api = api as? LibraryApiWorkerProtocol & LlmApiWorkerProtocol else {
                fatalError("api must conform to LibraryApiWorkerProtocol & LlmApiWorkerProtocol")
            }
            let interactor = DocumentInteractor(apiWorker: api, sftpWorker: sftp)
            return interactor
        }

        container.register(DocumentViewOutput.self) { resolver in
            guard let interactor = resolver.resolve(DocumentInteractorInput.self) as? DocumentInteractor,
                  let router = resolver.resolve(DocumentRouterProtocol.self) else {
                fatalError("Could not resolve DocumentInteractor or Router for DocumentPresenter")
            }
            let presenter = DocumentPresenter()
            presenter.interactor = interactor
            presenter.router = router
            interactor.output = presenter
            return presenter
        }

        container.register(DocumentViewInput.self) { resolver in
            guard let presenter = resolver.resolve(DocumentViewOutput.self) as? DocumentPresenter else {
                fatalError("Could not resolve DocumentPresenter for DocumentView")
            }
            let view = DocumentView(presenter: presenter, preview: preview)
            presenter.view = view
            return view
        }

        container.register(UIViewController.self, name: "DocumentView") { resolver in
            guard let view = resolver.resolve(DocumentViewInput.self) as? DocumentView else {
                fatalError("Could not resolve DocumentView")
            }
            let nav = UINavigationController(rootViewController: view)
            router.view = nav
            return nav
        }

        guard let viewController = container.resolve(UIViewController.self, name: "DocumentView") else {
            fatalError("Could not resolve DocumentView from container")
        }

        return viewController
    }
}
