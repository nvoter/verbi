//
//  DocumentPickerViewController.swift
//  VerbiFrontend
//
//  Created by Анастасия Манушкина on 13.05.2025.
//

import UIKit

class DocumentPickerViewController: UIViewController, UIDocumentPickerDelegate {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white

        let openDocumentButton = UIButton(type: .system)
        openDocumentButton.setTitle("Выбрать файл", for: .normal)
        openDocumentButton.addTarget(self, action: #selector(openDocumentPicker), for: .touchUpInside)
        openDocumentButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(openDocumentButton)

        NSLayoutConstraint.activate([
            openDocumentButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            openDocumentButton.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    @objc private func openDocumentPicker() {
        // Создаем Document Picker
        let documentPicker = UIDocumentPickerViewController(forOpeningContentTypes: [.item], asCopy: true)
        documentPicker.delegate = self
        documentPicker.allowsMultipleSelection = false // Разрешить выбор только одного файла
        present(documentPicker, animated: true, completion: nil)
    }

    // MARK: - UIDocumentPickerDelegate

    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard let selectedFileURL = urls.first else { return }

        // Обработка выбранного файла
        print("Выбранный файл: \(selectedFileURL)")

        // Пример: Чтение содержимого файла
        do {
            let fileContent = try String(contentsOf: selectedFileURL, encoding: .utf8)
            print("Содержимое файла: \(fileContent)")
        } catch {
            print("Ошибка чтения файла: \(error.localizedDescription)")
        }
    }

    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        print("Пользователь отменил выбор файла")
    }
}
