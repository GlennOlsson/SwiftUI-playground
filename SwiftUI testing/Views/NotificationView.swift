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
	
	@Published var isVisible: Bool = false
	@Published var text: String = ""
	@Published var notificationType: NotificationType = .standard
	
	func showNotification(text: String, type: NotificationType) {
		DispatchQueue.main.async {
			self.text = text
			self.notificationType = type
			self.isVisible = true
		}
	}
	
	func hide() {
		self.isVisible = false
	}
}

struct NotificationStack<Content: View>: View {
	
	let content: () -> Content
	
//	@State var isVisible: Bool = false
//	@State var notificationText: String = ""
//	@State var notificationType: NotificationType = .standard
	
	var notificationContext: NotificationContext
	
	init(content: @escaping () -> Content) {
		self.content = content
		self.notificationContext = NotificationContext()
	}
	
//	func showNotification(text: String, type: NotificationType) {
//		self.notificationText = text
//		self.notificationType = type
//		self.isVisible = true
//	}
	
    var body: some View {
		print("Upadtr: \(notificationContext.isVisible)")
		return ZStack {
			NotificationView(context: notificationContext)
				.position(x: pixelsOf(precent: 50, inDimension: .horizontal), y: 0)
//				.background(self.notificationBackgrund)
				.zIndex(1)
			
			content().environmentObject(self.notificationContext)
		}
    }
}

struct NotificationView: View {
	
	@ObservedObject var context: NotificationContext
	
	private let offset_isVisible: CGFloat = UIApplication.shared.windows.first?.safeAreaInsets.top ?? 0
	private let offset_isInvisible: CGFloat = -100
	
	let height: CGFloat = 100
	
	@State var yValDiff: CGFloat = 0
	@State var opactity: Double = 1
	
	var type: NotificationType {
		self.context.notificationType
	}
	
	var text: String {
		self.context.text
	}
	
	var isVisible: Bool {
		self.context.isVisible
	}
	
	func hide() {
		self.yValDiff = 0
		self.context.hide()
	}
	
	var offset: CGFloat {
		if self.isVisible {
			return offset_isVisible + self.yValDiff
		} else {
			return offset_isInvisible + self.yValDiff
		}
	}
	
	var notificationBackgrund: Color {
		if self.type == .standard {
			return Color.blue
		} else {
			return Color.red
		}
	}
	
	var body: some View {
		HStack {
			Text(self.text)
				.padding()
		}.frame(width: pixelsOf(precent: 90, inDimension: .horizontal), height: self.height, alignment: .center)
		.background(self.notificationBackgrund)
			.animation(.none) //No animation for background color
		.cornerRadius(10)
		.offset(x: 0, y: self.offset)
		.animation(.spring())
			.opacity(self.opactity)
			.gesture(DragGesture()
			.onChanged({value in
				self.yValDiff = min(self.height * 0.4, value.translation.height)
			})
			.onEnded({value in
				//< .5 as we only want to be able to swipe up. -0.5 = 50% of the total height
				if value.translation.height / self.height < -0.5 {
					self.hide()
				} else {
					self.yValDiff = 0
				}
			}))
	}
}

struct NotificationView_Previews: PreviewProvider {
    static var previews: some View {
		NotificationStack {
			NotificationViewSubview()
		}
    }
}

private struct NotificationViewSubview: View {
	
	@EnvironmentObject var notificationContext: NotificationContext
	
	var body: some View {
		VStack {
			Text("Hello!")
			Button(action: {
				self.notificationContext.showNotification(text: "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Sapien nec sagittis aliquam malesuada bibendum arcu vitae. Egestas pretium aenean pharetra magna ac. Sit amet facilisis magna etiam tempor orci eu lobortis. Quisque egestas diam in arcu cursus. Bibendum neque egestas congue quisque egestas diam in arcu cursus. Faucibus pulvinar elementum integer enim. Feugiat in fermentum posuere urna. Et magnis dis parturient montes nascetur ridiculus mus mauris. Eu non diam phasellus vestibulum lorem sed. Tempus urna et pharetra pharetra massa massa ultri", type: .error)
			}, label: {
				Text("Click")
			})
		}
	}
}
