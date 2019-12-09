//
//  ViewController.swift
//  Photos
//
//  Created by Sowmya J G on 08/12/19.
//  Copyright © 2019 Sowmya J G. All rights reserved.
//

import UIKit
import Alamofire

class ViewController: UIViewController,
    UICollectionViewDelegate,
    UICollectionViewDataSource,
    UICollectionViewDelegateFlowLayout {

    var images = [ImageData]()
    let cellReuseIdentifier = "imageCell"
    let cellsPerRow: CGFloat = 1
    var titleString = "No Title"
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        
        images = readAndParseJson() as! [ImageData]
        
        let titleLabel = UILabel.init(frame: CGRect.init(x: 0, y: 0, width: self.view.frame.width, height: 100))
        self.view.addSubview(titleLabel)
        titleLabel.text = titleString
        titleLabel.textAlignment = .center
        titleLabel.textColor = UIColor.white
        titleLabel.backgroundColor = UIColor.init(displayP3Red: 75/255.0, green: 0, blue: 130/255.0, alpha: 1.0)
        titleLabel.font = UIFont.boldSystemFont(ofSize: 20.0)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        if #available(iOS 11.0, *) {
            let guide = self.view.safeAreaLayoutGuide
            titleLabel.trailingAnchor.constraint(equalTo: guide.trailingAnchor).isActive = true
            titleLabel.leadingAnchor.constraint(equalTo: guide.leadingAnchor).isActive = true
            titleLabel.topAnchor.constraint(equalTo: guide.topAnchor).isActive = true
            titleLabel.heightAnchor.constraint(equalToConstant: 50).isActive = true

        }
        else {
            NSLayoutConstraint(item: titleLabel, attribute: .top, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1.0, constant: 0).isActive = true
            NSLayoutConstraint(item: titleLabel, attribute: .leading, relatedBy: .equal, toItem: view, attribute: .leading, multiplier: 1.0, constant: 0).isActive = true
            NSLayoutConstraint(item: titleLabel, attribute: .trailing, relatedBy: .equal, toItem: view, attribute: .trailing, multiplier: 1.0, constant: 0).isActive = true

            titleLabel.heightAnchor.constraint(equalToConstant: 100).isActive = true
        }
        
        let flowLayout = UICollectionViewFlowLayout()
        let collectionView = UICollectionView(frame: CGRect.init(x: 0,
                                                                 y: titleLabel.frame.height,
                                                                 width: self.view.frame.width,
                                                                 height: self.view.frame.height - titleLabel.frame.height),
                                              collectionViewLayout: flowLayout)
        collectionView.register(ImageCollectionViewCell.self, forCellWithReuseIdentifier: cellReuseIdentifier)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = UIColor.white

        self.view.addSubview(collectionView)
        
        let margin: CGFloat = 15.0
        flowLayout.minimumInteritemSpacing = margin
        flowLayout.minimumLineSpacing = margin
        flowLayout.sectionInset = UIEdgeInsets(top: margin, left: margin, bottom: margin, right: margin)

        collectionView.contentInsetAdjustmentBehavior = .always
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
    }
    
    func readAndParseJson() -> [Any] {
        guard let path = Bundle.main.path(forResource: "AboutCanada", ofType: "json") else {
            return [Any]()
        }
        do {
            let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
            let jsonResult = try JSONSerialization.jsonObject(with: data, options: .mutableLeaves)
            guard let jsonDictionary = jsonResult as? Dictionary<String, Any>,
                let rows = jsonDictionary["rows"] as? [Dictionary<String, Any>] else {
               return [Any]()
            }
            titleString = jsonDictionary["title"] as! String // Assign the title value to global variable
            
            var modelArray = [ImageData]()
            for dic in rows{
                modelArray.append(ImageData(dic)) // adding now value in Model array
            }
            return modelArray
            
        } catch {
            print("Error occured while reading json file")
        }
        return [Any]()
    }


    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        images.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellReuseIdentifier, for: indexPath) as! ImageCollectionViewCell
        let imageInfo = images[indexPath.row]
        cell.setUp(imageData: imageInfo);
        
        AF.request(imageInfo.imageHref).responseData { (response) in
            if (response.error == nil) {
                guard response.data != nil else {
                    cell.imageView.image = UIImage.init(named: "Default.png")
                    return
                }
                cell.setImage(data: response.data!)
                print("Set image at \(indexPath.row)")
            } else {
                print("Failed to fetch the image at \(indexPath.row)")
            }
            
        }
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let flowLayout = collectionViewLayout as! UICollectionViewFlowLayout

        let totalSpace = flowLayout.sectionInset.left
            + flowLayout.sectionInset.right
            + (flowLayout.minimumInteritemSpacing * CGFloat(cellsPerRow - 1))

        let size = Int((collectionView.bounds.width - totalSpace) / CGFloat(cellsPerRow))

        return CGSize(width: size, height: size)
    }
}

