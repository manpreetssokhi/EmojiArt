//
//  EmojiArtDocument.swift
//  EmojiArt
//
//  Created by Manpreet Sokhi on 9/11/20.
//  Copyright © 2020 Manpreet Sokhi. All rights reserved.
//

import SwiftUI
import Combine // for cancellable, publishing and subscribing

class EmojiArtDocument: ObservableObject, Hashable, Identifiable {
    // strategy (for Hashable and Equatable) would only work for a reference type aka class becasue we are seeing same version of it in heap
    // stub form Hashable issue of not being Equatable
    static func == (lhs: EmojiArtDocument, rhs: EmojiArtDocument) -> Bool {
        lhs.id == rhs.id
    }
    
    // Hashable protocol has one function - hash and to be Hashable need to implement Equatable
    // hasher.combine takes something that itself is hashable and it combines multiple things inside object to make something hashable
    // UUID is struct that generates a unique thing - UUID is hashable
    let id: UUID
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static let palette: String = "🤬🤯🥶🗣🐴🐻🐬🥞🍺🥊🏎🚀💻💈"
    
    // @Published because everytime emojiArt changes need to use ObservableObject to cause View to redraw
    @Published private var emojiArt: EmojiArt
    
    private var autosaveCancellable: AnyCancellable?
    
    // passing in id to store documents with unique name rather than "EmojiArtDocument.Untitled"
    // making this an optional allows us to call init with nothing or a UUID or a nil - adds flexibility
    init(id: UUID? = nil) {
        self.id = id ?? UUID()
        let defaultsKey = "EmojiArtDocument.\(self.id.uuidString)"
        emojiArt = EmojiArt(json: UserDefaults.standard.data(forKey: defaultsKey)) ?? EmojiArt()
        // publisher - trying to sink it to function. Sink is a subsriber
        autosaveCancellable = $emojiArt.sink { emojiArt in
            print("\(emojiArt.json?.utf8 ?? "nil")")
            UserDefaults.standard.set(emojiArt.json, forKey: defaultsKey)
        }
        fetchBackgroundImageData()
    }
    
    // UIImage is actaully from UIKit but works well and ? because we may have link but not UIImage
    @Published private(set) var backgroundImage: UIImage?
    
    // UI visual state and is temporary - 1.0 is normal, 2.0 is double, 0.5 is half original
    @Published var steadyStateZoomScale: CGFloat = 1.0
    // this for the pan
    @Published var steadyStatePanOffset: CGSize = .zero
    
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
            emojiArt.emojis[index].size = Int((CGFloat(emojiArt.emojis[index].size) * scale).rounded(.toNearestOrEven))
        }
    }
    
    var backgroundURL: URL? {
        get {
            emojiArt.backgroundURL
        }
        set {
            emojiArt.backgroundURL = newValue?.imageURL
            // only job is to set the backgroundImage, ReactiveUI is set
            fetchBackgroundImageData()
            
        }

    }
    
    private var fetchImageCancellable: AnyCancellable?
    private func fetchBackgroundImageData() {
        backgroundImage = nil
        if let url = self.emojiArt.backgroundURL {
            // URLSessions way of doing it with publisher
            
            // when we get a new image request cancel the old one we are not interested in
            fetchImageCancellable?.cancel()
            // shared can be used for simple downloads
            // dataTaskPublisher - go out fetch and publish
            // assign will only work if never (or UIImage is optional so can return error as nil) as the error
            fetchImageCancellable = URLSession.shared.dataTaskPublisher(for: url)
                // map takes a closure that gives info on existing publisher (data and URLResponse here) and it lets you return the type you wnat it to be (UIImage)
                .map { data, URLResponse in UIImage(data: data) }
                // to publish on main queue
                . receive(on: DispatchQueue.main)
                // basically if error make the response nil
                .replaceError(with: nil)
                .assign(to: \.backgroundImage, on: self)
            
//            DispatchQueue.global(qos: .userInitiated).async { // do this on a background thread
//                if let imageData = try? Data(contentsOf: url) { // this could take variable time, could freeze our app - use dispatch mechanism
//                    DispatchQueue.main.async {
//                        if url == self.emojiArt.backgroundURL { // error handling to make sure image requested is still the right one
//                            self.backgroundImage = UIImage(data: imageData) // if outside of main - problem here is that this forces View to redraw BUT on a background thread - NOT ALLOWED
//                        }
//                    }
//                }
//            }
        }
    }
}

// interpretation of model - now we don't have to deal with Ints in View
extension EmojiArt.Emoji {
    var fontSize: CGFloat { CGFloat(self.size) }
    var location: CGPoint { CGPoint(x: CGFloat(x), y: CGFloat(y)) }
}
