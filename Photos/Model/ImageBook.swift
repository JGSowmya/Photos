//
//  ImageBook.swift
//  Photos
//
//  Created by Sowmya J G on 09/12/19.
//  Copyright © 2019 Sowmya J G. All rights reserved.
//

import Foundation

struct ImageBook: Codable {
    let title: String?
    var rows: [ImageData]

    enum CodingKeys: String, CodingKey {
        case title = "title"
        case rows = "rows"
    }
}

struct ImageData: Codable {
    let title: String?
    let description: String?
    let imageURL: URL?

    enum CodingKeys: String, CodingKey {
        case title = "title"
        case description = "description"
        case imageURL = "imageHref"
    }
}
