//
//  DocumentExporter.swift
//  KochRezepte
//
//  Created by Caner Oktay on 22.07.26.
//

import SwiftUI
import UIKit

struct DocumentExporter: UIViewControllerRepresentable {
    let url: URL
    var onCompletion: (Bool) -> Void

    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        let picker = UIDocumentPickerViewController(forExporting: [url], asCopy: true)
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {}

    func makeCoordinator() -> Coordinator { Coordinator(onCompletion: onCompletion) }

    final class Coordinator: NSObject, UIDocumentPickerDelegate {
        let onCompletion: (Bool) -> Void
        init(onCompletion: @escaping (Bool) -> Void) { self.onCompletion = onCompletion }

        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            onCompletion(true)
        }
        func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
            onCompletion(false)
        }
    }
}
