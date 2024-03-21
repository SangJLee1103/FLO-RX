//
//  Music.swift
//  FLO-RX
//
//  Created by 이상준 on 3/16/24.
//

import Foundation

struct Music: Decodable {
    let singer, album, title: String
    let duration: Int
    let lyrics: String
    let imageUrl: String
    let fileUrl: String
    
    enum CodingKeys: String, CodingKey {
        case singer
        case album
        case title
        case duration
        case lyrics
        case imageUrl = "image"
        case fileUrl = "file"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.singer = try container.decode(String.self, forKey: .singer)
        self.album = try container.decode(String.self, forKey: .album)
        self.title = try container.decode(String.self, forKey: .title)
        self.duration = try container.decode(Int.self, forKey: .duration)
        self.imageUrl = try container.decode(String.self, forKey: .imageUrl)
        self.fileUrl = try container.decode(String.self, forKey: .fileUrl)
        self.lyrics = try container.decode(String.self, forKey: .lyrics)
    }
}
