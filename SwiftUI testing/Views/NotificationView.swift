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
	
	@Published var notifications: [NotificationModel] = []
	
	func addNotification(text: String, type: NotificationType) {
			let notification = NotificationModel(text: text, type: type)
		DispatchQueue.main.async {
			self.notifications.append(notification)
		}
	}
}

class NotificationModel {
	var type: NotificationType
	var text: String
	var id: UUID
	
	init(text: String, type: NotificationType) {
		self.text = text
		self.type = type
		self.id = UUID()
	}
	
}

struct NotificationStack<Content: View>: View {
	
	let content: () -> Content

	@ObservedObject var notificationContext: NotificationContext
	
	init(content: @escaping () -> Content) {
		self.content = content
		self.notificationContext = NotificationContext()
	}
	
	func removeNotification(notification: NotificationModel) {
		notificationContext.notifications.removeAll(where: {$0.id == notification.id})
	}
	
    var body: some View {
		return ZStack {
			ForEach(Array(notificationContext.notifications.enumerated()), id: \.1.id) { (index, notification) in
				NotificationView(notification: notification, onHide: self.removeNotification)
						.position(x: pixelsOf(precent: 50, inDimension: .horizontal), y: 0)
						.zIndex(1)
			}
			
			content().environmentObject(self.notificationContext)
		}
    }
}

struct NotificationView: View {
	
	private let offset_isVisible: CGFloat = UIApplication.shared.windows.first?.safeAreaInsets.top ?? 0
	private let offset_isInvisible: CGFloat = -100
	
	let height: CGFloat = 100
	
	@State var yValDiff: CGFloat = 0
	@State var opactity: Double = 1
	
	let notification: NotificationModel
	
	var type: NotificationType {
		notification.type
	}
	
	var text: String {
		notification.text
	}
	
	@State var isVisible: Bool = false
	
	let onHide: (NotificationModel) -> Void
	
	func hide() {
		let animationTime: Double = 2
		withAnimation(.linear(duration: animationTime)){
			self.isVisible = false
			self.yValDiff = 0
		}
		
		//After animation is done, remove notification from rendering
		DispatchQueue.main.asyncAfter(deadline: .now() + animationTime) {
			self.onHide(self.notification)
		}
	}
	
	init(notification: NotificationModel, onHide: @escaping (NotificationModel) -> Void) {
		self.notification = notification
		self.onHide = onHide
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
		.shadow(radius: 5)
		.animation(.spring())
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
		.onAppear() {
			self.isVisible = true
		}
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
				self.notificationContext.addNotification(text: "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Sapien nec sagittis aliquam malesuada bibendum arcu vitae. Egestas pretium aenean pharetra magna ac. Sit amet facilisis magna etiam tempor orci eu lobortis. Quisque egestas diam in arcu cursus. Bibendum neque egestas congue quisque egestas diam in arcu cursus. Faucibus pulvinar elementum integer enim. Feugiat in fermentum posuere urna. Et magnis dis parturient montes nascetur ridiculus mus mauris. Eu non diam phasellus vestibulum lorem sed. Tempus urna et pharetra pharetra massa massa ultri", type: .error)
			}, label: {
				Text("Click")
			})
		}
	}
}
