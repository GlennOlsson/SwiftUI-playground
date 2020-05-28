//
//  QRCodeReader.swift
//  SwiftUI testing
//
//  Created by Glenn Olsson on 2020-05-27.
//  Copyright © 2020 Glenn Olsson. All rights reserved.
//

import Foundation
import SwiftUI
import AVFoundation
import UIKit

struct QRCodeReader: UIViewControllerRepresentable {
	class Coordinator: NSObject, AVCaptureMetadataOutputObjectsDelegate {
		var layer: CALayer?
		
		var captureSession: AVCaptureSession?
		var input: AVCaptureInput?
		
		var previewLayer: AVCaptureVideoPreviewLayer?
		
		var lastCodeContent: String = ""
		
		var onScan: (String) -> Void
		
		/// onScan takes one parameter, the stringvalue of the QR code
		init(onScan: @escaping (String) -> Void) {
			self.onScan = onScan
		}
		
		func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
			if metadataObjects.count == 0 {
				lastCodeContent = ""
			}
			
			if let metadata = metadataObjects.first {
				let bounds = self.previewLayer?.transformedMetadataObject(for: metadata)?.bounds
				self.layer!.frame = CGRect(x: bounds!.origin.x, y: bounds!.origin.y, width: bounds!.width, height: bounds!.height)
				if let readableObject = metadata as? AVMetadataMachineReadableCodeObject {
					guard let stringValue = readableObject.stringValue else { return }
					if lastCodeContent != stringValue {
						self.lastCodeContent = stringValue
						onScan(stringValue)
					}
				}
			}
		}
		
	}
	
	@Binding var isFrontCamera: Bool
	@Binding var isShowing: Bool
	
	var onScan: (String) -> Void
	
	func makeCoordinator() -> Coordinator {
		return Coordinator(onScan: self.onScan)
	}
	
	func makeUIViewController(context: Context) -> UIViewController {
		let viewController = UIViewController()
		
		self.createNewScannerLayer(controller: viewController, context: context, captureDevice: getCamera(isFront: self.isFrontCamera))
		
		return viewController
	}
	
	func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
		
		let captureSession = context.coordinator.captureSession!
		let input = context.coordinator.input!
		captureSession.stopRunning()
		
		let newInputOptional = createAVInput(captureDevice: getCamera(isFront: self.isFrontCamera))
		guard let newInput = newInputOptional else { return }
		
		captureSession.removeInput(input)
		
		if captureSession.canAddInput(newInput) {
			captureSession.addInput(newInput)
			context.coordinator.input = newInput
		}
				
		context.coordinator.layer?.isHidden = true
		
		if self.isShowing {
			captureSession.startRunning()
		} else {
			captureSession.stopRunning()
		}
		
		
		//		self.createNewScannerLayer(controller: uiViewController, context: context, captureDevice: getCamera(isFront: self.isFrontCamera))
	}
	
	private func getCamera(isFront: Bool) -> AVCaptureDevice? {
		if isFront {
			return AVCaptureDevice.default(.builtInTrueDepthCamera, for: .video, position: .front)
		} else {
			return AVCaptureDevice.default(.builtInDualWideCamera, for: .video, position: .back)
		}
	}
	
	private func createNewScannerLayer(controller: UIViewController, context: Context, captureDevice: AVCaptureDevice?) {
		let captureSession = AVCaptureSession()
		context.coordinator.captureSession = captureSession
		
		guard let captureDevice = captureDevice else {
			print("Could not get default capture device")
			return
		}
		
		guard let avInput = self.createAVInput(captureDevice: captureDevice) else {
			print("AVInput was nil")
			return
		}
		
		context.coordinator.input = avInput
		
		if (captureSession.canAddInput(avInput)) {
			captureSession.addInput(avInput)
		} else {
			print("Could not add input")
			return
		}
		
		let metadataOutput = AVCaptureMetadataOutput()
		
		if captureSession.canAddOutput(metadataOutput) {
			captureSession.addOutput(metadataOutput)
			
			metadataOutput.setMetadataObjectsDelegate(context.coordinator, queue: .main)
			metadataOutput.metadataObjectTypes = [.qr]
		} else {
			print("Could not add metadata output")
			return
		}
		
		let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
		previewLayer.frame = controller.view.bounds
		previewLayer.videoGravity = .resizeAspectFill
		controller.view.layer.addSublayer(previewLayer)
		
		
		let layer = CALayer()
		layer.backgroundColor = CGColor.init(srgbRed: 0.5, green: 0.5, blue: 0.5, alpha: 0)
		layer.borderWidth = 1
		layer.borderColor = .init(srgbRed: 1, green: 1, blue: 1, alpha: 1)
		context.coordinator.layer = layer
		previewLayer.addSublayer(layer)
		
		context.coordinator.previewLayer = previewLayer
		
		captureSession.startRunning()
	}
	
	func createAVInput(captureDevice: AVCaptureDevice?) -> AVCaptureInput? {
		guard let captureDevice = captureDevice else {
			print("Could not get default capture device")
			return nil
		}
		
		let avInput: AVCaptureDeviceInput
		
		do {
			avInput = try AVCaptureDeviceInput(device: captureDevice)
		} catch {
			print("Could not create AVCaptureDevice. \(error.localizedDescription)")
			return nil
		}
		
		return avInput
	}
	
}
