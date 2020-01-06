//
//  ViewController.swift
//  Photos
//
//  Created by Sowmya J G on 08/12/19.
//  Copyright © 2019 Sowmya J G. All rights reserved.
//

import UIKit
import Alamofire
import UserNotifications
@available(iOS 10.0, *)
class ViewController: UIViewController,
                                    UICollectionViewDelegate,
                                    UICollectionViewDataSource,
                                    UICollectionViewDelegateFlowLayout {

    let jsonURL: String = "https://dl.dropboxusercontent.com/s/2iodh4vg0eortkl/facts.json"
    var images: [ImageData]?
    let imageCollectionView: UICollectionView = {

            let feedLayout = CustomFlowLayout()
            let collectionView = UICollectionView(frame: .zero, collectionViewLayout: feedLayout)
             return collectionView
    }()
    lazy var refreshControl = UIRefreshControl()
    var titleLabel: UILabel?
    let imageCache = NSCache<NSString, NSData>()
    let cellReuseIdentifier = "imageCell"
    let cellsPerRow: CGFloat = (UIDevice.current.userInterfaceIdiom == .phone) ? 1 : 2
    let separatorDecorationView = "separator"


    override func viewDidLoad() {
        super.viewDidLoad()
        
        let content = UNMutableNotificationContent()
        content.badge = 1
        content.title = "Chat Notification"
        content.subtitle = "Ramesh has sent you something!"
        content.body = "Hey, Where are you?"
        content.sound = UNNotificationSound.default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
        
        let request = UNNotificationRequest(identifier: "LocalNotification", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
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
                                self.imageCollectionView.reloadData()
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

        
    self.imageCollectionView.collectionViewLayout.register(SeparatorView.self, forDecorationViewOfKind: separatorDecorationView)

//        let flowLayout = CustomFlowLayout()
//        let margin: CGFloat = 15.0
//        flowLayout.minimumInteritemSpacing = margin
//        flowLayout.minimumLineSpacing = margin
//        flowLayout.sectionInset = UIEdgeInsets(
//            top: margin,
//            left: margin,
//            bottom: margin,
//            right: margin)
//        let collectionView = UICollectionView.init(frame: .zero, collectionViewLayout: flowLayout)
        self.view.addSubview(self.imageCollectionView)
        imageCollectionView.delegate = self
        imageCollectionView.dataSource = self
        imageCollectionView.backgroundColor = UIColor.white
        imageCollectionView.register(
            ImageCell.self,
            forCellWithReuseIdentifier: cellReuseIdentifier)

        imageCollectionView.translatesAutoresizingMaskIntoConstraints = false
        if #available(iOS 11.0, *) {
            imageCollectionView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 0).isActive = true
            imageCollectionView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
            imageCollectionView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
            imageCollectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        } else {
            NSLayoutConstraint(item: imageCollectionView,
                               attribute: .top,
                               relatedBy: .equal,
                               toItem: view, attribute: .top,
                               multiplier: 1.0, constant: 0).isActive = true
            NSLayoutConstraint(item: imageCollectionView,
                               attribute: .leading,
                               relatedBy: .equal, toItem: view,
                               attribute: .leading,
                               multiplier: 1.0,
                               constant: 0).isActive = true
            NSLayoutConstraint(item: imageCollectionView, attribute: .trailing,
                               relatedBy: .equal,
                               toItem: view,
                               attribute: .trailing,
                               multiplier: 1.0,
                               constant: 0).isActive = true

            imageCollectionView.heightAnchor.constraint(equalToConstant: 50).isActive = true
        }
//        self.imageCollectionView = collectionView

        // Add refreh control to support pull to refresh
        refreshControl.attributedTitle = NSAttributedString(string: "Fetching data...")
        refreshControl.addTarget(
            self,
            action: #selector(refresh(sender:)),
            for: UIControl.Event.valueChanged)
        
        // Add Ref resh Control to Table View
        if #available(iOS 10.0, *) {
            imageCollectionView.refreshControl = refreshControl
        } else {
            imageCollectionView.addSubview(refreshControl)
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

        guard let url = imageInfo.imageURL, url != "", url != " " else {
            cell.setImage(imageData: nil)
            return cell
        }
        let cachedImageData = imageCache.object(forKey: url as NSString)
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

    func downloadImage(url: String, cell: ImageCell) {
        DispatchQueue.global(qos: .userInitiated).async {
            Alamofire.request(url, method: .get).responseData(completionHandler: { (response) in
                switch response.result {
                case .success:
                    guard let imageData = response.data else {
                        cell.setImage(imageData: nil)
                        print("Invalid image data")
                        return
                    }
                    self.imageCache.setObject(imageData as NSData, forKey: url as NSString)
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
