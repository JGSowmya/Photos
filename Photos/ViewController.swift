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

    let url: String = "https://dl.dropboxusercontent.com/s/2iodh4vg0eortkl/facts.json"
    var imageBookData = ImageBook([:])
    let cellReuseIdentifier = "imageCell"
    let cellsPerRow: CGFloat = 1
    let collectionView = UICollectionView.init(frame: CGRect(), collectionViewLayout: UICollectionViewFlowLayout())
    lazy var refreshControl = UIRefreshControl()

    override func viewDidLoad() {
        super.viewDidLoad()
            
        loadContent { (status) in
            guard status else {
                print("Failed to fetch the data")
                return
            }
            DispatchQueue.main.async {
                self.loadUI()
            }
        }
    }

    func loadContent(completionHandler: @escaping (_ status: Bool) -> Void) {
        
        Alamofire.request(url, method: .get).responseString { response in
            switch response.result {
                case .success:
                    let string = response.result.value
                    let data = string!.data(using: .utf8)!
                    do {
                        if let jsonObject = try JSONSerialization.jsonObject(with: data, options : .allowFragments) as? Dictionary<String,Any>
                        {
                            self.imageBookData = ImageBook(jsonObject)
                            return completionHandler(true)

                        } else {
                            print("bad json")
                            return completionHandler(false)
                        }
                    } catch let error as NSError {
                        print("Error: \(error)")
                        return completionHandler(false)
                    }
                case .failure( _):
                    return completionHandler(false)
                }
        }

    }
    
    func loadUI() {
        let titleLabel = UILabel.init(frame: CGRect.init(x: 0, y: 0, width: self.view.frame.width, height: 100))
        self.view.addSubview(titleLabel)
        titleLabel.text = imageBookData.title
        titleLabel.textAlignment = .center
        titleLabel.textColor = UIColor.white
        if #available(iOS 10.0, *) {
            titleLabel.backgroundColor = UIColor.init(displayP3Red: 75/255.0, green: 0, blue: 130/255.0, alpha: 1.0)
        } else {
            // Fallback on earlier versions
        }
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

            if #available(iOS 9.0, *) {
                titleLabel.heightAnchor.constraint(equalToConstant: 100).isActive = true
            } else {
                // Fallback on earlier versions
            }
        }
        
        collectionView.frame = CGRect.init(x: 0,
                                           y: titleLabel.frame.height,
                                           width: self.view.frame.width,
                                           height: self.view.frame.height - titleLabel.frame.height)
        let flowLayout = UICollectionViewFlowLayout()
        collectionView.collectionViewLayout = flowLayout
        collectionView.register(ImageCollectionViewCell.self, forCellWithReuseIdentifier: cellReuseIdentifier)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = UIColor.white

        self.view.addSubview(collectionView)
        
        let margin: CGFloat = 15.0
        flowLayout.minimumInteritemSpacing = margin
        flowLayout.minimumLineSpacing = margin
        flowLayout.sectionInset = UIEdgeInsets(top: margin, left: margin, bottom: margin, right: margin)

        if #available(iOS 11.0, *) {
            collectionView.contentInsetAdjustmentBehavior = .always
        } else {
            // Fallback on earlier versions
        }
        collectionView.translatesAutoresizingMaskIntoConstraints = false

        // Add refreh control
        refreshControl.attributedTitle = NSAttributedString(string: "Fetching data...")
        refreshControl.addTarget(self, action: #selector(refresh(sender:)), for: UIControl.Event.valueChanged)
        
        // Add Refresh Control to Table View
        if #available(iOS 10.0, *) {
            collectionView.refreshControl = refreshControl
        } else {
            collectionView.addSubview(refreshControl)
        }
    }
    
    @objc func refresh(sender: AnyObject) {
        loadContent { (status) in
            if (status) {
                self.collectionView.reloadData()
                self.refreshControl.endRefreshing()
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageBookData.rows.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellReuseIdentifier, for: indexPath) as! ImageCollectionViewCell
        let imageInfo = imageBookData.rows[indexPath.row]
        cell.setUp(imageData: imageInfo);
        
        Alamofire.request(imageInfo.imageHref).responseData { (response) in
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
