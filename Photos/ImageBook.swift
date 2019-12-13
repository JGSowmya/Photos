//
//  ImageBook.swift
//  Photos
//
//  Created by Sowmya J G on 09/12/19.
//  Copyright © 2019 Sowmya J G. All rights reserved.
//

import Foundation

public struct ImageBook {
    let title: String?
    var rows: [ImageData]
    
    init(_ dictionary: [String: Any]) {
        self.title = dictionary["title"] as? String ?? ""
        self.rows = [ImageData]()

        guard let items = dictionary["rows"] as? [Dictionary<String, Any>] else {
            return
        }
        for item in items {
            self.rows.append(ImageData(item)) // adding now value in Model array
        }
        return
    }
}
