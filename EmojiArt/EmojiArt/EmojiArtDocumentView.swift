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
                            .onDrag { return NSItemProvider(object: emoji as NSString) } // old objc code
                    }
                }
            }
            .padding(.horizontal)
            GeometryReader { geometry in
                ZStack {
                    // overlay rather than ZStack because of size
                    Color.white.overlay(
                        Group {
                            if self.document.backgroundImage != nil {
                                Image(uiImage: self.document.backgroundImage!)
                            }
                        }
                    )
                        .edgesIgnoringSafeArea([.horizontal, .bottom])
                        // of - what kind of thing do you want to drop / "public.iamge" - a URI that specifies type of things that are images
                        // isTargeted - lets us know when user is dragging something over NOT when dropping
                        // function/closure - providers - provide information that is being dropped (transfer needs to happen asynchronously) / location - to drop
                        .onDrop(of: ["public.image"], isTargeted: nil) { providers, location in
                            var location = geometry.convert(location, from: .global)
                            location = CGPoint(x: location.x - geometry.size.width/2, y: location.y - geometry.size.height/2)
                            // return if drop succeeds
                            return self.drop(providers: providers, at: location)
                        }
                    ForEach(self.document.emojis) { emoji in
                        Text(emoji.text)
                            .font(self.font(for: emoji))
                            .position(self.position(for: emoji, in: geometry.size))
                    }
                }
            }
        }
    }
    
    private func font(for emoji: EmojiArt.Emoji) -> Font {
        Font.system(size: emoji.fontSize)
    }
    
    private func position(for emoji: EmojiArt.Emoji, in size: CGSize) -> CGPoint {
        CGPoint(x: emoji.location.x + size.width/2, y: emoji.location.y + size.height/2)
    }
    
    private func drop(providers: [NSItemProvider], at location: CGPoint) -> Bool {
        var found = providers.loadFirstObject(ofType: URL.self) { url in
            print("dropped \(url)")
            self.document.setBackgroundURL(url)
        }
        if !found {
            found = providers.loadObjects(ofType: String.self) { string in
                self.document.addEmoji(string, at: location, size: self.defaultEmojiSize)
            }
        }
        return found
    }
    
    private let defaultEmojiSize: CGFloat = 40
}


//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        ContentView()
//    }
//}
