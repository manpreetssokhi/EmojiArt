//
//  EmojiArtDocumentView.swift
//  EmojiArt
//
//  Created by Manpreet Sokhi on 9/11/20.
//  Copyright © 2020 Manpreet Sokhi. All rights reserved.
//

import SwiftUI

struct EmojiArtDocumentView: View {
    @ObservedObject var document: EmojiArtDocument // our ViewModel
    
    var body: some View {
        VStack {
            ScrollView(.horizontal) {
                HStack {
                    // map is a function on String that will turn it into array given a single character
                    ForEach(EmojiArtDocument.palette.map { String($0) }, id: \.self) { emoji in
                        Text(emoji)
                            .font(Font.system(size: self.defaultEmojiSize))
                    }
                }
            }
            .padding(.horizontal)
            Rectangle().foregroundColor(.yellow)
                .edgesIgnoringSafeArea([.horizontal, .bottom])
        }
    }
    
    private let defaultEmojiSize: CGFloat = 40
}


//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        ContentView()
//    }
//}
