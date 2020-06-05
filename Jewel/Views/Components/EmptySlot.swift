//
//  EmptySlot.swift
//  Jewel
//
//  Created by Greg Hepworth on 01/06/2020.
//  Copyright © 2020 Breakbeat Ltd. All rights reserved.
//

import SwiftUI

struct EmptySlot: View {
  
  @EnvironmentObject var store: AppStore
  
  @State private var showSearch: Bool = false
  
  var slotIndex: Int
  
  var body: some View {
    HStack {
      Button(action: {
        self.showSearch = true
      }) {
        RoundedRectangle(cornerRadius: 4)
          .stroke(
            Color.secondary,
            style: StrokeStyle(lineWidth: 2, dash: [4, 6])
        )
          .overlay(
            Image(systemName: "plus")
              .font(.headline)
              .foregroundColor(Color.secondary)
        )
      }
      .sheet(isPresented: $showSearch) {
        SearchHome(slotIndex: self.slotIndex, showing: self.$showSearch)
          .environmentObject(self.store)
      }
    }
  }
}