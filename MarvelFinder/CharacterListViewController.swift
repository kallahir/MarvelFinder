//
//  ViewController.swift
//  MarvelFinder
//
//  Created by Itallo Rossi Lucas on 28/12/16.
//  Copyright © 2016 Kallahir Labs. All rights reserved.
//

import UIKit
import AlamofireImage

class CharacterListViewController: UITableViewController {
    
    let requests = MarvelRequests()
    
    var offset = 0
    var result: SearchResult!
    
    var loadMoreFlag = false
    var loadErrorFlag = false
    
    var selectedCharacter: Character!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.loadCharacterList(offset: self.offset)
    }
    
    // MARK: TableView
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if self.result == nil || indexPath.row == self.result?.characters?.count {
            if self.loadErrorFlag {
                let cell = tableView.dequeueReusableCell(withIdentifier: "CharacterListRetryCell", for: indexPath) as! CharacterListRetryCell
                
                cell.tryAgainLabel.text = NSLocalizedString("Cell.tryAgain", comment: "")
                
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "CharacterListLoadingCell", for: indexPath) as! CharacterListLoadingCell
                
                cell.loadingIndicator.startAnimating()
                
                return cell
            }
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "CharacterListCell", for: indexPath) as! CharacterListCell
        
        let urlString = "\(self.result.characters![indexPath.row].thumbnail!)/landscape_incredible.\(self.result.characters![indexPath.row].thumbFormat!)"
        
        cell.characterImage.af_setImage(withURL: URL(string: urlString)!, placeholderImage: UIImage(named: "placeholder_list"), imageTransition: UIImageView.ImageTransition.crossDissolve(0.3))
        cell.characterName.text = self.result.characters![indexPath.row].name
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if self.result == nil || indexPath.row == self.result?.characters?.count {
            return 88
        }
        
        return 185
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.result != nil {
            return (self.result.characters?.count)! + 1
        }
        
        return 1
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if self.result == nil || indexPath.row == self.result?.characters?.count {
            if self.loadErrorFlag {
                self.loadErrorFlag = false
                self.tableView.reloadData()
                self.loadCharacterList(offset: self.offset)
                return
            }
            return
        }
        
        self.selectedCharacter = self.result.characters![indexPath.row]
        self.performSegue(withIdentifier: "DetailFromList", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "DetailFromList" {
            let characterDetailVC = segue.destination as! CharacterDetailViewController
            characterDetailVC.character = self.selectedCharacter
        }
        
        let backItem = UIBarButtonItem()
        backItem.title = NSLocalizedString("Navigation.back", comment: "")
        navigationItem.backBarButtonItem = backItem
    }

    // MARK: Load more
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offset = scrollView.contentOffset.y
        let maxOffset = scrollView.contentSize.height - scrollView.frame.size.height
        
        if (maxOffset - offset) <= 55 {
            self.loadMore()
        }
    }
    
    func loadMore(){
        if self.loadMoreFlag == true {
            self.loadMoreFlag = false
            let offset = self.offset + 20
            
            if self.result != nil {
                if offset > self.result.total! {
                    return
                }
            }
            
            self.loadCharacterList(offset: offset)
        }
    }
    
    // MARK: Util
    func loadCharacterList(offset: Int) {
        self.requests.getCharacterList(offset: offset) { (result) in
            guard let result = result else {
                self.refreshTable(loadMore: false, loadError: true, offset: offset)
                return
            }
            
            if self.result == nil {
                self.result = result
            } else {
                for character in (result.characters)! {
                    self.result.characters?.append(character)
                }
            }
            
            self.refreshTable(loadMore: true, loadError: false, offset: offset)
        }
    }
    
    func refreshTable(loadMore: Bool, loadError: Bool, offset: Int) {
        DispatchQueue.main.sync {
            self.offset = offset
            self.loadMoreFlag = loadMore
            self.loadErrorFlag = loadError
            self.tableView.reloadData()
        }
    }
    
}
