//
//  SftpWorkerProtocol.swift
//  VerbiFrontend
//
//  Created by Анастасия Манушкина on 24.03.2025.
//

import Foundation

protocol SFTPWorkerProtocol {
    func downloadPreviews(
        for documents: [Document],
        credentials: GetCredentialsResponse,
        completion: @escaping (Result<[DocumentPreview], Error>) -> Void
    )
    func upload(
        documentURL: URL,
        remotePath: String,
        credentials: GetCredentialsResponse,
        completion: @escaping (Result<Void, Error>) -> Void
    )
    func downloadFullDocument(
        remotePath: String,
        credentials: GetCredentialsResponse,
        completion: @escaping (Result<URL, Error>) -> Void
    )
}
