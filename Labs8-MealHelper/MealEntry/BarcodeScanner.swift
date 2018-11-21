//
//  BarcodeScanner.swift
//  Labs8-MealHelper
//
//  Created by De MicheliStefano on 19.11.18.
//  Copyright © 2018 De MicheliStefano. All rights reserved.
//

import UIKit
import Firebase


public protocol BarcodeScannerDelegate: class {
    func barcodeScanner(_ controller: BarcodeScanner, didChangeStatus status: BarcodeScanner.Status)
    func barcodeScanner(_ controller: BarcodeScanner, didFinishScanningWithCode barcode: String)
    func barcodeScanner(_ controller: BarcodeScanner, didReceiveError error: Error)
    func barcodeScannerWillDismiss(_ controller: BarcodeScanner)
}

open class BarcodeScanner {
    
    public enum Status: String {
        case scanning // Scanning, but no barcode yet being detected
        case processing // Barcode detected and processed
        case notFound // No barcode found
    }
    
    // MARK: - Public properties

    public weak var delegate: BarcodeScannerDelegate?
    
    // MARK: - Private properties
    
    private lazy var vision = Vision.vision() // Firebase vision API
        
    // MARK: - Public
    
    public func detectBarcodes(with buffer: CMSampleBuffer) {
        delegate?.barcodeScanner(self, didChangeStatus: Status.processing)
        
        // Define options for barcode detector
        let format = VisionBarcodeFormat.all // TODO: restrict format for better performance
        let barcodeOptions = VisionBarcodeDetectorOptions(formats: format)
        
        // Create barcode detector
        let barcodeDetector = vision.barcodeDetector(options: barcodeOptions)
        
        let visionImage = VisionImage(buffer: buffer)
        
        barcodeDetector.detect(in: visionImage) { (features, error) in
            if let error = error {
                NSLog("On-device barcode detection failed with error \(String(describing: error))")
                self.delegate?.barcodeScanner(self, didReceiveError: error)
                return
            }
            
            guard let features = features, !features.isEmpty else {
                NSLog("No barcode detected")
                self.delegate?.barcodeScanner(self, didChangeStatus: Status.notFound)
                return
            }
            
            if let barcodeString = features.first?.rawValue {
                self.delegate?.barcodeScanner(self, didFinishScanningWithCode: barcodeString)
                print(barcodeString)
            }
            
            self.delegate?.barcodeScanner(self, didChangeStatus: Status.scanning)
        }
    }
    
    public func detectBarcodes(with image: UIImage) {
        delegate?.barcodeScanner(self, didChangeStatus: Status.processing)
        
        // Define options for barcode detector
        let format = VisionBarcodeFormat.all
        let barcodeOptions = VisionBarcodeDetectorOptions(formats: format)
        
        // Create barcode detector
        let barcodeDetector = vision.barcodeDetector(options: barcodeOptions)
        
        let visionImage = VisionImage(image: image)
        
        barcodeDetector.detect(in: visionImage) { (features, error) in
            if let error = error {
                NSLog("On-device barcode detection failed with error \(String(describing: error))")
                self.delegate?.barcodeScanner(self, didReceiveError: error)
                return
            }
            
            guard let features = features, !features.isEmpty else {
                NSLog("No barcode detected")
                self.delegate?.barcodeScanner(self, didChangeStatus: Status.notFound)
                return
            }
            
            if let barcodeString = features.first?.rawValue {
                self.delegate?.barcodeScanner(self, didFinishScanningWithCode: barcodeString)
                print(barcodeString)
            }
            
            self.delegate?.barcodeScanner(self, didChangeStatus: Status.scanning)
        }
    }

}
