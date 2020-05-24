//
//  ContentView.swift
//  SwiftUI testing
//
//  Created by Glenn Olsson on 2020-05-23.
//  Copyright © 2020 Glenn Olsson. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
		NotificationStack {
			SubView()
		}
    }
}

struct SubView: View {
	
	@EnvironmentObject var notificationContext: NotificationContext
	
	var body: some View {
		VStack {
			Button(action: {
				self.notificationContext.addNotification(text: "Hello, bruh", type: .standard)
			}) {
				Text("Click")
			}

			Button(action: {
				self.notificationContext.addNotification(type: .error) {
					AnyView (
						HStack {
							Button(action: {
								print("klick!")
							}, label: {
								Text("Hello")
							})
							Text("Hello")
							Text("Bajs")
							c
						}
					)
				}
			}) {
				Text("Click")
			}
		}
		
	}
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
