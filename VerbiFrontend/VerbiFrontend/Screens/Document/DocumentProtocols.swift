//
//  DocumentProtocols.swift
//  VerbiFrontend
//
//  Created by Анастасия Манушкина on 27.05.2025.
//

import Foundation
import PDFKit

// MARK: - View Protocols
protocol DocumentViewInput: AnyObject {
    func showError(_ message: String)
    func showDocument(_ document: PDFDocument)
    func showLoading(_ isLoading: Bool)
    func showLlmResponse(_ response: String)
}

protocol DocumentViewOutput {
    func viewDidLoad(preview: DocumentPreview)
    func didTapBackButton()
    func didSelectText(_ text: String, action: DocumentAction, question: String?)
}

// MARK: - Interactor Protocols
protocol DocumentInteractorInput {
    func loadDocument(id: UInt, title: String)
    func performLlmAction(text: String, action: DocumentAction, question: String?)
}

protocol DocumentInteractorOutput: AnyObject {
    func didFail(with error: Error)
    func didLoad(document: PDFDocument)
    func didReceiveLlmResponse(_ response: String)
}

// MARK: - Router Protocols
protocol DocumentRouterProtocol: AnyObject {
    func navigateToMainScreen()
}

// MARK: - Models
enum DocumentAction {
    case question
    case rephrase
    case summarize
}
