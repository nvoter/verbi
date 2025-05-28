//
//  LibraryProtocols.swift
//  VerbiFrontend
//
//  Created by Анастасия Манушкина on 22.01.2025.
//

import Foundation

// MARK: - View Protocols
protocol LibraryViewInput: AnyObject {
    func showEmptyState()
    func showDocuments(_ previews: [DocumentPreview])
    func reloadData()
    func showError(_ message: String)
    func presentDocumentPicker()
    func showLoading(_ isLoading: Bool)
}

protocol LibraryViewOutput {
    func viewDidLoad()
    func didTapAddButton()
    func didTapAccountButton()
    func didSelectItem(at indexPath: IndexPath)
    func didPickDocument(url: URL)
}

// MARK: - Interactor Protocols
protocol LibraryInteractorInput {
    func loadDocuments()
    func uploadDocument(at url: URL)
}

protocol LibraryInteractorOutput: AnyObject {
    func didFetch(previews: [DocumentPreview])
    func didFail(with error: Error)
}

// MARK: - Router Protocols
protocol LibraryRouterProtocol: AnyObject {
    func navigateToReader(with preview: DocumentPreview)
    func navigateToProfile()
}

// MARK: - Models
struct Document: Decodable {
    let id: UInt
    let userId: UInt
    let title: String
    let path: String

    private enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case title
        case path
    }
}
