//
//  UserDefaultWrapper.swift
//  SwiftUI testing
//
//  Created by Glenn Olsson on 2020-05-24.
//  Copyright © 2020 Glenn Olsson. All rights reserved.
//

import SwiftUI
import Combine

@propertyWrapper
class UserDefault<T>: ObservableObject {
	let key: String
	let defaultValue: T
	
	let defaults: UserDefaults
	
	@Published var wrappedValue: T 
	
	var subscriber: AnyCancellable?
	
	init(wrappedValue: T, key: String) {
		self.defaults = .standard
		
		self.key = key
		self.defaultValue = wrappedValue
		self.wrappedValue = self.defaults.object(forKey: key) as? T ?? wrappedValue
		self.subscriber = NotificationCenter.default.publisher(for: UserDefaults.didChangeNotification).map({_ in
			let currentDefaultForKey = self.defaults.object(forKey: self.key)
			let asT = currentDefaultForKey as? T
			print("isT? \(asT != nil)")
			return asT ?? self.defaultValue
		})
			.eraseToAnyPublisher()
			.receive(on: DispatchQueue.main)
			.assign(to: \UserDefault.wrappedValue, on: self)
	}
}
