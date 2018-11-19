//
//  BarcodeScanner.swift
//  Labs8-MealHelper
//
//  Created by De MicheliStefano on 19.11.18.
//  Copyright © 2018 De MicheliStefano. All rights reserved.
//

import UIKit
import Firebase

public enum BarcodeStatus: String {
    case scanning
    case processing
    case notFound
}

public protocol BarcodeScannerDelegate: class {
    func barcodeScanner(_ controller: BarcodeScanner, didChangeStatus status: BarcodeStatus)
    func barcodeScanner(_ controller: BarcodeScanner, didFinishScanningWithCode barcode: String)
    func barcodeScanner(_ controller: BarcodeScanner, didReceiveError error: Error)
    func barcodeScannerWillDismiss(_ controller: BarcodeScanner)
}

open class BarcodeScanner: UIViewController {
    
    // MARK: - Public properties

    public weak var delegate: BarcodeScannerDelegate?
    
    // MARK: - Private properties
    
    // MARK: - Life Cycle
    
    open override func viewDidLoad() {
        super.viewDidLoad()

        
    }
    
    // MARK: - Layout
    
    private func setupViews() {
        
    }

}
