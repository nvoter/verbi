//
//  LibraryPresenter.swift
//  VerbiFrontend
//
//  Created by Анастасия Манушкина on 22.01.2025.
//

import UIKit

final class LibraryPresenter: LibraryViewOutput {
    // MARK: - Properties
    weak var view: LibraryViewInput?
    var interactor: LibraryInteractorInput?
    var router: LibraryRouterProtocol?

    private var previews: [DocumentPreview] = []

    // MARK: - LibraryViewOutput
    func viewDidLoad() {
        view?.showEmptyState()
        interactor?.loadDocuments()
    }
    func didTapAddButton() {
        view?.presentDocumentPicker()
    }
    func didTapAccountButton() {
        router?.navigateToProfile()
    }
    func didSelectItem(at indexPath: IndexPath) {
        let preview = previews[indexPath.row]
        router?.navigateToReader(with: preview)
    }
    func didPickDocument(url: URL) {
        view?.showLoading(true)
        interactor?.uploadDocument(at: url)
    }
}

// MARK: - LibraryInteractorOutput
extension LibraryPresenter: LibraryInteractorOutput {
    func didFetch(previews: [DocumentPreview]) {
        view?.showLoading(false)
        if previews.isEmpty {
            view?.showEmptyState()
        } else {
            self.previews = previews
            view?.showDocuments(previews)
            view?.reloadData()
        }
    }

    func didFail(with error: Error) {
        view?.showLoading(false)
        view?.showError(error.localizedDescription)
    }
}
