//
//  LibraryInteractor.swift
//  VerbiFrontend
//
//  Created by Анастасия Манушкина on 22.01.2025.
//

import Foundation
import UIKit

final class LibraryInteractor: LibraryInteractorInput {
    // MARK: - Properties
    weak var output: LibraryInteractorOutput?
    private let api: LibraryApiWorkerProtocol
    private let sftp: SFTPWorkerProtocol
    private let userId: UInt = 1

    // MARK: - LifeCycle
    init(
        api: LibraryApiWorkerProtocol,
        sftp: SFTPWorkerProtocol
    ) {
        self.api = api
        self.sftp = sftp
    }

    // MARK: - LibraryInteractorInput
    func loadDocuments() {
        api.fetchDocuments(userId: userId) { [weak self] res in
            switch res {
            case .failure(let error):
                self?.output?.didFail(with: error)
            case .success(let docs):
                guard let self else { return }
                guard !docs.isEmpty else {
                    self.output?.didFetch(previews: [])
                    return
                }
                self.api.fetchCredentials(userId: self.userId) { credRes in
                    switch credRes {
                    case .failure(let error):
                        self.output?.didFail(with: error)
                    case .success(let creds):
                        self.sftp.downloadPreviews(for: docs, credentials: creds) { dlRes in
                            switch dlRes {
                            case .failure(let error):
                                self.output?.didFail(with: error)
                            case .success(let previews):
                                self.output?.didFetch(previews: previews)
                            }
                        }
                    }
                }
            }
        }
    }

    func uploadDocument(at url: URL) {
        let title = url.lastPathComponent
        api.createDocument(userId: userId, title: title) { [weak self] res in
            guard let self else { return }
            switch res {
            case .failure(let error):
                self.output?.didFail(with: error)
            case .success(let resp):
                self.sftp
                    .upload(
                        documentURL: url,
                        remotePath: resp.path,
                        credentials: resp.sftp
                    ) { [weak self] result in
                        guard let self else { return }
                        switch result {
                        case .failure(let error):
                            self.output?.didFail(with: error)
                        case .success:
                            self.loadDocuments()
                        }
                    }
            }
        }
    }
}
