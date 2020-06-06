//
//  Constants.swift
//  SwiftUI testing
//
//  Created by Glenn Olsson on 2020-05-28.
//  Copyright © 2020 Glenn Olsson. All rights reserved.
//

import CoreData
import Foundation
import Combine

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

var c: AnyCancellable?

func insertPersonSlow(moc: NSManagedObjectContext) {
	
	let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Person")
	fetchRequest.predicate = NSPredicate(format: "id == 'glennolle'")
	
	let results = try! moc.fetch(fetchRequest) as! [Person]

	var isSelected = false
	for person in results {
		isSelected = person.isSelected
		print("Prevois was \(isSelected ? "selected" : "not selected")")
		moc.delete(person)
	}
	
	DispatchQueue.global().asyncAfter(deadline: .now() + 10, execute: {
		let newPerson = Person(context: moc)
		newPerson.name = "Glenne Olssesson"
		newPerson.id = "glennolle"
		newPerson.isSelected = isSelected
		
		c = newPerson.publisher(for: \.isSelected).didChange().sink(receiveValue: {
			print("DID CHANGE CHANGED TO \(newPerson.isSelected ? "true": "false")")
		})
		
		try? moc.save()
		print("Saved")
	})
}
