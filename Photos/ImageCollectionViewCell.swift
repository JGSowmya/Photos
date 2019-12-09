//
//  ImageCollectionViewCell.swift
//  Photos
//
//  Created by Sowmya J G on 09/12/19.
//  Copyright © 2019 Sowmya J G. All rights reserved.
//

import Foundation
import UIKit

class ImageCollectionViewCell: UICollectionViewCell {
    var titleLabel = UILabel()
    var descriptionLabel = UILabel()
    var imageView = UIImageView()
    
    func setUp(imageData: ImageData) {
        // Add Title
        titleLabel.frame = CGRect.init(x: 0, y: 0, width: self.frame.width, height: self.frame.height * 0.2)
        titleLabel.text = imageData.title
        titleLabel.textColor = UIColor.black
        titleLabel.font = UIFont.boldSystemFont(ofSize: 18)
        
        // Add Image View
        imageView.frame = CGRect.init(x: 0, y: titleLabel.frame.height + titleLabel.frame.origin.y, width: self.frame.width, height: self.frame.height * 0.6)
        imageView.image = UIImage.init(named: "Default.png")
        
        // Add Description
        descriptionLabel.frame = CGRect.init(x: 0, y: imageView.frame.height + imageView.frame.origin.y, width: self.frame.width, height: self.frame.height * 0.2)
        descriptionLabel.text = imageData.description
        descriptionLabel.textColor = UIColor.black
        descriptionLabel.font = UIFont.boldSystemFont(ofSize: 15)

        descriptionLabel.contentMode = .scaleToFill
        descriptionLabel.numberOfLines = 0

        // Add separator line
        let separatorLine = UIView.init(frame: CGRect.init(x: 0, y: self.frame.height - 0.6, width: self.frame.width, height: 0.6))
        separatorLine.backgroundColor = UIColor.gray

        self.addSubview(titleLabel)
        self.addSubview(imageView)
        self.addSubview(descriptionLabel)
        self.addSubview(separatorLine)
    }
    
    func setImage(data: Data) {
        imageView.image = UIImage.init(data: data)
        if (imageView.image == nil) {
            imageView.image = UIImage.init(named: "Default.png")
        }
        imageView.contentMode = .scaleAspectFit
    }
}
