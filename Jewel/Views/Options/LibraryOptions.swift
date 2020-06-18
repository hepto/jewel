//
//  LibraryOptions.swift
//  Listen Later
//
//  Created by Greg Hepworth on 18/06/2020.
//  Copyright © 2020 Breakbeat Ltd. All rights reserved.
//

import SwiftUI

struct LibraryOptions: View {
  
  @EnvironmentObject private var app: AppEnvironment
  
  private var preferredMusicPlatform: Binding<Int> { Binding (
    get: { self.app.state.options.preferredMusicPlatform },
    set: { self.app.update(action: OptionsAction.setPreferredPlatform(platform: $0)) }
    )
  }
  
  var body: some View {
    NavigationView {
      VStack {
        Form {
          
          Section {
            Button(action: {
              self.app.navigation.libraryIsEditing = true
              self.app.navigation.showLibraryOptions = false
            }) {
              HStack {
                Image(systemName: "square.stack.3d.up")
                  .frame(width: Constants.optionsButtonIconWidth)
                Text("Reorder Library")
              }
            }
            .disabled(app.state.library.collections.isEmpty)
            RecommendationsButton()
          }
          
          Section(header: Text("APP OPTIONS"), footer: Text("Use this service for playback if available, otherwise use Apple Music.")) {
            Picker(selection: preferredMusicPlatform, label: Text("Playback Service")) {
              ForEach(0 ..< OdesliPlatform.allCases.count, id: \.self) {
                Text(OdesliPlatform.allCases[$0].friendlyName)
              }
            }
          }
          if app.state.options.debugMode {
            Button(action: {
              self.app.update(action: OptionsAction.reset)
            }) {
              Text("Reset Jewel")
                .foregroundColor(.red)
            }
          }
        }
        Spacer()
        Footer()
          .onTapGesture(count: 10) {
            self.app.update(action: OptionsAction.toggleDebugMode)
        }
        .padding()
      }
      .navigationBarTitle("Library Options", displayMode: .inline)
      .navigationBarItems(trailing:
        Button(action: {
          self.app.navigation.showLibraryOptions = false
        }) {
          Text("Close")
        }
      )
    }
    .navigationViewStyle(StackNavigationViewStyle())
  }
}
