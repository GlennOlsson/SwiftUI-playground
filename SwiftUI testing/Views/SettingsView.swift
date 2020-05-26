//
//  SettingsView.swift
//  SwiftUI testing
//
//  Created by Glenn Olsson on 2020-05-24.
//  Copyright © 2020 Glenn Olsson. All rights reserved.
//

import SwiftUI
import Foundation

struct SettingsView: View {
	
	let defaults: UserDefaults
	
	@State var unitIsMeter: Bool = true
	
	init() {
		self.defaults = .standard
		print("is \(self.defaults.bool(forKey: "unit"))")
	}
	
    var body: some View {
		VStack {
			Text("Hello")
			Toggle(isOn: self.$unitIsMeter) {
				Text("Unit in meters")
			}
			.padding()
		}.onAppear() {
			self.unitIsMeter = self.defaults.bool(forKey: "unit")
		}.onDisappear() {
			self.defaults.set(self.unitIsMeter, forKey: "unit")
			print("Set to \(self.unitIsMeter)")
		}
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
