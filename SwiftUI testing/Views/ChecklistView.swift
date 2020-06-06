//
//  ChecklistView.swift
//  SwiftUI testing
//
//  Created by Glenn Olsson on 2020-05-27.
//  Copyright © 2020 Glenn Olsson. All rights reserved.
//

import Foundation
import SwiftUI
import Combine
import CoreData

//
//class Person: ObservableObject{
//	let name: String
//	let id: String
//	@Published var isSelected: Bool
//	
//	init(_ dictionary: [String: Any]) {
//		self.name = dictionary["name"] as! String
//		self.id = dictionary["id"] as! String
//		self.isSelected = dictionary["isSelected"] as! Bool
//	}
//}

class ListOfPeopleSubscriber: Subscriber, ObservableObject {
	typealias Input = [FetchedResults<Person>.Element]
	typealias Failure = Never
	
	@Published var listOfPeople: [Person] = []
	
	func handleData() {
		
	}
	
	func receive(subscription: Subscription) {
		print("Recieved")
	}
	
	func receive(_ input: [FetchedResults<Person>.Element]) -> Subscribers.Demand {
		print("")
		return .unlimited
	}
	
	func receive(completion: Subscribers.Completion<Never>) {
		
	}
}

struct ChecklistView: View {
	
	@FetchRequest(entity: Person.entity(), sortDescriptors: [NSSortDescriptor(key: "name", ascending: true)]) var listOfPeople: FetchedResults<Person>
	
	@State var showQRCodeReader: Bool = false
	@State var isFrontCamera: Bool = false
	
	@State var isShowingAlert: Bool = false
	@State var currentAlert: Alert!
	
	@State var shownList: [Person] = []
	
	@Environment(\.managedObjectContext) var context
	
	@State var notificationSubscription: AnyCancellable?
	
	func executeRequest() {
		let request: NSFetchRequest<Person> = Person.fetchRequest()
		do {
			print("exectute fetch request")
			
			self.shownList = try context.fetch(request)
			
		} catch {
			print("Error with fetch request: \(error)")
		}
	}
	
	func subscribeToRequest() {
		self.notificationSubscription = NotificationCenter.default
			.publisher(for: .NSManagedObjectContextDidSave, object: context)
			.sink(receiveValue: { notification in
				print("Was saved")
				self.executeRequest()
//				_ = self.listOfPeople.publisher.collect().removeDuplicates()
//					.sink(receiveValue: { list in
//					print("GOT LIST OF \(list.count) people")
//					self.shownList = list
//				})
			})
		
		
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
				ForEach(shownList, id: \.id) { person in
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
		.onAppear() {
			self.executeRequest()
			self.subscribeToRequest()
		}.onDisappear() {
			self.notificationSubscription?.cancel()
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
		let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
		insertPeople(moc: context)

		return ChecklistView().environment(\.managedObjectContext, context)
	}
}
