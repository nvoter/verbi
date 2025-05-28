//
//  SftpWorker.swift
//  VerbiFrontend
//
//  Created by Анастасия Манушкина on 24.04.2025.
//

import Foundation
import mft
import UIKit

final class SFTPWorker: SFTPWorkerProtocol {
    // MARK: - DownloadPreviews
    func downloadPreviews(
        for documents: [Document],
        credentials: GetCredentialsResponse,
        completion: @escaping (Result<[DocumentPreview], Error>) -> Void
    ) {
        guard let port = Int(credentials.port) else {
            return completion(
                .failure(
                    NSError(domain: "", code: 0, userInfo: [
                        NSLocalizedDescriptionKey: "Invalid port"
                    ])
                )
            )
        }

        let sftp = MFTSftpConnection(
            hostname: credentials.host,
            port: port,
            username: credentials.username,
            password: credentials.password
        )

        do {
            try sftp.connect()
            try sftp.authenticate()

            var previews = [DocumentPreview]()
            for doc in documents {
                let path = doc.path.hasPrefix("/") ? doc.path : "/" + doc.path

                let remotePreview = path + "/preview.pdf"
                let localURL  = FileManager.default
                    .temporaryDirectory
                    .appendingPathComponent("preview_\(doc.id).pdf")

                let outStream = OutputStream(url: localURL, append: false)!
                defer { outStream.close() }

                try sftp.contents(
                    atPath: remotePreview,
                    toStream: outStream,
                    fromPosition: 0
                ) { _, _ in
                    return true
                }

                if let img = imageFromPDF(at: localURL) {
                    previews.append(.init(
                        id: doc.id,
                        title: doc.title,
                        image: img
                    ))
                }
            }

            sftp.disconnect()
            completion(.success(previews))
        } catch {
            completion(.failure(error))
        }
    }

    // MARK: - Upload
    func upload(
        documentURL: URL,
        remotePath: String,
        credentials: GetCredentialsResponse,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        guard let port = Int(credentials.port) else {
            return completion(
                .failure(
                    NSError(domain: "", code: 0, userInfo: [
                        NSLocalizedDescriptionKey: "Invalid port"
                    ])
                )
            )
        }

        let sftp = MFTSftpConnection(
            hostname: credentials.host,
            port: port,
            username: credentials.username,
            password: credentials.password
        )

        do {
            try sftp.connect()
            try sftp.authenticate()

            let filename = documentURL.lastPathComponent
            let remoteDir = remotePath.hasPrefix("/") ? remotePath : "/" + remotePath
            let fullRemote = remoteDir + "/" + filename
            let inStream = InputStream(url: documentURL)!

            try sftp.write(
                stream: inStream,
                toFileAtPath: fullRemote,
                append: false
            ) { _ in
                return true
            }

            let dir = (fullRemote as NSString).deletingLastPathComponent
            let previewRemote = dir + "/preview.pdf"
            let previewUrl = try generatePreviewPdf(from: documentURL)
            guard let prStream = InputStream(url: previewUrl) else { return }
            prStream.open()
            defer { prStream.close() }

            try sftp.write(
                stream: prStream,
                toFileAtPath: previewRemote,
                append: false
            ) { _ in
                return true
            }

            sftp.disconnect()
            completion(.success(()))
        } catch {
            completion(.failure(error))
        }
    }

    // MARK: - DownloadFullDocument
    func downloadFullDocument(
        remotePath: String,
        credentials: GetCredentialsResponse,
        completion: @escaping (Result<URL, Error>) -> Void
    ) {
        guard let port = Int(credentials.port) else {
            return completion(.failure(NSError(
                domain: "SFTPWorker", code: 0,
                userInfo: [NSLocalizedDescriptionKey: "Invalid port"])))
        }
        let sftp = MFTSftpConnection(
            hostname: credentials.host,
            port: port,
            username: credentials.username,
            password: credentials.password
        )
        do {
            try sftp.connect()
            try sftp.authenticate()

            let localURL = FileManager.default
                .temporaryDirectory
                .appendingPathComponent((remotePath as NSString).lastPathComponent)

            let out = OutputStream(url: localURL, append: false)!
            out.open()
            defer { out.close() }

            try sftp.contents(
                atPath: remotePath,
                toStream: out,
                fromPosition: 0
            ) { _, _ in
                true
            }

            sftp.disconnect()
            completion(.success(localURL))
        } catch {
            sftp.disconnect()
            completion(.failure(error))
        }
    }

    // MARK: - Methods
    private func imageFromPDF(at url: URL) -> UIImage? {
        guard let doc = CGPDFDocument(url as CFURL),
              let page = doc.page(at: 1)
        else { return nil }
        let rect = page.getBoxRect(.mediaBox)
        let renderer = UIGraphicsImageRenderer(size: rect.size)
        return renderer.image { ctx in
            UIColor.white.setFill()
            ctx.fill(rect)
            ctx.cgContext.translateBy(x: 0, y: rect.height)
            ctx.cgContext.scaleBy(x: 1, y: -1)
            ctx.cgContext.drawPDFPage(page)
        }
    }

    private func generatePreviewPdf(from sourceURL: URL) throws -> URL {
        guard
            let pdf = CGPDFDocument(sourceURL as CFURL),
            let page = pdf.page(at: 1)
        else {
            throw NSError(domain: "PreviewGen", code: 0, userInfo: [
                NSLocalizedDescriptionKey: "Cannot open PDF for preview"
            ])
        }
        let rect = page.getBoxRect(.mediaBox)
        let previewURL = FileManager.default
            .temporaryDirectory
            .appendingPathComponent("preview_\(UUID().uuidString).pdf")

        let renderer = UIGraphicsPDFRenderer(bounds: rect)
        try renderer.writePDF(to: previewURL) { ctx in
            ctx.beginPage()
            let cgCtx = ctx.cgContext
            cgCtx.translateBy(x: 0, y: rect.height)
            cgCtx.scaleBy(x: 1, y: -1)
            cgCtx.drawPDFPage(page)
        }

        return previewURL
    }
}
