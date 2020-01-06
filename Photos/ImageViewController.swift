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


    let jsonURL: String = "https://dl.dropboxusercontent.com/s/2iodh4vg0eortkl/facts.json"
    var images: [ImageData]?
    var imageCollectionView: UICollectionView?
    lazy var refreshControl = UIRefreshControl()
    var titleLabel: UILabel?
    let imageCache = NSCache<NSString, NSData>()
    let cellReuseIdentifier = "imageCell"
    let cellsPerRow: CGFloat = (UIDevice.current.userInterfaceIdiom == .phone) ? 1 : 2


    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewDidAppear(_ animated: Bool) {
        loadUI()
        loadContent()
    }

    func loadContent() {
        Alamofire.request(jsonURL, method: .get).responseString { response in
            switch response.result {
                case .success:
                    if let string = response.result.value {
                        if let jsonData = string.data(using: .utf8) {
                            let decoder = JSONDecoder()
                            do {
                                let imageBookObject = try decoder.decode(ImageBook.self, from: jsonData)
                                self.images = imageBookObject.rows
                                self.titleLabel?.text = imageBookObject.title
                                self.imageCollectionView?.reloadData()
                            } catch let error as NSError {
                                print("Error: \(error)")
                            }
                        }
                    }

                case .failure(_):
                    break
            }
        }
    }
    
    func loadUI() {
        let titleLabel = UILabel()
        self.view.addSubview(titleLabel)
        titleLabel.textAlignment = .center
        titleLabel.textColor = UIColor.white
        titleLabel.backgroundColor = UIColor.init(
            red: 75/255.0,
            green: 0,
            blue: 130/255.0,
            alpha: 1.0)
        titleLabel.font = UIFont.boldSystemFont(ofSize: 20.0)
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        if #available(iOS 11.0, *) {
            let guide = view.safeAreaLayoutGuide
            titleLabel.topAnchor.constraint(equalTo: guide.topAnchor, constant: 0).isActive = true
            titleLabel.leftAnchor.constraint(equalTo: guide.leftAnchor).isActive = true
            titleLabel.widthAnchor.constraint(equalTo: guide.widthAnchor).isActive = true
            titleLabel.heightAnchor.constraint(equalToConstant: 50).isActive = true
        } else {
            NSLayoutConstraint(item: titleLabel,
                               attribute: .top,
                               relatedBy: .equal,
                               toItem: view, attribute: .top,
                               multiplier: 1.0, constant: 0).isActive = true
            NSLayoutConstraint(item: titleLabel,
                               attribute: .leading,
                               relatedBy: .equal, toItem: view,
                               attribute: .leading,
                               multiplier: 1.0,
                               constant: 0).isActive = true
            NSLayoutConstraint(item: titleLabel, attribute: .trailing,
                               relatedBy: .equal,
                               toItem: view,
                               attribute: .trailing,
                               multiplier: 1.0,
                               constant: 0).isActive = true

                titleLabel.heightAnchor.constraint(equalToConstant: 50).isActive = true
        }
        self.titleLabel = titleLabel

        let flowLayout = UICollectionViewFlowLayout()
        let margin: CGFloat = 15.0
        flowLayout.minimumInteritemSpacing = margin
        flowLayout.minimumLineSpacing = margin
        flowLayout.sectionInset = UIEdgeInsets(
            top: margin,
            left: margin,
            bottom: margin,
            right: margin)
        let collectionView = UICollectionView.init(frame: .zero, collectionViewLayout: flowLayout)
        self.view.addSubview(collectionView)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = UIColor.white
        collectionView.register(
            ImageCell.self,
            forCellWithReuseIdentifier: cellReuseIdentifier)

        collectionView.translatesAutoresizingMaskIntoConstraints = false
        if #available(iOS 11.0, *) {
            collectionView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 0).isActive = true
            collectionView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
            collectionView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        } else {
            NSLayoutConstraint(item: collectionView,
                               attribute: .top,
                               relatedBy: .equal,
                               toItem: view, attribute: .top,
                               multiplier: 1.0, constant: 0).isActive = true
            NSLayoutConstraint(item: collectionView,
                               attribute: .leading,
                               relatedBy: .equal, toItem: view,
                               attribute: .leading,
                               multiplier: 1.0,
                               constant: 0).isActive = true
            NSLayoutConstraint(item: collectionView, attribute: .trailing,
                               relatedBy: .equal,
                               toItem: view,
                               attribute: .trailing,
                               multiplier: 1.0,
                               constant: 0).isActive = true

            collectionView.heightAnchor.constraint(equalToConstant: 50).isActive = true
        }
        self.imageCollectionView = collectionView

        // Add refreh control to support pull to refresh
        refreshControl.attributedTitle = NSAttributedString(string: "Fetching data...")
        refreshControl.addTarget(
            self,
            action: #selector(refresh(sender:)),
            for: UIControl.Event.valueChanged)
        
        // Add Ref resh Control to Table View
        if #available(iOS 10.0, *) {
            collectionView.refreshControl = refreshControl
        } else {
            collectionView.addSubview(refreshControl)
        }
    }
    
    @objc func refresh(sender: AnyObject) {
        loadContent()
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int) -> Int {
        guard let images = images else {
            return 0
        }
        return images.count
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellReuseIdentifier, for: indexPath) as! ImageCell
        let imageInfo = images![indexPath.row]
        cell.setUp(imageData: imageInfo);

        guard let url = imageInfo.imageURL else {
            cell.setImage(imageData: nil)
            return cell
        }
        let cachedImageData = imageCache.object(forKey: url.absoluteString as NSString)
        if cachedImageData != nil {
            print("Cached image")
            cell.setImage(imageData: (cachedImageData! as Data))
            return cell
        }
        downloadImage(url: url, cell: cell)
        return cell
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let flowLayout = collectionViewLayout as! UICollectionViewFlowLayout

        let totalSpace = flowLayout.sectionInset.left
            + flowLayout.sectionInset.right
            + (flowLayout.minimumInteritemSpacing * CGFloat(cellsPerRow - 1))

        let size = CGFloat((collectionView.bounds.width - totalSpace) / CGFloat(cellsPerRow))
        return CGSize(width: size, height: size)
    }

    func downloadImage(url: URL, cell: ImageCell) {
        DispatchQueue.global(qos: .userInitiated).async {
            Alamofire.request(url, method: .get).responseData(completionHandler: { (response) in
                switch response.result {
                case .success:
                    guard let imageData = response.data else {
                        cell.setImage(imageData: nil)
                        print("Invalid image data")
                        return
                    }
                    self.imageCache.setObject(imageData as NSData, forKey: url.absoluteString as NSString)
                    cell.setImage(imageData: imageData)
                    print("Display image")
                    break
                case .failure:
                    cell.setImage(imageData: nil)
                    print("Failed to fetch image")
                    break
                }
            })
        }
    }
}
