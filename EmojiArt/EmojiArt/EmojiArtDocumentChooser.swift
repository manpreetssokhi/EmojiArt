//
//  EmojiArtDocumentChooser.swift
//  EmojiArt
//
//  Created by Manpreet Sokhi on 9/15/20.
//  Copyright © 2020 Manpreet Sokhi. All rights reserved.
//

import SwiftUI

struct EmojiArtDocumentChooser: View {
    @EnvironmentObject var store: EmojiArtDocumentStore
    
    @State private var editMode: EditMode = .inactive
    
    var body: some View {
        // Need NavigationView so when we click on something in List, it will go somewhere - can put Lists or Forms in NavigationView
        NavigationView {
            // List is like VStack but more powerful with a scrollable List and separators etc. aka a TableView in UIKit
            List {
                // can do this beacuse it is Identifiable
                ForEach(store.documents) { document in
                    // NavigationLink for each of the items in List to provide a destination aka make it navigatable
                    NavigationLink(destination: EmojiArtDocumentView(document: document)
                        .navigationBarTitle(self.store.name(for: document))
                    ) {
                        EditableText(self.store.name(for: document), isEditing: self.editMode.isEditing) { name in
                            self.store.setName(name, for: document)
                        }
                    }
                }
                // swipe to delete - indexSet is an array of indeces and it tells you things that are deleted
                .onDelete { indexSet in
                    // come back and understand this
                    indexSet.map { self.store.documents[$0] }.forEach { document in
                        self.store.removeDocument(document)
                    }
                }
            }
            .navigationBarTitle(self.store.name)
            // would only be available when list is showing
            .navigationBarItems(
                leading: Button(action: {
                    self.store.addDocument()
                }, label: {
                    Image(systemName: "plus").imageScale(.large)
                }),
                // second way of deleting - edit mode in a for each
                trailing: EditButton()
            )
            // to be able to change document name in edit mode - this is a binding to edit mode
            // .environment sets that var in environment values only for the view it is called on
            .environment(\.editMode, $editMode)
        }
    }
}

struct EmojiArtDocumentChooser_Previews: PreviewProvider {
    static var previews: some View {
        EmojiArtDocumentChooser()
    }
}
