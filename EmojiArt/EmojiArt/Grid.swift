//
//  Grid.swift
//  Memorize
//
//  Created by Manpreet Sokhi on 9/1/20.
//  Copyright © 2020 Manpreet Sokhi. All rights reserved.
//

import SwiftUI

// forcing id to be same to be able to call the init
extension Grid where Item: Identifiable, ID == Item.ID {
    init(_ items: [Item], viewForItem: @escaping (Item) -> ItemView) {
        self.init(items, id: \Item.id, viewForItem: viewForItem)
    }
}

// constrains and gains using generics with protocols to constrain don't cares to work
struct Grid<Item, ID, ItemView>: View where ID: Hashable, ItemView: View {
    // Both are "don't care"
    private var items: [Item]
    private var id: KeyPath<Item, ID>
    private var viewForItem: (Item) -> ItemView
    
    // @escaping allows function to escape from init without being called
    init(_ items: [Item], id: KeyPath<Item, ID>,viewForItem: @escaping (Item) -> ItemView) {
        self.items = items
        self.id = id
        self.viewForItem = viewForItem
    }
    
    var body: some View {
        // figure out space that is allocated to Grid using GeometryReader
        GeometryReader { geometry in
            self.body(for: GridLayout(itemCount: self.items.count, in: geometry.size))
        }
    }
    
    private func body(for layout: GridLayout) -> some View {
        ForEach(items, id: id) { item in
            self.body(for: item, in: layout)
        }
    }
    
    private func body(for item: Item, in layout: GridLayout) -> some View {
        // ! will force unwrap it and turn index to an int
        let index = items.firstIndex(where: { item[keyPath: id] == $0[keyPath: id] } )
        // Group's function argument is a View builder, positioning will still work
        return Group {
            viewForItem(item)
                .frame(width: layout.itemSize.width, height: layout.itemSize.height)
                .position(layout.location(ofItemAt: index!))
        }
    }
}
