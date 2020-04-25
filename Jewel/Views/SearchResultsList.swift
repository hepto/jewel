//
//  SearchResultsList.swift
//  Jewel
//
//  Created by Greg Hepworth on 24/04/2020.
//  Copyright © 2020 Breakbeat Limited. All rights reserved.
//

import SwiftUI
import KingfisherSwiftUI
import HMV

struct SearchResultsList: View {
    
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var wallet: Wallet
    @Binding var searchResults: [Album]?
    var slotId: Int
    
    var body: some View {
        List(0...self.searchResults!.count - 1, id: \.self) { i in
            Button(action: {
                self.wallet.addAlbumToSlot(albumId: self.searchResults![i].id, slotId: self.slotId)
                self.presentationMode.wrappedValue.dismiss()
            }, label: {
                HStack {
                    VStack(alignment: .leading) {
                        Text(self.searchResults![i].attributes!.artistName)
                            .font(.headline)
                            .lineLimit(1)
                        Text(self.searchResults![i].attributes!.name)
                            .font(.subheadline)
                            .lineLimit(1)
                    }
                    Spacer()
                    KFImage(self.searchResults![i].attributes!.artwork.url(forWidth: 50))
                        .placeholder {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color.gray)
                        }
                        .renderingMode(.original)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .cornerRadius(4)
                        .frame(width: 50)
                }
            })
        }
    }
}

//struct SearchResultsList_Previews: PreviewProvider {
//    static var previews: some View {
//        SearchResultsList()
//    }
//}

struct SearchResultsList_Previews: PreviewProvider {
    static var previews: some View {
        /*@START_MENU_TOKEN@*/Text("Hello, World!")/*@END_MENU_TOKEN@*/
    }
}