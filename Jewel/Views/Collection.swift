//
//  Home.swift
//  Jewel
//
//  Created by Greg Hepworth on 29/05/2020.
//  Copyright © 2020 Breakbeat Ltd. All rights reserved.
//

import SwiftUI
import HMV

struct Collection: View {
    
    @EnvironmentObject var store: AppStore
    
    private var albums: [Album?] {
        store.state.collection.albums
    }
    
    var body: some View {
        NavigationView {
            GeometryReader { geo in
                List(self.albums.indices, id: \.self) { albumIndex in
                    Group {
                        if self.albums[albumIndex] != nil {
                            NavigationLink(
                                destination: AlbumDetail(album: self.albums[albumIndex]!)
                            ) {
                                AlbumCard(album: self.albums[albumIndex]!)
                            }
                        } else {
                            EmptySlot(slotIndex: albumIndex)
                        }
                    }
                    .frame(height: (geo.size.height - geo.safeAreaInsets.top - geo.safeAreaInsets.bottom) / CGFloat(self.albums.count))
                }
                .onAppear {
                    UITableView.appearance().separatorStyle = .none
                }
                .navigationBarTitle(self.store.state.collection.name)
                .navigationBarItems(
                    leading: HomeButtonsLeading(),
                    trailing: HomeButtonsTrailing()
                )
            }
        }
    }
}
