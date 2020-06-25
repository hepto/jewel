//
//  Options.swift
//  Jewel
//
//  Created by Greg Hepworth on 31/05/2020.
//  Copyright © 2020 Breakbeat Ltd. All rights reserved.
//

import SwiftUI

struct CollectionOptions: View {
  
  @EnvironmentObject private var app: AppEnvironment
  
  let collectionId: UUID
  
  private var isOnRotation: Bool {
    self.collectionId == self.app.state.library.onRotation.id
  }
  private var collection: Collection {
    if self.collectionId == self.app.state.library.onRotation.id {
      return self.app.state.library.onRotation
    } else {
      return self.app.state.library.collections.first(where: { $0.id == self.collectionId })!
    }
  }
  private var collectionEmpty: Bool {
    collection.slots.filter( { $0.source != nil }).count == 0
  }
  private var collectionName: Binding<String> { Binding (
    get: { self.collection.name },
    set: { self.app.update(action: LibraryAction.setCollectionName(name: $0, collectionId: self.collectionId))}
    )}
  private var collectionCurator: Binding<String> { Binding (
    get: { self.collection.curator },
    set: { self.app.update(action: LibraryAction.setCollectionCurator(curator: $0, collectionId: self.collectionId))}
    )}
  
  var body: some View {
    NavigationView {
      Form {
        Section {
          ShareCollectionButton(collection: collection)
          if collection.id == app.state.library.onRotation.id {
            Button(action: {
              self.app.navigation.selectedTab = .library
              self.app.navigation.showHomeOptions = false
              self.app.update(action: LibraryAction.saveOnRotation(collection: self.app.state.library.onRotation))
            }) {
              HStack {
                Image(systemName: "arrow.right.square")
                  .frame(width: Constants.optionsButtonIconWidth)
                Text("Add to my Collection Library")
              }
            }
          }
          if collection.type == .userCollection {
            Button(action: {
              self.app.navigation.listIsEditing = true
              self.app.navigation.showHomeOptions = false
            }) {
              HStack {
                Image(systemName: "square.stack.3d.up")
                  .frame(width: Constants.optionsButtonIconWidth)
                Text("Reorder \(isOnRotation ? "On Rotation" : "Collection")")
              }
            }
          }
        }
        .disabled(self.collectionEmpty)
        
        Section {
          HStack {
            Text("Collection Name")
            TextField(
              collectionName.wrappedValue,
              text: collectionName,
              onCommit: {
                self.app.navigation.showHomeOptions = false
            }
            ).foregroundColor(.accentColor)
          }
          .disabled(isOnRotation)
          HStack {
            Text("Curator")
            TextField(
              collectionCurator.wrappedValue,
              text: collectionCurator,
              onCommit: {
                self.app.navigation.showHomeOptions = false
            }
            ).foregroundColor(.accentColor)
          }
        }
        .disabled(collection.type != .userCollection)
      }
      .navigationBarTitle("\(isOnRotation ? "On Rotation" : "Collection") Options", displayMode: .inline)
      .navigationBarItems(
        leading:
        SettingsButton()
          .environmentObject(self.app),
        trailing:
        Button(action: {
          if self.app.navigation.activeCollectionId == self.app.navigation.onRotationId {
            self.app.navigation.showHomeOptions = false
          } else {
            self.app.navigation.showCollectionOptions = false
          }
        }) {
          Text("Close")
        }
      )
      
    }
    .navigationViewStyle(StackNavigationViewStyle())
  }
}

struct ShareCollectionButton: View {
  
  @EnvironmentObject var app: AppEnvironment
  
  var collection: Collection
  
  @State private var showSharing: Bool = false
  
  private var isOnRotation: Bool {
    self.collection.id == self.app.state.library.onRotation.id
  }
  
  var body: some View {
    Button(action: {
      self.showSharing = true
    }) {
      HStack {
        Image(systemName: "square.and.arrow.up")
          .frame(width: Constants.optionsButtonIconWidth)
        Text("Share \(self.isOnRotation ? "On Rotation" : "Collection")")
      }
    }
    .sheet(isPresented: self.$showSharing) {
      ShareSheetLoader(collection: self.collection)
        .environmentObject(self.app)
    }
  }
}

