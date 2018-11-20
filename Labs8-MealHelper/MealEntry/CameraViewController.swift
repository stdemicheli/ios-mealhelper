//
//  CameraViewController.swift
//  Labs8-MealHelper
//
//  Created by De MicheliStefano on 15.11.18.
//  Copyright © 2018 De MicheliStefano. All rights reserved.
//

import UIKit
import AVFoundation
import Firebase

class CameraViewController: UIViewController {
    
    // MARK: - Properties
    private var captureSession: AVCaptureSession!
    private var previewView = CameraPreview()
    private lazy var vision = Vision.vision() // Firebase vision API
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupCapture()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Call startRunning() to let data flow from inputs to outputs
        captureSession.startRunning()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        captureSession.stopRunning()
    }
    
    // MARK: - User actions
    
    
    // MARK: - Configuration
    
    private func updateViews() {
        guard isViewLoaded else { return }
        
    }
    
    private func setupCapture() {
        // Setup: AVCaptureDeviceInput --> AVCaptureSession --> AVCaptureOutput (i.e. AVCaptureVideoPreviewLayer & AVCaptureVideoDataOutput)
        
        // Session
        let captureSession = AVCaptureSession()
        
        // VideoPreviewLayer
        view.addSubview(previewView)
        previewView.fillSuperview()
        
        // Input
        let device = bestCamera()
        guard let videoDeviceInput = try? AVCaptureDeviceInput(device: device),
            captureSession.canAddInput(videoDeviceInput) else { // check if it can be added or not
                // fatalError()
                // TODO: Handle absence of appropriate capture device (e.g. alert view "No camera available")
                return
        }
        captureSession.addInput(videoDeviceInput)
        
        // VideoDataOutput
        let videoDataOutput = AVCaptureVideoDataOutput()
        // TODO: Set Videosettings (compression settings)
        // DispatchQueue that will handle video frames
        let dataOutputQueue = DispatchQueue(label: "video-data-queue",
                                            qos: .userInitiated,
                                            attributes: [],
                                            autoreleaseFrequency: .workItem)
        videoDataOutput.setSampleBufferDelegate(self, queue: dataOutputQueue)
        videoDataOutput.videoSettings = [(kCVPixelBufferPixelFormatTypeKey as String) : NSNumber(value: kCVPixelFormatType_32BGRA as UInt32)]
        
        if captureSession.canAddOutput(videoDataOutput) {
            captureSession.addOutput(videoDataOutput)
        }
        
        captureSession.sessionPreset = .hd1920x1080
        captureSession.commitConfiguration() // Save all configurations and set up captureSession
        
        self.captureSession = captureSession
        
        previewView.videoPreviewLayer.session = captureSession
    }
    
    // Camera's nowadays have a variety of cameras, so this function takes the best camera on the device
    private func bestCamera() -> AVCaptureDevice {
        if let device = AVCaptureDevice.default(.builtInDualCamera, for: .video, position: .back) {
            return device
        } else if let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) {
            return device
        } else {
            fatalError("Missing expected back camera device")
        }
    }
    
}

// MARK: - AVCaptureVideoDataOutputSampleBufferDelegate

extension CameraViewController: AVCaptureVideoDataOutputSampleBufferDelegate {
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        // Detect video frames with Firebase MLVisionBarcodeModel
        detectBarcodes(with: sampleBuffer)
    }
    
    // Keep in case we need to work with images (e.g. compression)
    private func imageFromSampleBuffer(_ sampleBuffer : CMSampleBuffer) -> UIImage {
        // Get a CMSampleBuffer's Core Video image buffer for the media data
        let  imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer)
        
        // Lock the base address of the pixel buffer
        CVPixelBufferLockBaseAddress(imageBuffer!, CVPixelBufferLockFlags.readOnly);
        
        // Get the number of bytes per row, width and height for the pixel buffer
        let baseAddress = CVPixelBufferGetBaseAddress(imageBuffer!)
        let bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer!)
        let width = CVPixelBufferGetWidth(imageBuffer!)
        let height = CVPixelBufferGetHeight(imageBuffer!)
        
        // Create a device-dependent RGB color space
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        
        // Create a bitmap graphics context with the sample buffer data
        var bitmapInfo: UInt32 = CGBitmapInfo.byteOrder32Little.rawValue
        bitmapInfo |= CGImageAlphaInfo.premultipliedFirst.rawValue & CGBitmapInfo.alphaInfoMask.rawValue
        //let bitmapInfo: UInt32 = CGBitmapInfo.alphaInfoMask.rawValue
        let context = CGContext.init(data: baseAddress, width: width, height: height, bitsPerComponent: 8, bytesPerRow: bytesPerRow, space: colorSpace, bitmapInfo: bitmapInfo)
        // Create a Quartz image from the pixel data in the bitmap graphics context
        let quartzImage = context?.makeImage()
        // Unlock the pixel buffer
        CVPixelBufferUnlockBaseAddress(imageBuffer!, CVPixelBufferLockFlags.readOnly)
        
        // Create an image object from the Quartz image
        let image = UIImage.init(cgImage: quartzImage!)
        
        return (image)
    }
    
}

extension CameraViewController {
    
    func detectBarcodes(with buffer: CMSampleBuffer) {
        // Define options for barcode detector
        let format = VisionBarcodeFormat.all // TODO: restrict format for better performance
        let barcodeOptions = VisionBarcodeDetectorOptions(formats: format)
        
        // Create barcode detector
        let barcodeDetector = vision.barcodeDetector(options: barcodeOptions)
        
        let visionImage = VisionImage(buffer: buffer)
        
        barcodeDetector.detect(in: visionImage) { (features, error) in
            if let error = error {
                NSLog("On-device barcode detection failed with error \(String(describing: error))")
                return
            }
            
            guard let features = features, !features.isEmpty else {
                NSLog("No barcode detected")
                return
            }
            
            let barcodeString = features.first?.rawValue
            
        }
    }
    
    func detectBarcodes(with image: UIImage) {
        // Define options for barcode detector
        let format = VisionBarcodeFormat.all
        let barcodeOptions = VisionBarcodeDetectorOptions(formats: format)
        
        vision.cloudddete
        // Create barcode detector
        let barcodeDetector = vision.barcodeDetector(options: barcodeOptions)
        
        let visionImage = VisionImage(image: image)
        
        barcodeDetector.detect(in: visionImage) { (features, error) in
            if let error = error {
                NSLog("On-device barcode detection failed with error \(String(describing: error))")
                return
            }
            
            guard let features = features, !features.isEmpty else {
                NSLog("No barcode detected")
                return
            }
            
            let barcodeString = features.first?.rawValue
        }
    }
    
}
