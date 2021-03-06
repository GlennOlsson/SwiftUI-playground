//
//  NotificationView.swift
//  SwiftUI testing
//
//  Created by Glenn Olsson on 2020-05-23.
//  Copyright © 2020 Glenn Olsson. All rights reserved.
//

import SwiftUI

enum NotificationType {
	case standard, error
}

/**
Context used to publish notifications

- Tag: NotificationContext
*/
class NotificationContext: ObservableObject {
	
	@Published var notifications: [NotificationModel] = []
	
	/**
	Add notification with plain text. This will be wrapped in a Text label
	*/
	func addNotification(type: NotificationType, text: String) {
		let notification = NotificationModel(type: type, text: text)
		self.addNotification(notification: notification)
	}
	
	/**
	Add notification with custom content view
	*/
	func addNotification<Content: View>(type: NotificationType, @ViewBuilder content: @escaping (UUID) -> Content) {
		let notification = NotificationModel(type: type, content: content)
		self.addNotification(notification: notification)
	}
	
	func addNotification(notification: NotificationModel) {
		DispatchQueue.main.async {
			self.notifications.append(notification)
		}
	}
	
	func removeNotification(id: UUID) {
		notifications.removeAll(where: {$0.id == id})
	}
}

/**
Model a notification to be displayed
*/
struct NotificationModel {
	var type: NotificationType
	var id: UUID
	
	var content: () -> AnyView
	
	/**
	- Parameters:
	    - type : The notification type to be associated with the notification
	    - text: The text the notification will display
	*/
	init(type: NotificationType, text: String) {
		self.content = { AnyView(Text(text)) }
		self.type = type
		self.id = UUID()
	}
	
	/**
	- parameters:
	    - type : The notification type to be associated with the notification
	    - content: The closure will be called with the id of the notification
	*/
	init<Content: View>(type: NotificationType, @ViewBuilder content: @escaping (UUID) -> Content) {
		self.type = type
		let id = UUID()
		self.id = id
		self.content = { AnyView(content(id)) }
	}
}

/**
Wrapper for the views to be able to recieve notifications on. Embeds a NotificationContext in the environment for the underlying views to push notifications

The context can be extracted with this line in the subviews declaration

    @EnvironmentObject var notificationContext: NotificationContext

- See also: [NotificationContext](x-source-tag://NotificationContext)
*/
struct NotificationStack<Content: View>: View {
	
	let content: () -> Content

	@ObservedObject var notificationContext: NotificationContext
	
	init(content: @escaping () -> Content) {
		self.content = content
		self.notificationContext = NotificationContext()
	}
	
	func removeNotification(notification: NotificationModel) {
		notificationContext.removeNotification(id: notification.id)
	}
	
    var body: some View {
		return ZStack {
			ForEach(Array(notificationContext.notifications.enumerated()), id: \.1.id) { (index, notification) in
				NotificationView(notification: notification, onHide: self.removeNotification)
					.position(x: UIScreen.main.bounds.width * 0.5, y: 0)
						.zIndex(1)
			}
			
			content().environmentObject(self.notificationContext)
		}
    }
}

/**
The actual notification that is displayed
*/
private struct NotificationView: View {
	
	private let offset_isVisible: CGFloat = UIApplication.shared.windows.first?.safeAreaInsets.top ?? 0
	private let offset_isInvisible: CGFloat = -100
	
	let height: CGFloat = 100
	
	@State var yValDiff: CGFloat = 0
	@State var opactity: Double = 1
	
	let notification: NotificationModel
	
	var type: NotificationType {
		notification.type
	}
	
	var content: AnyView {
		notification.content()
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
			content
				.padding()
		}
		.frame(width: UIScreen.main.bounds.width * 0.9, height: self.height, alignment: .center)
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
				self.notificationContext.addNotification(type: .error, text: "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Sapien nec sagittis aliquam malesuada bibendum arcu vitae. Egestas pretium aenean pharetra magna ac. Sit amet facilisis magna etiam tempor orci eu lobortis. Quisque egestas diam in arcu cursus. Bibendum neque egestas congue quisque egestas diam in arcu cursus. Faucibus pulvinar elementum integer enim. Feugiat in fermentum posuere urna. Et magnis dis parturient montes nascetur ridiculus mus mauris. Eu non diam phasellus vestibulum lorem sed. Tempus urna et pharetra pharetra massa massa ultri")
			}, label: {
				Text("Click")
			})
		}
	}
}
