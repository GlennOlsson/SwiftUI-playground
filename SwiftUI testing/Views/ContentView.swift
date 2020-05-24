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
				self.notificationContext.addNotification(type: .standard, text: "Hello, bruh")
			}) {
				Text("Click")
			}

			Button(action: {
				self.notificationContext.addNotification(type: .error) {_ in
					HStack {
						Button(action: {
							print("klick!")
						}, label: {
							Text("Hello")
						})
						Text("Hello")
						Text("Bajs")
					}
				}
			}) {
				Text("Click2")
			}
		}
		
	}
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
