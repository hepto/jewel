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
  
  var body: some View {
    NavigationView {
      Form {
        Section {
          Button(action: {
            self.app.navigation.libraryIsEditing = true
            self.app.navigation.showOptions = false
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
      }
      .navigationBarTitle("Library Options", displayMode: .inline)
      .navigationBarItems(
        leading:
        SettingsButton()
          .environmentObject(self.app),
        trailing:
        Button(action: {
          self.app.navigation.showOptions = false
        }) {
          Text("Close")
        }
      )
    }
    .navigationViewStyle(StackNavigationViewStyle())
  }
}
