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
				
				NavigationLink(destination: ScannerParentView()) {
					Text("Scanner")
				}.padding()
				
				HStack(alignment: .center, spacing: 0) {
					Text("100 ")
					Text(self.unitIsMeter)
				}
			}
		}
	}
}

struct ScannerParentView: View {
	@State var isFronCamera: Bool = true
	
	var body: some View {
		ZStack {
			ScannerView(isFrontCamera: self.$isFronCamera)
			
		}.navigationBarItems(trailing:
			Button("Toggle camera") {
				self.isFronCamera.toggle()
		})
	}
}

struct ContentView_Previews: PreviewProvider {
	static var previews: some View {
		ContentView()
	}
}
