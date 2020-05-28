//
//  HostingController.swift
//  WatchTarget Extension
//
//  Created by Glenn Olsson on 2020-05-28.
//  Copyright © 2020 Glenn Olsson. All rights reserved.
//

import WatchKit
import Foundation
import SwiftUI
import CoreData

class HostingController: WKHostingController<AnyView> {
	
	private var context: NSManagedObjectContext!
	
	override func awake(withContext context: Any?) {
		let context = (WKExtension.shared().delegate as! ExtensionDelegate).persistentContainer.viewContext
		
		self.context = context
	}
	
    override var body: AnyView {
		let view = ContentView().environment(\.managedObjectContext, context)
		return AnyView(view)
    }
}
