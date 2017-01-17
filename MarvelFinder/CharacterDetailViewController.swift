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
    @IBOutlet weak var seriesCollectionView: UICollectionView!
    @IBOutlet weak var storiesCollectionView: UICollectionView!
    @IBOutlet weak var eventsCollectionView: UICollectionView!
    
    var urls = Dictionary<String, String>()
    
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
        
//        self.seriesCollectionView.delegate = self
//        self.seriesCollectionView.dataSource = self
//        
//        self.storiesCollectionView.delegate = self
//        self.storiesCollectionView.dataSource = self
//        
//        self.eventsCollectionView.delegate = self
//        self.eventsCollectionView.dataSource = self
        
        self.requests.getCollectionList(characterId: self.character.id!, collectionType: "comics", offset: self.comicsOffset, completion: { (result) in
            self.comicsCollection = result
            
            DispatchQueue.main.sync {
                self.comicsLoadMore = true
                self.comicsCollectionView.reloadData()
            }
        })
    }
    
    // MARK: Collection View
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.numberOfItems(collectionView: collectionView)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if self.comicsCollection != nil {
            if collectionView == self.comicsCollectionView {
                if self.comicsCollection.items!.count == indexPath.row {
                    let cell = self.comicsCollectionView.dequeueReusableCell(withReuseIdentifier: "CollectionLoadCell", for: indexPath) as! CharacterDetailCollectionLoadingCell
                    
                    cell.loadingIndicator.startAnimating()
                    
                    return cell
                }
                
                if self.comicsCollection.items!.count == 0 {
                    let cell = self.comicsCollectionView.dequeueReusableCell(withReuseIdentifier: "CollectionMessageCell", for: indexPath) as! CharacterDetailCollectionMessageCell
                    
                    cell.messageLabel.text = "No records found."
                    
                    return cell
                }
                
                let cell = self.comicsCollectionView.dequeueReusableCell(withReuseIdentifier: "CollectionCell", for: indexPath) as! CharacterDetailCollectionCell
                
                let urlString = "\(self.comicsCollection.items![indexPath.row].thumbnail!)/portrait_medium.\(self.comicsCollection.items![indexPath.row].thumbFormat!)"
                
                cell.collectionImage.af_setImage(withURL: URL(string: urlString)!, placeholderImage: UIImage(named: "placeholder_search"), imageTransition: UIImageView.ImageTransition.crossDissolve(0.3))
                cell.collectionName.text = self.comicsCollection.items![indexPath.row].name
                
                return cell
            }
        }
        
        let cell = self.comicsCollectionView.dequeueReusableCell(withReuseIdentifier: "CollectionLoadCell", for: indexPath) as! CharacterDetailCollectionLoadingCell
        
        cell.loadingIndicator.startAnimating()
        
        return cell
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
        
        if indexPath.section == 5 {
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
                print("ERRO")
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        if indexPath.section == 5 {
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
                print("ERRO")
            }
        }
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
            
            self.requests.getCollectionList(characterId: self.character.id!, collectionType: "comics", offset: self.comicsOffset, completion: { (result) in
                for item in result.items! {
                    self.comicsCollection.items!.append(item)
                }
                
                DispatchQueue.main.sync {
                    self.comicsLoadMore = true
                    self.comicsCollectionView.reloadData()
                }
            })
        }
    }
    
    // MARK: Util
    func openRelatedLink(linkType: String) {
        if let relatedLink = urls[linkType] {
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
        default:
            break
        }
        
        return numberOfItems
    }
    
}
