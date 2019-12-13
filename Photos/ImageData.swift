//
//  ImageData.swift
//  Photos
//
//  Created by Sowmya J G on 09/12/19.
//  Copyright © 2019 Sowmya J G. All rights reserved.
//

import Foundation

public struct ImageData {
    let title: String?
    let description: String?
    let imageURL: String?
    
    init(_ dictionary: [String: Any]) {
        self.title = dictionary["title"] as? String ?? ""
        self.description = dictionary["description"] as? String ?? ""
        self.imageURL = dictionary["imageHref"] as? String ?? ""
    }
}
