//
//  CharacterSearchViewController.swift
//  MarvelFinder
//
//  Created by Itallo Rossi Lucas on 29/12/16.
//  Copyright © 2016 Kallahir Labs. All rights reserved.
//

import UIKit
import SwiftHash
import ObjectMapper

class CharacterSearchViewController: UITableViewController, UISearchBarDelegate {
    
    let requests = MarvelRequests()
    
    let searchController = UISearchController(searchResultsController: nil)
    var searchingIndicator: UIActivityIndicatorView!
    var searchText = ""
    
    var offset = 0
    var result: SearchResult!
    
    var loadMoreFlag = false
    var loadErrorFlag = false
    var newSearchFlag = false
    
    var selectedCharacter: Character!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.searchingIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.whiteLarge)
        self.searchingIndicator.color = UIColor.system
        self.searchingIndicator.center = self.tableView.center
        
        self.searchController.searchBar.delegate = self
        self.searchController.dimsBackgroundDuringPresentation = false
        self.searchController.searchBar.isTranslucent   = false
        
        self.tableView.tableHeaderView = searchController.searchBar
        
        self.definesPresentationContext = true
        self.extendedLayoutIncludesOpaqueBars = true
        
        UISearchBar.appearance().barTintColor = UIColor.system
        UISearchBar.appearance().tintColor = UIColor.white
        UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self]).tintColor = UIColor.system

        self.searchController.searchBar.placeholder = "Character Name"
        self.searchController.searchBar.layer.borderWidth = 1
        self.searchController.searchBar.layer.borderColor = UIColor.system.cgColor
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    // MARK: Search
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.newSearchFlag = true
        
        self.result = nil
        self.tableView.reloadData()
        
        self.tableView.addSubview(self.searchingIndicator)
        self.searchingIndicator.startAnimating()
        
        if !searchBar.text!.containsEmoji {
            self.offset = 0
            self.searchText = searchBar.text!.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlHostAllowed)!
            self.searchCharacter(name: self.searchText, offset: self.offset)
        } else {
            self.invalidTextAlert()
        }
    }
    
    // MARK: TableView
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if self.result != nil {
            if self.result.count == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "CharacterNotFoundCell", for: indexPath)
                
                cell.textLabel?.text = "No results found"
                
                return cell
            }
            
            if indexPath.row == self.result?.characters?.count {
                if self.loadErrorFlag {
                    let cell = tableView.dequeueReusableCell(withIdentifier: "CharacterSearchRetryCell", for: indexPath) as! CharacterSearchRetryCell
                    
                    cell.retryLabel.text = "Click here and try again..."
                    
                    return cell
                }
                
                if self.result.characters!.count >= self.result.total! {
                    let cell = tableView.dequeueReusableCell(withIdentifier: "CharacterNotFoundCell", for: indexPath)
                    
                    cell.textLabel?.text = "Data provided by Marvel. © 2014 Marvel"
                    
                    return cell
                }
                
                let cell = tableView.dequeueReusableCell(withIdentifier: "CharacterSearchLoadingCell", for: indexPath) as! CharacterSearchLoadingCell
                
                cell.loadingIndicator.startAnimating()
                
                return cell
            }
        }
        
        if self.result == nil {
            if self.loadErrorFlag {
                let cell = tableView.dequeueReusableCell(withIdentifier: "CharacterSearchRetryCell", for: indexPath) as! CharacterSearchRetryCell
                
                cell.retryLabel.text = "Click here and try again..."
                
                return cell
            }
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "CharacterSearchCell", for: indexPath) as! CharacterSearchCell
        
        let urlString = "\(self.result.characters![indexPath.row].thumbnail!)/portrait_medium.\(self.result.characters![indexPath.row].thumbFormat!)"
        
        cell.characterImage.af_setImage(withURL: URL(string: urlString)!, placeholderImage: UIImage(named: "placeholder_search"), imageTransition: UIImageView.ImageTransition.crossDissolve(0.3))
        cell.characterName.text = self.result.characters![indexPath.row].name
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if self.result != nil {
            if self.result.count == 0 {
                return 44
            }
        }
        
        return 88
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.result != nil {
            if self.result.count == 0 {
                return 1
            }
            
            return (self.result.characters?.count)! + 1
        } else {
            if self.loadErrorFlag {
                return 1
            }
        }
        
        return 0
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if self.result == nil || indexPath.row == self.result?.characters?.count {
            if self.loadErrorFlag {
                self.loadErrorFlag = false
                self.tableView.reloadData()
                
                if self.result == nil {
                    self.searchingIndicator.startAnimating()
                }
                
                self.searchCharacter(name: self.searchText, offset: self.offset)
                return
            }
            return
        }
        
        self.selectedCharacter = self.result.characters![indexPath.row]
        tableView.deselectRow(at: indexPath, animated: true)
        self.performSegue(withIdentifier: "DetailFromSearch", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "DetailFromSearch" {
            let characterDetailVC = segue.destination as! CharacterDetailViewController
            characterDetailVC.character = self.selectedCharacter
        }
        
        let backItem = UIBarButtonItem()
        backItem.title = "Back"
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
        if self.loadMoreFlag == true && self.newSearchFlag == false {
            self.loadMoreFlag = false
            let offset = self.offset + 10
            
            if self.result != nil {
                if offset > self.result.total! && (offset - self.result.total!) <= 0 {
                    return
                }
            }
            
            self.searchCharacter(name: self.searchText, offset: offset)
        }
    }
    
    //MARK: Util
    func searchCharacter(name: String, offset: Int) {
        self.requests.searchCharacter(name: name, offset: offset, completion: { (result) in
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
        })
    }
    
    func refreshTable(loadMore: Bool, loadError: Bool, offset: Int) {
        DispatchQueue.main.sync {
            if offset == 0 {
                self.newSearchFlag = false
                self.searchingIndicator.stopAnimating()
            }
            self.offset = offset
            self.loadMoreFlag = loadMore
            self.loadErrorFlag = loadError
            self.tableView.reloadData()
        }
    }
    
    func invalidTextAlert() {
        let alert = UIAlertController(title: "Invalid Text", message: "Please do not insert emojis and other symbols.", preferredStyle: UIAlertControllerStyle.alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(action)
        
        self.present(alert, animated: true, completion: nil)
    }
}
