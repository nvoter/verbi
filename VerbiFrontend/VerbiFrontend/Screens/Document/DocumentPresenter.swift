//
//  DocumentPresenter.swift
//  VerbiFrontend
//
//  Created by Анастасия Манушкина on 27.04.2025.
//

import PDFKit

final class DocumentPresenter: DocumentViewOutput {
    // MARK: - Properties
    weak var view: DocumentViewInput?
    var interactor: DocumentInteractorInput?
    var router: DocumentRouterProtocol?

    // MARK: - DocumentViewOutput
    func viewDidLoad(preview: DocumentPreview) {
        view?.showLoading(true)
        interactor?.loadDocument(id: preview.id, title: preview.title)
    }

    func didTapBackButton() {
        router?.navigateToMainScreen()
    }

    func didSelectText(_ text: String, action: DocumentAction, question: String?) {
        view?.showLoading(true)
        interactor?.performLlmAction(text: text, action: action, question: question)
    }
}

extension DocumentPresenter: DocumentInteractorOutput {
    func didFail(with error: Error) {
        view?.showError(error.localizedDescription)
    }

    func didLoad(document: PDFDocument) {
        view?.showLoading(false)
        view?.showDocument(document)
    }

    func didReceiveLlmResponse(_ response: String) {
        view?.showLoading(false)
        view?.showLlmResponse(response)
    }
}
