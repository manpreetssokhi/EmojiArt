//
//  EmojiArt.swift
//  EmojiArt
//
//  Created by Manpreet Sokhi on 9/11/20.
//  Copyright © 2020 Manpreet Sokhi. All rights reserved.
//

import Foundation

struct EmojiArt: Codable  {
    var backgroundURL: URL?
    var emojis = [Emoji]()
    
    // Codable - encode and decode JSON
    // Hashable - can put into set
    struct Emoji: Identifiable, Codable, Hashable {
        let text: String
        var x: Int // offset from center
        var y: Int // offset from center
        var size: Int
        let id: Int // UUID() would be unique identifier for being identifiable but overkill here
        
        // protecting adding emoji when addEmoji is not called - we don't want to use private(set) because we want coordinates to be freely set by user
        // fileprivate makes this private init private in this file - gives EmojiArt the power to do it, but no one outside file
        fileprivate init(text: String, x: Int, y: Int, size: Int, id: Int) {
            self.text = text
            self.x = x
            self.y = y
            self.size = size
            self.id = id
        }
    }
    
    var json: Data? {
        return try? JSONEncoder().encode(self)
    }
    
    // to decode - way to create EmojiArtDocument from this JSON data
    init?(json: Data?) {
        if json != nil, let newEmojiArt = try? JSONDecoder().decode(EmojiArt.self, from: json!) {
            self = newEmojiArt // allowed to do this with value type and even with enums
        } else {
            return nil
        }
    }
    
    init() { }
    
    private var uniqueEmojiId = 0
    
    mutating func addEmoji(_ text: String, x: Int, y: Int, size: Int) {
        uniqueEmojiId += 1
        emojis.append(Emoji(text: text, x: x, y: y, size: size, id: uniqueEmojiId))
    }
}
