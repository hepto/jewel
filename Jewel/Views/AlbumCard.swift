//
//  Album.swift
//  Jewel
//
//  Created by Greg Hepworth on 08/04/2020.
//  Copyright © 2020 Breakbeat Limited. All rights reserved.
//

import SwiftUI
import KingfisherSwiftUI
import HMV

struct AlbumCard: View {
    
    @EnvironmentObject var wallet: SlotStore
    var slotId: Int
    
    var body: some View {
        Rectangle()
        .foregroundColor(.clear)
        .background(
            Unwrap(wallet.slots[slotId].album?.attributes?.artwork) { artwork in
                KFImage(artwork.url(forWidth: 1000))
                    .placeholder {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.gray)
                    }
                    .renderingMode(.original)
                    .resizable()
                    .scaledToFill()
            })
        .cornerRadius(4)
        .overlay(
            MetadataOverlay(slotId: slotId), alignment: .bottomLeading
        )
        .shadow(radius: 3)
    }
}

struct ReleaseListItem_Previews: PreviewProvider {
    
    static let wallet = SlotStore()
    
    static var previews: some View {
        AlbumCard(slotId: 0)
    }
}
