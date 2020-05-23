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
		Button(action: {
			self.notificationContext.showNotification(text: "Hello, bruh", type: .standard)
		}) {
			Text("Click")
		}
	}
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
