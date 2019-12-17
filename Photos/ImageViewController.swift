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
    let cellReuseIdentifier = "imageCell"
    let cellsPerRow: CGFloat = 1
    var imageCollectionView: UICollectionView?
    lazy var refreshControl = UIRefreshControl()
    var titleLabel: UILabel?

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        loadUI()
        loadContent()
    }

    func loadContent() {
        Alamofire.request(jsonURL, method: .get).responseString { response in
            switch response.result {
                case .success:
                    let string = response.result.value
                    let data = string!.data(using: .utf8)!
                    do {
                        if let jsonObject = try JSONSerialization.jsonObject(
                            with: data,
                        options : .allowFragments) as? [String: Any] {
                            let imageBookData = ImageBook(jsonObject)
                            DispatchQueue.main.async {
                                self.images = imageBookData.rows
                                self.titleLabel!.text = imageBookData.title // Set the title
                                self.imageCollectionView?.reloadData()
                                self.refreshControl.endRefreshing()
                            }
                        } else {
                            print("bad json")
                        }
                    } catch let error as NSError {
                        print("Error: \(error)")
                    }
                case .failure(_):
                    break
            }
        }
    }
    
    func loadUI() {
        let titleLabel = UILabel.init(frame: CGRect.init(
            x: 0,
            y: 0,
            width: self.view.frame.width,
            height: 100))
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
        titleLabel.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        titleLabel.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        titleLabel.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        titleLabel.heightAnchor.constraint(equalToConstant: 60).isActive = true
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

        let collectionView = UICollectionView.init(
            frame: CGRect.init(
                x: 0,
                y: titleLabel.frame.height,
                width: self.view.frame.width,
                height: self.view.frame.height - titleLabel.frame.height),
            collectionViewLayout: flowLayout)
        self.view.addSubview(collectionView)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = UIColor.white
        collectionView.register(
            ImageCell.self,
            forCellWithReuseIdentifier: cellReuseIdentifier)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
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
        downloadImage(url: imageInfo.imageURL, cell: cell)
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

    func downloadImage(url: String?, cell: ImageCell) {
        guard let url = url else {
            cell.setImage(imageData: nil)
            return
        }

        DispatchQueue.global(qos: .userInitiated).async {
            Alamofire.request(url, method: .get).responseData(completionHandler: { (response) in
                switch response.result {
                case .success:
                    guard let imageData = response.data else {
                        cell.setImage(imageData: nil)
                        print("Invalid image data")
                        return
                    }
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
