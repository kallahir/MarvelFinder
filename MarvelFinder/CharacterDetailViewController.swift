//
//  CharacterDetailViewController.swift
//  MarvelFinder
//
//  Created by Itallo Rossi Lucas on 08/01/17.
//  Copyright © 2017 Kallahir Labs. All rights reserved.
//

import UIKit
import AlamofireImage

class CharacterDetailViewController: UITableViewController, UICollectionViewDelegate, UICollectionViewDataSource {

    let requests = MarvelRequests()
    
    var character: Character!
    @IBOutlet weak var characterImage: UIImageView!
    @IBOutlet weak var characterName: UILabel!
    @IBOutlet weak var characterDescription: UITextView!
    
    @IBOutlet weak var comicsCollectionView: UICollectionView!
    var comicsCollection: Collection!
    var comicsOffset   = 0
    var comicsLoadMore = false
    var comicsLoadError = false
    @IBOutlet weak var seriesCollectionView: UICollectionView!
    var seriesCollection: Collection!
    var seriesOffset   = 0
    var seriesLoadMore = false
    var seriesLoadError = false
    @IBOutlet weak var storiesCollectionView: UICollectionView!
    @IBOutlet weak var eventsCollectionView: UICollectionView!
    
    var urls = Dictionary<String, String>()
    // TODO: don't forget to update it!
    private let relatedLinksSection = 2
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let urlString = "\(self.character!.thumbnail!)/landscape_xlarge.\(self.character!.thumbFormat!)"
        
        self.characterName.text = self.character!.name
        self.characterImage.af_setImage(withURL: URL(string: urlString)!, placeholderImage: UIImage(named: "placeholder_search"), imageTransition: UIImageView.ImageTransition.crossDissolve(0.3))
        
        if (self.character!.description?.isEmpty)! {
            self.characterDescription.text = "No description available."
        } else {
            self.characterDescription.text = self.character!.description
        }
        
        for url in self.character!.urls! {
            urls[url.linkType!] = url.linkURL!
        }
        
        self.comicsCollectionView.delegate = self
        self.comicsCollectionView.dataSource = self
        
        self.seriesCollectionView.delegate = self
        self.seriesCollectionView.dataSource = self

//        self.storiesCollectionView.delegate = self
//        self.storiesCollectionView.dataSource = self
//        
//        self.eventsCollectionView.delegate = self
//        self.eventsCollectionView.dataSource = self
        
        self.loadCollectionList(characterId: self.character.id!, collectionType: "comics", offset: self.comicsOffset) { (result) in
            self.comicsCollection = result
            self.refreshCollectionView("comics", loadMore: true, loadError: false)
        }
        
