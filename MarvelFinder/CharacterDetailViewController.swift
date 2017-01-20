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
    var storiesCollection: Collection!
    var storiesOffset   = 0
    var storiesLoadMore = false
    var storiesLoadError = false
    @IBOutlet weak var eventsCollectionView: UICollectionView!
    var eventsCollection: Collection!
    var eventsOffset   = 0
    var eventsLoadMore = false
    var eventsLoadError = false
    
    var selectedCollectionItem: CollectionItem!
    var selectedCollectionTitle: String!
    
    var urls = Dictionary<String, String>()
    private let relatedLinksSection = 5
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let urlString = "\(self.character!.thumbnail!)/landscape_xlarge.\(self.character!.thumbFormat!)"
        
        self.characterName.text = self.character!.name
        self.characterImage.af_setImage(withURL: URL(string: urlString)!, placeholderImage: UIImage(named: "placeholder_search"), imageTransition: UIImageView.ImageTransition.crossDissolve(0.3))
        
        if (self.character!.description?.isEmpty)! {
            self.characterDescription.text = NSLocalizedString("Detail.noDescription", comment: "")
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

        self.storiesCollectionView.delegate = self
        self.storiesCollectionView.dataSource = self
        
        self.eventsCollectionView.delegate = self
        self.eventsCollectionView.dataSource = self
        
        self.loadCollectionList(characterId: self.character.id!, collectionType: "comics", offset: self.comicsOffset) { (result) in
            self.comicsCollection = result
            self.refreshCollectionView("comics", loadMore: true, loadError: false, offset: self.comicsOffset)
        }
        
        self.loadCollectionList(characterId: self.character.id!, collectionType: "series", offset: self.seriesOffset) { (result) in
            self.seriesCollection = result
            self.refreshCollectionView("series", loadMore: true, loadError: false, offset: self.seriesOffset)
        }
        
        self.loadCollectionList(characterId: self.character.id!, collectionType: "stories", offset: self.storiesOffset) { (result) in
            self.storiesCollection = result
            self.refreshCollectionView("stories", loadMore: true, loadError: false, offset: self.storiesOffset)
        }
        
        self.loadCollectionList(characterId: self.character.id!, collectionType: "events", offset: self.eventsOffset) { (result) in
            self.eventsCollection = result
            self.refreshCollectionView("events", loadMore: true, loadError: false, offset: self.eventsOffset)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowCollectionItem" {
            let collectionDetailVC = segue.destination as! CollectionItemDetailViewController
            collectionDetailVC.collectionItem = self.selectedCollectionItem
            collectionDetailVC.collectionType = self.selectedCollectionTitle
        }
        
        let backItem = UIBarButtonItem()
        backItem.title = NSLocalizedString("Navigation.back", comment: "")
        navigationItem.backBarButtonItem = backItem
    }
    
    // MARK: Collection View
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.numberOfItems(collectionView: collectionView)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == self.comicsCollectionView {
            return getCell(collectionView: self.comicsCollectionView, collection: self.comicsCollection, indexPath: indexPath, loadError: self.comicsLoadError)
        }
        
        if collectionView == self.seriesCollectionView {
            return getCell(collectionView: self.seriesCollectionView, collection: self.seriesCollection, indexPath: indexPath, loadError: self.seriesLoadError)
        }
        
        if collectionView == self.storiesCollectionView {
            return getCell(collectionView: self.storiesCollectionView, collection: self.storiesCollection, indexPath: indexPath, loadError: self.storiesLoadError)
        }

        return getCell(collectionView: self.eventsCollectionView, collection: self.eventsCollection, indexPath: indexPath, loadError: self.eventsLoadError)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == self.comicsCollectionView {
            if self.comicsCollection == nil || indexPath.row == self.comicsCollection.items!.count {
                if self.comicsLoadError {
                    self.comicsLoadError = false
                    self.comicsCollectionView.reloadData()
                    
                    self.loadCollectionList(characterId: self.character.id!, collectionType: "comics", offset: self.comicsOffset) { (result) in
                        if self.comicsCollection == nil {
                            self.comicsCollection = result
                        } else {
                            for item in (result?.items!)! {
                                self.comicsCollection.items!.append(item)
                            }
                        }
                        self.refreshCollectionView("comics", loadMore: true, loadError: false, offset: self.comicsOffset)
                    }
                    return
                }
                return
            }
            self.selectedCollectionItem = self.comicsCollection.items![indexPath.row]
            self.selectedCollectionTitle = "Comics"
            self.performSegue(withIdentifier: "ShowCollectionItem", sender: self)
        }
        
        if collectionView == self.seriesCollectionView {
            if self.seriesCollection == nil || indexPath.row == self.seriesCollection.items!.count {
                if self.seriesLoadError {
                    self.seriesLoadError = false
                    self.seriesCollectionView.reloadData()
                    
                    self.loadCollectionList(characterId: self.character.id!, collectionType: "series", offset: self.seriesOffset) { (result) in
                        if self.seriesCollection == nil {
                            self.seriesCollection = result
                        } else {
                            for item in (result?.items!)! {
                                self.seriesCollection.items!.append(item)
                            }
                        }
                        self.refreshCollectionView("series", loadMore: true, loadError: false, offset: self.seriesOffset)
                    }
                    return
                }
                return
            }
        }
        
        if collectionView == self.storiesCollectionView {
            if self.storiesCollection == nil || indexPath.row == self.storiesCollection.items!.count {
                if self.storiesLoadError {
                    self.storiesLoadError = false
                    self.storiesCollectionView.reloadData()
                    
                    self.loadCollectionList(characterId: self.character.id!, collectionType: "stories", offset: self.storiesOffset) { (result) in
                        if self.storiesCollection == nil {
                            self.storiesCollection = result
                        } else {
                            for item in (result?.items!)! {
                                self.storiesCollection.items!.append(item)
                            }
                        }
                        self.refreshCollectionView("stories", loadMore: true, loadError: false, offset: self.storiesOffset)
                    }
                    return
                }
                return
            }
        }

        if self.eventsCollection == nil || indexPath.row == self.eventsCollection.items!.count {
            if self.eventsLoadError {
                self.eventsLoadError = false
                self.eventsCollectionView.reloadData()
                
                self.loadCollectionList(characterId: self.character.id!, collectionType: "events", offset: self.eventsOffset) { (result) in
                    if self.eventsCollection == nil {
                        self.eventsCollection = result
                    } else {
                        for item in (result?.items!)! {
                            self.eventsCollection.items!.append(item)
                        }
                    }
                    self.refreshCollectionView("events", loadMore: true, loadError: false, offset: self.eventsOffset)
                }
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
                self.loadMore(loadMore: &self.comicsLoadMore, offset: self.comicsOffset, collection: self.comicsCollection, collectionType: "comics", completion: { (result,offset) in
                    if result != nil {
                        for item in (result?.items!)! {
                            self.comicsCollection.items!.append(item)
                        }
                    }
                    self.refreshCollectionView("comics", loadMore: true, loadError: false, offset: offset)
                })
                break
            case self.seriesCollectionView:
                self.loadMore(loadMore: &self.seriesLoadMore, offset: self.seriesOffset, collection: self.seriesCollection, collectionType: "series", completion: { (result,offset) in
                    if result != nil {
                        for item in (result?.items!)! {
                            self.seriesCollection.items!.append(item)
                        }
                    }
                    self.refreshCollectionView("series", loadMore: true, loadError: false, offset: offset)
                })
                break
            case self.storiesCollectionView:
                self.loadMore(loadMore: &self.storiesLoadMore, offset: self.storiesOffset, collection: self.storiesCollection, collectionType: "stories", completion: { (result,offset) in
                    if result != nil {
                        for item in (result?.items!)! {
                            self.storiesCollection.items!.append(item)
                        }
                    }
                    self.refreshCollectionView("stories", loadMore: true, loadError: false, offset: offset)
                })
                break
            case self.eventsCollectionView:
                self.loadMore(loadMore: &self.eventsLoadMore, offset: self.eventsOffset, collection: self.eventsCollection, collectionType: "events", completion: { (result,offset) in
                    if result != nil {
                        for item in (result?.items!)! {
                            self.eventsCollection.items!.append(item)
                        }
                    }
                    self.refreshCollectionView("events", loadMore: true, loadError: false, offset: offset)
                })
                break
            default:
                break
            }
        }
    }
    
    func loadMore(loadMore: inout Bool, offset: Int, collection: Collection!, collectionType: String, completion: @escaping (_ result: Collection?, _ offset: Int) -> Void) {
        if loadMore == true {
            loadMore = false
            let offsetTemp = offset + 20
            
            if collection != nil {
                if offsetTemp >= collection.total! {
                    return
                }
            }
            
            self.loadCollectionList(characterId: self.character.id!, collectionType: collectionType, offset: offsetTemp, completion: { (result) in
                completion(result, offsetTemp)
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
        case self.storiesCollectionView:
            if self.storiesCollection != nil {
                if self.storiesCollection.count! != 0 {
                    numberOfItems = self.storiesCollection.items!.count
                    
                    if !(self.storiesCollection.items!.count >= self.storiesCollection.total!) {
                        numberOfItems += 1
                    }
                }
            }
            break
        case self.eventsCollectionView:
            if self.eventsCollection != nil {
                if self.eventsCollection.count! != 0 {
                    numberOfItems = self.eventsCollection.items!.count
                    
                    if !(self.eventsCollection.items!.count >= self.eventsCollection.total!) {
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
    
    // MARK: Collections cells
    func getCell<T>(collectionView: UICollectionView, collection: Collection!, indexPath: IndexPath, loadError: Bool) -> T {
        if collection != nil {
            if collection.items!.count == 0 {
                return self.noRecordsFoundCell(collectionView: collectionView, indexPath: indexPath, text: NSLocalizedString("Cell.noResults", comment: "")) as! T
            }
            
            if collection.items!.count == indexPath.row {
                if loadError {
                    return self.retryCell(collectionView: collectionView, indexPath: indexPath, text: NSLocalizedString("Cell.tryAgain", comment: "")) as! T
                }
                
                return self.loadingCell(collectionView: collectionView, indexPath: indexPath) as! T
            }
            
            return collectionCell(collectionView: collectionView, indexPath: indexPath, item: collection.items![indexPath.row]) as! T
        }
        
        if collection == nil {
            if loadError {
                return self.retryCell(collectionView: collectionView, indexPath: indexPath, text: NSLocalizedString("Cell.tryAgain", comment: "")) as! T
            }
        }
        
        return self.loadingCell(collectionView: collectionView, indexPath: indexPath) as! T
    }
    
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
        
        let urlString = "\(item.thumbnail ?? "nothing")/portrait_medium.\(item.thumbFormat ?? "nothing")"
        
        cell.collectionImage.af_setImage(withURL: URL(string: urlString)!, placeholderImage: UIImage(named: "placeholder_search"), imageTransition: UIImageView.ImageTransition.crossDissolve(0.3))
        cell.collectionName.text = item.name
        
        return cell
    }
    
    // MARK: Request Util
    func loadCollectionList(characterId: Int, collectionType: String, offset: Int, completion: @escaping (_ result: Collection?) -> Void) {
        self.requests.getCollectionList(characterId: characterId, collectionType: collectionType, offset: offset, completion: { (result) in
            guard let result = result else {
                self.refreshCollectionView(collectionType, loadMore: false, loadError: true, offset: offset)
                return
            }
            
            completion(result)
        })
    }

    func refreshCollectionView(_ collectionType: String, loadMore: Bool, loadError: Bool, offset: Int) {
        switch collectionType {
        case "comics":
            DispatchQueue.main.sync {
                self.comicsOffset = offset
                self.comicsLoadMore = loadMore
                self.comicsLoadError = loadError
                self.comicsCollectionView.reloadData()
            }
            break
        case "series":
            DispatchQueue.main.sync {
                self.seriesOffset = offset
                self.seriesLoadMore = loadMore
                self.seriesLoadError = loadError
                self.seriesCollectionView.reloadData()
            }
            break
        case "stories":
            DispatchQueue.main.sync {
                self.storiesOffset = offset
                self.storiesLoadMore = loadMore
                self.storiesLoadError = loadError
                self.storiesCollectionView.reloadData()
            }
            break
        case "events":
            DispatchQueue.main.sync {
                self.eventsOffset = offset
                self.eventsLoadMore = loadMore
                self.eventsLoadError = loadError
                self.eventsCollectionView.reloadData()
            }
            break
        default:
            break
        }
    }
    
}
