//
//  ContentView.swift
//  SwiftUI testing
//
//  Created by Glenn Olsson on 2020-05-23.
//  Copyright © 2020 Glenn Olsson. All rights reserved.
//

import SwiftUI
import Combine

struct ContentView: View {
	var body: some View {
		NotificationStack {
			SubView()
		}
	}
}

struct SubView: View {
	
	let defaults: UserDefaults = .standard
	
	@EnvironmentObject var notificationContext: NotificationContext
	
	@ObservedObject @UserDefault(key: "unit") var unitIsMeter = "meter";
	
	var body: some View {
		NavigationView {
			VStack {
				NavigationLink(destination: SettingsView()) {
					Text("Settings")
				}
					
				HStack(alignment: .center, spacing: 0) {
					Text("100 ")
					Text(self.unitIsMeter)
				}
			}
		}
	}
}

struct ContentView_Previews: PreviewProvider {
	static var previews: some View {
		ContentView()
	}
}
