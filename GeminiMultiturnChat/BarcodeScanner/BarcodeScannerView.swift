//
//  BarcodeScannerView.swift
//  GeminiMultiturnChat
//
//  Created by Sri Yanamandra on 4/7/24.
//

import Foundation
import BarcodeScanner
import SwiftUI

struct BarcodeScannerView: UIViewControllerRepresentable {
    @Binding var scannedBarcode: String?
    @Binding var isScanningBarcode: Bool
    
    func makeUIViewController(context: Context) -> BarcodeScannerViewController {
        let scannerViewController = BarcodeScannerViewController()
        scannerViewController.codeDelegate = context.coordinator
        scannerViewController.errorDelegate = context.coordinator
        scannerViewController.dismissalDelegate = context.coordinator
        return scannerViewController
    }
    
    func updateUIViewController(_ uiViewController: BarcodeScannerViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, BarcodeScannerCodeDelegate, BarcodeScannerErrorDelegate, BarcodeScannerDismissalDelegate {
        let parent: BarcodeScannerView
        
        init(_ parent: BarcodeScannerView) {
            self.parent = parent
        }
        
        func scanner(_ controller: BarcodeScannerViewController, didCaptureCode code: String, type: String) {
            parent.scannedBarcode = code
            parent.isScanningBarcode = false
        }
        
        func scanner(_ controller: BarcodeScannerViewController, didReceiveError error: Error) {
            print("Scanning error: \(error.localizedDescription)")
        }
        
        func scannerDidDismiss(_ controller: BarcodeScannerViewController) {
            parent.isScanningBarcode = false
        }
    }
}
