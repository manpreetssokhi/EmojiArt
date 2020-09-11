//
//  EmojiArtDocument.swift
//  EmojiArt
//
//  Created by Manpreet Sokhi on 9/11/20.
//  Copyright © 2020 Manpreet Sokhi. All rights reserved.
//

import SwiftUI

class EmojiArtDocument: ObservableObject {
    
    static let palette: String = "🤬🤯🥶🗣🐴🐻🐬🥞🍺🥊🏎🚀💻💈"
    
    // @Published because everytime emojiArt changes need to use ObservableObject to cause View to redraw
    @Published private var emojiArt: EmojiArt = EmojiArt()
    
    // UIImage is actaully from UIKit but works well and ? because we may have link but not UIImage
    @Published private(set) var backgroundImage: UIImage?
    
    var emojis: [EmojiArt.Emoji] { emojiArt.emojis } // return emojiArt - a read only access to model
    
    // MARK: - Intent(s)
    
    func addEmoji(_ emoji: String, at location: CGPoint, size: CGFloat) {
        emojiArt.addEmoji(emoji, x: Int(location.x), y: Int(location.y), size: Int(size))
    }
    
    func moveEmoji(_ emoji: EmojiArt.Emoji, by offset: CGSize) {
        if let index = emojiArt.emojis.firstIndex(matching: emoji) {
            emojiArt.emojis[index].x += Int(offset.width)
            emojiArt.emojis[index].y += Int(offset.height)
        }
    }
    
    func scaleEmoji(_ emoji: EmojiArt.Emoji, by scale: CGFloat) {
        if let index = emojiArt.emojis.firstIndex(matching: emoji) {
            emojiArt.emojis[index].size = Int ((CGFloat(emojiArt.emojis[index].size) * scale).rounded(.toNearestOrEven))
        }
    }
    
    func setBackgroundURL(_ url: URL?) {
        emojiArt.backgroundURL = url?.imageURL
        
        // only job is to set the backgroundImage, ReactiveUI is set
        fetchBackgroundImageData()
    }
    
    // would use URL Sessions if really downloading data
    private func fetchBackgroundImageData() {
        backgroundImage = nil
        if let url = self.emojiArt.backgroundURL {
            DispatchQueue.global(qos: .userInitiated).async { // do this on a background thread
                if let imageData = try? Data(contentsOf: url) { // this could take variable time, could freeze our app - use dispatch mechanism
                    DispatchQueue.main.async {
                        if url == self.emojiArt.backgroundURL { // error handling to make sure image requested is still the right one
                            self.backgroundImage = UIImage(data: imageData) // if outside of main - problem here is that this forces View to redraw BUT on a background thread - NOT ALLOWED
                        }
                    }
                }
            }
        }
    }
}

// interpretation of model - now we don't have to deal with Ints in View
extension EmojiArt.Emoji {
    var fontSize: CGFloat { CGFloat(self.size) }
    var location: CGPoint { CGPoint(x: CGFloat(x), y: CGFloat(y)) }
}
