//
//  ContentView.swift
//  WatchTarget Extension
//
//  Created by Glenn Olsson on 2020-05-28.
//  Copyright © 2020 Glenn Olsson. All rights reserved.
//

import SwiftUI
import CoreData

struct ContentView: View {
	
	@FetchRequest(entity: Person.entity(), sortDescriptors: [NSSortDescriptor(key: "name", ascending: true)]) var listOfPeople: FetchedResults<Person>
	
    var body: some View {
		
		VStack {
			List {
				ForEach(self.listOfPeople, id: \.id) { person in
					Text("\(person.name ?? "inget namn") is active? \((person.isSelected ? "true" : "false") ?? "uncertain")")
				}
			}
			if self.listOfPeople.count == 0 {
				Text("No objects")
			}
		}
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
