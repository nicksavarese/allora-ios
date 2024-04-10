//
//  ContentView.swift
//  Allora
//
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            Text("Allora - An LLM Keyboard via API Request")
            Text("✨ by Nick Savarese\n")
            Text("Enable in Settings>General>Keyboard, then select 'Add new keyboard' and add Allora.")
            Text("\n\nOnce done, you can use the keyboard in any text input field.\n\n")
            Image(systemName: "globe")
            .imageScale(.large)
            .foregroundColor(.accentColor)
            Text("\n\nWhen the keyboard is in view, press the globe icon to switch between keyboards.")


        }
        .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
