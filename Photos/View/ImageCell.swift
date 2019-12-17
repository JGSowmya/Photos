//
//ImageCell.swift
//  Photos
//
//  Created by Sowmya J G on 09/12/19.
//  Copyright © 2019 Sowmya J G. All rights reserved.
//

import Foundation
import UIKit

class ImageCell: UICollectionViewCell {
    var titleLabel = UILabel()
    var descriptionLabel = UILabel()
    var imageView = UIImageView()
    
    func setUp(imageData: ImageData) {
        // Add Image View
        imageView.frame = CGRect.init(
            x: 0,
            y: 0,
            width: self.frame.width,
            height: self.frame.height * 0.6)

        // Add Title
        titleLabel.frame = CGRect.init(
            x: 0,
            y: imageView.frame.height + imageView.frame.origin.y,
            width: self.frame.width,
            height: self.frame.height * 0.15)
        titleLabel.text = imageData.title
        titleLabel.textColor = UIColor.black
        titleLabel.font = UIFont.boldSystemFont(ofSize: 18)

        // Add Description
        descriptionLabel.frame = CGRect.init(
            x: 0,
            y: titleLabel.frame.height + titleLabel.frame.origin.y,
            width: self.frame.width,
            height: self.frame.height * 0.25)
        descriptionLabel.text = imageData.description
        descriptionLabel.textColor = UIColor.gray
        descriptionLabel.font = UIFont.italicSystemFont(ofSize: 14)
        descriptionLabel.textAlignment = NSTextAlignment.left
        descriptionLabel.contentMode = .scaleAspectFit
        descriptionLabel.numberOfLines = 0

        // Add separator line
        let separatorLine = UIView.init(frame: CGRect.init(
            x: 0,
            y: self.frame.height - 0.4,
            width: self.frame.width,
            height: 0.4))
        separatorLine.backgroundColor = UIColor.lightGray

        self.addSubview(titleLabel)
        self.addSubview(imageView)
        self.addSubview(descriptionLabel)
        self.addSubview(separatorLine)
    }
    
    func setImage(imageData: Data?) {
        DispatchQueue.main.async {
            guard let imageData = imageData else {
                self.imageView.image = UIImage.init(named: "Default.png")
                self.imageView.contentMode = .scaleAspectFit
                return
            }
            self.imageView.image = UIImage.init(data: imageData)
            self.imageView.contentMode = .scaleAspectFit
        }
    }
}
