//
//  NotificationView.swift
//  SwiftUI testing
//
//  Created by Glenn Olsson on 2020-05-23.
//  Copyright © 2020 Glenn Olsson. All rights reserved.
//

import SwiftUI

public enum DIMENSION {
	case vertical, horizontal
}

func pixelsOf(precent: CGFloat, inDimension: DIMENSION) -> CGFloat{
	let bounds = UIScreen.main.bounds
	switch inDimension {
	case .vertical:
		return CGFloat(precent / CGFloat(100)) * bounds.height
	case .horizontal:
		return CGFloat(precent / CGFloat(100)) * bounds.width
	}
}

enum NotificationType {
	case standard, error
}

class NotificationContext: ObservableObject {
	
	@Published var isVisible: Bool = false {
		willSet {
			print("Set")
			objectWillChange.send()
		}
	}
	@Published var notificationText: String = ""
	@Published var notificationType: NotificationType = .standard
	
	func showNotification(text: String, type: NotificationType) {
		print("SHOW")
		DispatchQueue.main.async {
			self.notificationText = text
			self.notificationType = type
			self.isVisible = true
		}
	}
}

struct NotificationStack<Content: View>: View {
	
	let content: () -> Content
	
//	@State var isVisible: Bool = false
//	@State var notificationText: String = ""
//	@State var notificationType: NotificationType = .standard
	
	@EnvironmentObject var notificationContext: NotificationContext
	
	init(content: @escaping () -> Content) {
		self.content = content
	}
	
//	func showNotification(text: String, type: NotificationType) {
//		self.notificationText = text
//		self.notificationType = type
//		self.isVisible = true
//	}
	
    var body: some View {
		print("Upadtr: \(notificationContext.isVisible)")
		return ZStack {
			NotificationView(type: notificationContext.notificationType, text: notificationContext.notificationText, isVisible: notificationContext.isVisible)
				.position(x: pixelsOf(precent: 50, inDimension: .horizontal), y: -100)
//				.background(self.notificationBackgrund)
				.zIndex(1)
			
			content()
		}
    }
}

struct NotificationView: View {
	
	let type: NotificationType
	let text: String
	let isVisible: Bool
	
	var notificationBackgrund: Color {
		if self.type == .standard {
			return Color.blue
		} else {
			return Color.red
		}
	}
	
	var offset: CGFloat {
		if self.isVisible {
			print("IS VISIBLE")
			return 100
		} else {
			return 0
		}
	}
	
	var body: some View {
		HStack {
			Text(self.text)
		}.frame(width: pixelsOf(precent: 80, inDimension: .horizontal), height: 100, alignment: .center)
		.cornerRadius(10)
		.background(self.notificationBackgrund)
			.offset(x: 0, y: self.offset)
	}
}

struct NotificationView_Previews: PreviewProvider {
    static var previews: some View {
		NotificationStack {
			VStack {
				Text("Hello!")
				Button(action: {
					print("Hello")
				}, label: {
					Text("Click")
				})
			}
		}
    }
}
