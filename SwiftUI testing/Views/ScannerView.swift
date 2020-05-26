//
//  ScannerView.swift
//  SwiftUI testing
//
//  Created by Glenn Olsson on 2020-05-26.
//  Copyright © 2020 Glenn Olsson. All rights reserved.
//

import Foundation
import SwiftUI
import AVFoundation
import UIKit

struct ScannerView: UIViewControllerRepresentable {
	
	@State var view: UIView!
	
	class Coordinator: NSObject, AVCaptureMetadataOutputObjectsDelegate {
		
		let parent: ScannerView
		var parentView: UIView?
		
		var label: UILabel!
		var rect: UIView!
		
		init(_ parent: ScannerView) {
			self.parent = parent
			self.parentView = nil
			
			label = UILabel()
			rect = UIView()
			rect.backgroundColor = .black
			
			if let window = UIApplication.shared.windows.first {
				window.addSubview(label)
				window.addSubview(rect)
			}
		}
		
		func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
			if let metadata = metadataObjects.first {
				
//				parentView!.addSubview(label)
				
//				if let window = UIApplication.shared.windows.first {
//					window.addSubview(label)
//				} else {
//					print("No window??")
//				}
				print("x: \(metadata.bounds.origin.x), y: \(metadata.bounds.origin.y), width: \(metadata.bounds.width), height: \(metadata.bounds.height)")
				
				let window =  UIApplication.shared.windows.first!
				let windowWidth = parentView!.bounds.width
				let windowHeight = parentView!.bounds.height
				
				let metaBounds = metadata.bounds.origin
				let metaX = metaBounds.x * windowWidth
				let metaY = metaBounds.y * windowHeight
				
				if let readableObject = metadata as? AVMetadataMachineReadableCodeObject {
					guard let stringValue = readableObject.stringValue else { return }
					print("Found code! \(stringValue)")
//					let label = UILabel()
					
					self.rect.bounds = CGRect(x: metaY, y: metaX, width: 100, height: 100)
						
					label.text = stringValue
					//				label.bounds = metadata.bounds
					label.frame = CGRect(x: metaY, y: metaX, width: 500, height: 100)
//					parentView?.addSubview(label)
					print(metadata.accessibilityFrame, metadata.accessibilityActivationPoint)
				} else if let catObject = metadata as? AVMetadataCatBodyObject {
					
				}
			}
		}
		
	}
	
	func makeCoordinator() -> Coordinator {
		return Coordinator(self)
	}
	
	func makeUIViewController(context: Context) -> UIViewController {
		let viewController = UIViewController()
		
		self.view = viewController.view
		
		let captureSession = AVCaptureSession()
		guard let captureDevice = AVCaptureDevice.default(for: .video) else {
			print("Could not get default capture device")
			return viewController
		}
		
		let avInput: AVCaptureDeviceInput
		
		do {
			avInput = try AVCaptureDeviceInput(device: captureDevice)
		} catch {
			print("Could not create AVCaptureDevice. \(error.localizedDescription)")
			return viewController
		}
		
		if (captureSession.canAddInput(avInput)) {
			captureSession.addInput(avInput)
		} else {
			print("Could not add input")
			return viewController
		}
		
		let metadataOutput = AVCaptureMetadataOutput()
		
		if captureSession.canAddOutput(metadataOutput) {
			captureSession.addOutput(metadataOutput)
			
			metadataOutput.setMetadataObjectsDelegate(context.coordinator, queue: .main)
			metadataOutput.metadataObjectTypes = [.qr, .catBody]
		} else {
			print("Could not add metadata output")
			return viewController
		}
		
		context.coordinator.parentView = viewController.view
		
		let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
		previewLayer.frame = viewController.view.bounds
		previewLayer.videoGravity = .resizeAspectFill
		viewController.view.layer.addSublayer(previewLayer)
		
		captureSession.startRunning()
		
		return viewController
	}
	
	func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
		
	}

}
