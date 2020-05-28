//
//  ChecklistView.swift
//  SwiftUI testing
//
//  Created by Glenn Olsson on 2020-05-27.
//  Copyright © 2020 Glenn Olsson. All rights reserved.
//

import Foundation
import SwiftUI

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

class Person: ObservableObject{
	let name: String
	let id: String
	@Published var isSelected: Bool
	
	init(_ dictionary: [String: Any]) {
		self.name = dictionary["name"] as! String
		self.id = dictionary["id"] as! String
		self.isSelected = dictionary["isSelected"] as! Bool
	}
}

struct ChecklistView: View {
	
	let listOfPeople: [Person]
	
	@State var showQRCodeReader: Bool = false
	@State var isFrontCamera: Bool = false
	
	@State var isShowingAlert: Bool = false
	@State var currentAlert: Alert!
	
	init() {
		listOfPeople = peopleWithTickets.map({Person($0)})
	}
	
	func onScan(_ codeContent: String) {
		
		let generator = UINotificationFeedbackGenerator()
		var foundPerson = false
		for person in listOfPeople {
			if person.id == codeContent {
				person.isSelected = true
				foundPerson = true
				generator.notificationOccurred(.success)
			}
		}
		if !foundPerson {
			generator.notificationOccurred(.warning)
			DispatchQueue.main.async {
				self.currentAlert = Alert(title: Text("Person with id \(codeContent) does not have a ticket!"))
				self.isShowingAlert = true
			}
			print("Show")
		}
	}
	
	var body: some View {
		VStack {
			if showQRCodeReader {
				QRCodeReader(isFrontCamera: self.$isFrontCamera,  isShowing: self.$showQRCodeReader, onScan: self.onScan(_:))
				
			}
			
			List {
				ForEach(listOfPeople, id: \.id) { person in
					ListItem(person: person)
				}
			}
			
		}.alert(isPresented: self.$isShowingAlert, content: {
			self.currentAlert
		})
		.navigationBarItems(trailing:	Button(action: {
			self.showQRCodeReader.toggle()
		}, label: {
			Text("Toggle reader")
		}))
	}
}

private struct ListItem: View {
	
	@ObservedObject var person: Person
	var body: some View {
		HStack {
			Toggle(isOn: self.$person.isSelected, label: { EmptyView() })
				.toggleStyle(CheckboxStyle())
				.padding(.trailing)
			
			Text(self.person.name)
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
		}.frame(width: 50, height: 50, alignment: .center)
			.background(Color(red: 0xe8/256, green: 0x3d/256, blue: 0x84/256))
			.onTapGesture {
				withAnimation(Animation.linear(duration: 0.1)) {
					configuration.isOn.toggle()
				}
		}
	}
	//	}
	
}

struct ChecklistView_Previews: PreviewProvider {
	static var previews: some View {
		ChecklistView()
	}
}
