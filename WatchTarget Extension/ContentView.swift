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
					ListItem(person: person)
				}
			}
			if self.listOfPeople.count == 0 {
				Text("No objects")
			}
		}
    }
}

private struct ListItem: View {
	
	@ObservedObject var person: Person
	var body: some View {
		HStack {
			Toggle(isOn: self.$person.isSelected, label: { EmptyView() })
				.toggleStyle(CheckboxStyle())
				.padding(.trailing)
			
			Text(self.person.name ?? "Inget namn")
		}.onTapGesture {
			self.person.isSelected.toggle()
		}
	}
}

private struct CheckboxStyle: ToggleStyle {
	func makeBody(configuration: Configuration) -> some View {
		//		Button(action: {configuration.isOn.toggle()}) {
		VStack {
			if configuration.isOn {
				Image(systemName: "checkmark").foregroundColor(.white)
					.transition(.scale)
					.scaleEffect(2)
			} else {
				Image(systemName: "checkmark").hidden()
			}
		}.frame(width: 30, height: 30, alignment: .center)
			.background(Color(red: 0xe8/256, green: 0x3d/256, blue: 0x84/256))
			.onTapGesture {
				withAnimation(Animation.linear(duration: 0.1)) {
					configuration.isOn.toggle()
				}
		}
	}
	//	}
	
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
		let context = (WKExtension.shared().delegate as! ExtensionDelegate).persistentContainer.viewContext

		insertPeople(moc: context)
		
        return ContentView().environment(\.managedObjectContext, context)
    }
}


let peopleWithTickets: [[String: Any]] = [
	[
		"name": "Glenn Olsson",
		"id": "glennol",
		"isSelected": false
	], [
		"name": "Fredrik",
		"id": "frnorlin",
		"isSelected": false
	], [
		"name": "Linus",
		"id": "linusri",
		"isSelected": false
	], [
		"name": "Oscar",
		"id": "oscarekh",
		"isSelected": false
	],[
		"name": "Dexter Callahan",
		"id": "dextercallahan",
		"isSelected": false
	],[
		"name": "Opal Salter",
		"id": "opalsalter",
		"isSelected": false
	],[
		"name": "Mehmet Bernard",
		"id": "mehmetbernard",
		"isSelected": false
	],[
		"name": "Alexandre Khan",
		"id": "alexandrekhan",
		"isSelected": false
	],[
		"name": "Domonic Rivers",
		"id": "domonicrivers",
		"isSelected": false
	],[
		"name": "Leela Bradley",
		"id": "leelabradley",
		"isSelected": false
	],[
		"name": "Aston Mcdonald",
		"id": "astonmcdonald",
		"isSelected": false
	],[
		"name": "Atif Ponce",
		"id": "atifponce",
		"isSelected": false
	],[
		"name": "Bobbi Jacobson",
		"id": "bobbijacobson",
		"isSelected": false
	],[
		"name": "Marvin Holden",
		"id": "marvinholden",
		"isSelected": false
	]
]


func insertPeople(moc: NSManagedObjectContext) {
	do {
		
		let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Person")
		
		let results = try moc.fetch(fetchRequest) as! [NSManagedObject]
		
		for result in results {
			moc.delete(result)
		}
		
		for person in peopleWithTickets {
			let personEntity = Person(context: moc)
			personEntity.name = person["name"] as? String
			personEntity.id = person["id"] as? String
			personEntity.isSelected = person["isSelected"] as! Bool
		}
		
		try moc.save()
		
	} catch {
		print("Error! \(error)")
	}
}