        self.loadCollectionList(characterId: self.character.id!, collectionType: "series", offset: self.seriesOffset) { (result) in
            self.seriesCollection = result
            self.refreshCollectionView("series", loadMore: true, loadError: false)
        }
    }
    
    // MARK: Collection View
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.numberOfItems(collectionView: collectionView)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == self.comicsCollectionView {
            return getCell(collectionView: self.comicsCollectionView, collection: self.comicsCollection, indexPath: indexPath, loadError: self.comicsLoadError)
        }
        
        return getCell(collectionView: self.seriesCollectionView, collection: self.seriesCollection, indexPath: indexPath, loadError: self.seriesLoadError)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == self.comicsCollectionView {
            if self.comicsCollection == nil || indexPath.row == self.comicsCollection.items!.count {
                if self.comicsLoadError {
                    print("[TRY AGAIN COMICS...]")
                    return
                }
                return
            }
        }
        
        if self.seriesCollection == nil || indexPath.row == self.seriesCollection.items!.count {
            if self.seriesLoadError {
                print("[TRY AGAIN SERIES...]")
                return
            }
            return
        }
    }
    
    // MARK: Table View
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return self.characterDescription.contentSize.height+15
        }
        
        return super.tableView(tableView, heightForRowAt: indexPath)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tableView.deselectRow(at: indexPath, animated: true)
        self.selectRelatedLink(indexPath: indexPath)
    }
    
    override func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        self.selectRelatedLink(indexPath: indexPath)
    }
    
    // MARK: Load More
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offset = scrollView.contentOffset.x
        let maxOffset = scrollView.contentSize.width - scrollView.frame.size.width
        
        if (maxOffset - offset) <= 55 {
            switch scrollView {
            case self.comicsCollectionView:
                self.loadMoreComics()
                break
            case self.seriesCollectionView:
                self.loadMoreSeries()
                break
            default:
                break
            }
        }
    }
    
    func loadMoreComics() {
        if self.comicsLoadMore == true {
            self.comicsLoadMore = false
            self.comicsOffset += 20
            
            if self.comicsCollection != nil {
                if self.comicsOffset >= self.comicsCollection.total! {
                    return
                }
            }
            
            self.loadCollectionList(characterId: self.character.id!, collectionType: "comics", offset: self.comicsOffset, completion: { (result) in
                if result != nil {
                    for item in (result?.items!)! {
                        self.comicsCollection.items!.append(item)
                    }
                }
                self.refreshCollectionView("comics", loadMore: true, loadError: false)
            })
        }
    }
    
    func loadMoreSeries() {
        if self.seriesLoadMore == true {
            self.seriesLoadMore = false
            self.seriesOffset += 20
            
            if self.seriesCollection != nil {
                if self.seriesOffset >= self.seriesCollection.total! {
                    return
                }
            }
            
            self.loadCollectionList(characterId: self.character.id!, collectionType: "series", offset: self.seriesOffset, completion: { (result) in
                if result != nil {
                    for item in (result?.items!)! {
                        self.seriesCollection.items!.append(item)
                    }
                }
                self.refreshCollectionView("series", loadMore: true, loadError: false)
            })
        }
    }
    
    // MARK: Util
    func selectRelatedLink(indexPath: IndexPath) {
        if indexPath.section == self.relatedLinksSection {
            switch indexPath.row {
            case 0:
                self.openRelatedLink(linkType: "detail")
                break
            case 1:
                self.openRelatedLink(linkType: "wiki")
                break
            case 2:
                self.openRelatedLink(linkType: "comiclink")
                break
            default:
                break
            }
        }
    }
    
    func openRelatedLink(linkType: String) {
        if let relatedLink = self.urls[linkType] {
            UIApplication.shared.open(NSURL(string: relatedLink) as! URL, options: [:], completionHandler: nil)
        } else {
            UIApplication.shared.open(NSURL(string:"http://www.marvel.com/") as! URL, options: [:], completionHandler: nil)
        }
    }
    
    func numberOfItems(collectionView: UICollectionView) -> Int {
        var numberOfItems = 1
        
        switch collectionView {
        case self.comicsCollectionView:
            if self.comicsCollection != nil {
                if self.comicsCollection.count! != 0 {
                    numberOfItems = self.comicsCollection.items!.count
                    
                    if !(self.comicsCollection.items!.count >= self.comicsCollection.total!) {
                        numberOfItems += 1
                    }
                }
            }
            break
        case self.seriesCollectionView:
            if self.seriesCollection != nil {
                if self.seriesCollection.count! != 0 {
                    numberOfItems = self.seriesCollection.items!.count
                    
                    if !(self.seriesCollection.items!.count >= self.seriesCollection.total!) {
                        numberOfItems += 1
                    }
                }
            }
            break
        default:
            break
        }
        
        return numberOfItems
    }
    
    func getCell<T>(collectionView: UICollectionView, collection: Collection!, indexPath: IndexPath, loadError: Bool) -> T {
        if collection != nil {
            if collection.items!.count == 0 {
                return self.noRecordsFoundCell(collectionView: collectionView, indexPath: indexPath, text: "No records found.") as! T
            }
            
            if collection.items!.count == indexPath.row {
                if loadError {
                    return self.retryCell(collectionView: collectionView, indexPath: indexPath, text: "Try again...") as! T
                }
                
                return self.loadingCell(collectionView: collectionView, indexPath: indexPath) as! T
            }
            
            return collectionCell(collectionView: collectionView, indexPath: indexPath, item: collection.items![indexPath.row]) as! T
        }
        
        if collection == nil {
            if loadError {
                return self.retryCell(collectionView: collectionView, indexPath: indexPath, text: "Try again...") as! T
            }
        }
        
        return self.loadingCell(collectionView: collectionView, indexPath: indexPath) as! T
    }
    
    // MARK: Collections cells
    func noRecordsFoundCell(collectionView: UICollectionView, indexPath: IndexPath, text: String) -> CharacterDetailCollectionMessageCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CollectionMessageCell", for: indexPath) as! CharacterDetailCollectionMessageCell
        
        cell.messageLabel.text = text
        
        return cell
    }
    
    func retryCell(collectionView: UICollectionView, indexPath: IndexPath, text: String) -> CharacterDetailCollectionRetryCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CollectionRetryCell", for: indexPath) as! CharacterDetailCollectionRetryCell
        
        cell.retryLabel.text = text
        
        return cell
    }
    
    func loadingCell(collectionView: UICollectionView, indexPath: IndexPath) -> CharacterDetailCollectionLoadingCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CollectionLoadCell", for: indexPath) as! CharacterDetailCollectionLoadingCell
        
        cell.loadingIndicator.startAnimating()
        
        return cell
    }
    
    func collectionCell(collectionView: UICollectionView, indexPath: IndexPath, item: CollectionItem) -> CharacterDetailCollectionCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CollectionCell", for: indexPath) as! CharacterDetailCollectionCell
        
        let urlString = "\(item.thumbnail!)/portrait_medium.\(item.thumbFormat!)"
        
        cell.collectionImage.af_setImage(withURL: URL(string: urlString)!, placeholderImage: UIImage(named: "placeholder_search"), imageTransition: UIImageView.ImageTransition.crossDissolve(0.3))
        cell.collectionName.text = item.name
        
        return cell
    }
    
    // MARK: Request Util
    func loadCollectionList(characterId: Int, collectionType: String, offset: Int, completion: @escaping (_ result: Collection?) -> Void) {
        self.requests.getCollectionList(characterId: characterId, collectionType: collectionType, offset: offset, completion: { (result) in
            guard let result = result else {
                self.refreshCollectionView(collectionType, loadMore: false, loadError: true)
                return
            }
            
            completion(result)
        })
    }

    func refreshCollectionView(_ collectionType: String, loadMore: Bool, loadError: Bool) {
        switch collectionType {
        case "comics":
            DispatchQueue.main.sync {
                self.comicsLoadMore = loadMore
                self.comicsLoadError = loadError
                self.comicsCollectionView.reloadData()
            }
            break
        case "series":
            DispatchQueue.main.sync {
                self.seriesLoadMore = loadMore
                self.seriesLoadError = loadError
                self.seriesCollectionView.reloadData()
            }
            break
        default:
            break
        }
    }
    
}
