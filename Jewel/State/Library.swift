//
//  LibraryState.swift
//  Listen Later
//
//  Created by Greg Hepworth on 04/06/2020.
//  Copyright © 2020 Breakbeat Ltd. All rights reserved.
//

import Foundation
import HMV

struct Library: Codable {
  var collections = [Collection]()
  var cuedCollection: ShareLinkProvider.ShareableCollection?
  
  enum CodingKeys: CodingKey {
    case collections
  }
}
