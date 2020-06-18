//
//  EmptySlot.swift
//  Jewel
//
//  Created by Greg Hepworth on 01/06/2020.
//  Copyright © 2020 Breakbeat Ltd. All rights reserved.
//

import SwiftUI

struct EmptySlotCard: View {
  
  @EnvironmentObject var app: AppEnvironment
  
  let slotIndex: Int
  let collectionId: UUID
  
  @State private var showSearch: Bool = false
  
  var body: some View {
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
      SearchHome(slotIndex: self.slotIndex, collectionId: self.collectionId, showing: self.$showSearch)
        .environmentObject(self.app)
    }
  }
}
