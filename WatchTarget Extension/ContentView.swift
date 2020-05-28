//
//  ContentView.swift
//  WatchTarget Extension
//
//  Created by Glenn Olsson on 2020-05-28.
//  Copyright © 2020 Glenn Olsson. All rights reserved.
//

import SwiftUI

struct ContentView: View {
	
	@State var name: String = ""
	@State var pass: String = ""
	
    var body: some View {
		VStack {
			TextField("Username", text: self.$name)
				.textContentType(.username)
		
			SecureField("Pass", text: self.$pass)
				.textContentType(.password)
			
			Text("Hello, \(name.count > 0 ? name : "world")! \(pass)")
		}
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
