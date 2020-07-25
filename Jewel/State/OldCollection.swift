//
//  CollectionState.swift
//  Jewel
//
//  Created by Greg Hepworth on 01/06/2020.
//  Copyright © 2020 Breakbeat Ltd. All rights reserved.
//

import Foundation
import HMV

struct OldCollection: Identifiable, Codable {
  var id = UUID()
  var type: CollectionType
  var name: String
  var curator: String
  var slots: [OldSlot] = {
    var tmpSlots = [OldSlot]()
    for _ in 0..<8 {
      let slot = OldSlot()
      tmpSlots.append(slot)
    }
    return tmpSlots
  }()
  
  var shareLinkLong: URL?
  var shareLinkShort: URL?
  
  enum CodingKeys: CodingKey {
    case id
    case name
    case type
    case curator
    case slots
    case shareLinkLong
    case shareLinkShort
  }
}

enum CollectionType: String, Codable {
  case userCollection
  case sharedCollection
}
