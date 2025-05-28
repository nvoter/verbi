//
//  DocumentInteractor.swift
//  VerbiFrontend
//
//  Created by Анастасия Манушкина on 27.05.2025.
//

import Foundation
import PDFKit

final class DocumentInteractor: DocumentInteractorInput {
    // MARK: - Properties
    weak var output: DocumentInteractorOutput?
    private let apiWorker: LibraryApiWorkerProtocol & LlmApiWorkerProtocol
    private let sftpWorker: SFTPWorkerProtocol
    private let userId: UInt

    // MARK: - LifeCycle
    init(
        apiWorker: LibraryApiWorkerProtocol & LlmApiWorkerProtocol,
        sftpWorker: SFTPWorkerProtocol,
        userId: UInt = 1
    ) {
        self.apiWorker = apiWorker
        self.sftpWorker = sftpWorker
        self.userId = userId
    }

    // MARK: - DocumentInteractorInput
    func loadDocument(id: UInt, title: String) {
        apiWorker.fetchCredentials(userId: self.userId) { credRes in
            switch credRes {
            case .failure(let error):
                self.output?.didFail(with: error)
            case .success(let creds):
                let path = "/\(self.userId)/\(id)/\(title)"
                self.sftpWorker.downloadFullDocument(remotePath: path, credentials: creds) { result in
                    switch result {
                    case .failure(let error):
                        self.output?.didFail(with: error)
                    case .success(let url):
                        if let document = PDFDocument(url: url) {
                            self.output?.didLoad(document: document)
                        } else {
                            self.output?
                                .didFail(
                                    with: NSError(
                                        domain: "",
                                        code: -1,
                                        userInfo: [NSLocalizedDescriptionKey: "Unable to open PDF"]
                                    )
                                )
                        }
                    }
                }
            }
        }
    }

    func performLlmAction(
        text: String,
        action: DocumentAction,
        question: String?
    ) {
        let req = LlmRequest(
            query: text,
            queryType: String(describing: action),
            prompt: question ?? "",
            book: /* передайте название книги, если нужно */ ""
        )
        apiWorker.send(request: req) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let resp):
                    self?.output?.didReceiveLlmResponse(resp.response)
                case .failure(let err):
                    self?.output?.didFail(with: err)
                }
            }
        }
    }
}
