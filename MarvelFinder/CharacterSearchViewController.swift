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
    var searchText = ""
    var searchingIndicator: UIActivityIndicatorView!
    
    var offset = 0
    var result: SearchResult!
    
    var loadMoreFlag = false
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
            
            self.requests.searchCharacter(name: self.searchText, offset: self.offset, completion: { (result) in
                self.result = result
                
                DispatchQueue.main.sync {
                    self.searchingIndicator.stopAnimating()
                    self.loadMoreFlag = true
                    self.newSearchFlag = false
                    self.tableView.reloadData()
                }
            })
        } else {
            let alert = UIAlertController(title: "Invalid Text", message: "Please do not insert emojis and other symbols.", preferredStyle: UIAlertControllerStyle.alert)
            let action = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(action)
            
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    // MARK: TableView
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if self.result.count == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "CharacterNotFoundCell", for: indexPath)
            
            cell.textLabel?.text = "No results found"
            
            return cell
        }
        
        if indexPath.row == self.result.characters!.count {
            if self.result.characters!.count >= self.result.total! {
                let cell = tableView.dequeueReusableCell(withIdentifier: "CharacterNotFoundCell", for: indexPath)
                
                cell.textLabel?.text = "Data provided by Marvel. © 2014 Marvel"
                
                return cell
            }
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "CharacterSearchLoadingCell", for: indexPath) as! CharacterSearchLoadingCell
            
            cell.loadingIndicator.startAnimating()
            
            return cell
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
            
//            if self.result.characters!.count >= self.result.total! {
//                return (self.result.characters?.count)!
//            }
            
            return (self.result.characters?.count)! + 1
        }
        
        return 0
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
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
            self.offset += 10
            
            if self.result != nil {
                if self.offset >= self.result.total! {
                    return
                }
            }
            
            self.requests.searchCharacter(name: self.searchText, offset: self.offset, completion: { (result) in
                for character in (result.characters)! {
                    self.result.characters?.append(character)
                }
                
                DispatchQueue.main.sync {
                    self.loadMoreFlag = true
                    self.tableView.reloadData()
                }
            })
        }
    }
    
}
