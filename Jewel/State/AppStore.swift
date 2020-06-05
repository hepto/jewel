//
//  Store.swift
//  Jewel
//
//  Created by Greg Hepworth on 29/05/2020.
//  Copyright © 2020 Breakbeat Ltd. All rights reserved.
//

import Foundation
import HMV

final class AppStore: ObservableObject {
  @Published private(set) var state: AppState {
    didSet {
      save()
    }
  }
  
  init() {
    if let savedState = UserDefaults.standard.object(forKey: "jewelState") as? Data {
      do {
        state = try JSONDecoder().decode(AppState.self, from: savedState)
        print("Loaded state")
        return
      } catch {
        print(error)
      }
    }
    
    let options = Options()
    let collection = Collection()
    let library = Library()
    let search = Search()
    let appState = AppState(options: options, collection: collection, library: library, search: search)
    self.state = appState
  }
  
  public func update(action: AppAction) {
    state = updateState(appState: state, action: action)
  }
  
  private func save() {
    do {
      let encodedState = try JSONEncoder().encode(state)
      UserDefaults.standard.set(encodedState, forKey: "jewelState")
      print("Saved state")
    } catch {
      print(error)
    }
  }
  
}
