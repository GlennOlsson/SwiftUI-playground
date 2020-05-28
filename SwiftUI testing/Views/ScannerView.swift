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
		
		var layer: CALayer?
		
		var lastObject: AVMetadataObject.ObjectType? = nil
		
		var captureSession: AVCaptureSession?
		var input: AVCaptureInput?
		
		var previewLayer: AVCaptureVideoPreviewLayer?
		
		init(_ parent: ScannerView) {
			self.parent = parent
			self.parentView = nil
			
			label = UILabel()
			rect = UIView()
			rect.backgroundColor = .black
			
			if let window = UIApplication.shared.windows.first {
//				window.addSubview(label)
//								window.addSubview(rect)
			}
		}
		
		
		
		func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
			print(metadataObjects.count)
			if metadataObjects.count == 0 {
				self.layer?.isHidden = true
				self.lastObject = nil
			} else {
				self.layer?.isHidden = false
			}
			if let metadata = metadataObjects.first {
				
				//				parentView!.addSubview(label)
				
				//				if let window = UIApplication.shared.windows.first {
				//					window.addSubview(label)
				//				} else {
				//					print("No window??")
				//				}
//				print("x: \(metadata.bounds.origin.x), y: \(metadata.bounds.origin.y), width: \(metadata.bounds.width), height: \(metadata.bounds.height)")
				
				if metadata.type != lastObject {
					UIImpactFeedbackGenerator(style: .light).impactOccurred()
					lastObject = metadata.type
				}
				
				let window =  UIApplication.shared.windows.first!
				let windowWidth = parentView!.bounds.width
				let windowHeight = parentView!.bounds.height
				
				let metaBounds = metadata.bounds.origin
				let metaX = metaBounds.x * windowWidth
				let metaY = metaBounds.y * windowHeight
				
				label.frame = CGRect(x: metaY, y: metaX, width: 500, height: 100)

				let bounds2 = self.previewLayer?.transformedMetadataObject(for: metadata)?.bounds
				self.layer!.frame = CGRect(x: bounds2!.origin.x, y: bounds2!.origin.y, width: bounds2!.width, height: bounds2!.height)
				if let readableObject = metadata as? AVMetadataMachineReadableCodeObject {
//					print("rect1: \(readableObject.bounds.origin), rect2: \(metadata.bounds.origin), rect3: \(bounds2)")
					
					guard let stringValue = readableObject.stringValue else { return }
//					print("Found code! \(stringValue)")
					//					let label = UILabel()
					
//					self.rect.frame = CGRect(x: bounds2!.origin.x, y: bounds2!.origin.y, width: bounds2!.width, height: bounds2!.height)
					self.rect.bounds = bounds2!
//					label.frame = CGRect(x: bounds2!.origin.x, y: bounds2!.origin.y, width: 500, height: 100)
//					label.text = stringValue
					
					//				label.bounds = metadata.bounds
					//					parentView?.addSubview(label)
//					print(metadata.accessibilityFrame, metadata.accessibilityActivationPoint)
				} else if let catObject = metadata as? AVMetadataCatBodyObject {
					label.text = "Katt!!"
				} else if let face = metadata as? AVMetadataFaceObject {
					label.text = "Människa nr. \(face.faceID)"
//					print("ID: \(face.faceID), jawnAngle: \(face.rollAngle)")
				} else if let body = metadata as? AVMetadataHumanBodyObject {
					label.text = "Människokropp"
				}
			}
		}
		
	}
	
	@Binding var isFrontCamera: Bool
	
	func makeCoordinator() -> Coordinator {
		return Coordinator(self)
	}
	
	func makeUIViewController(context: Context) -> UIViewController {
		let viewController = UIViewController()
		self.view = viewController.view
		
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
		
		captureSession.startRunning()
		
		//		self.createNewScannerLayer(controller: uiViewController, context: context, captureDevice: getCamera(isFront: self.isFrontCamera))
	}
	
	private func getCamera(isFront: Bool) -> AVCaptureDevice? {
		if isFront {
			return AVCaptureDevice.default(.builtInTrueDepthCamera, for: .video, position: .front)
		} else {
			return AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back)
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
			metadataOutput.metadataObjectTypes = [.qr, .catBody, .face, .humanBody]
		} else {
			print("Could not add metadata output")
			return
		}
		
		context.coordinator.parentView = controller.view
		
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
