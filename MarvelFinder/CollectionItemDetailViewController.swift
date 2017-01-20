
//
//  CollectionItemDetailViewController.swift
//  MarvelFinder
//
//  Created by Itallo Rossi Lucas on 20/01/17.
//  Copyright © 2017 Kallahir Labs. All rights reserved.
//

import UIKit

class CollectionItemDetailViewController: UIViewController {
    
    @IBOutlet weak var collectionImage: UIImageView!
    @IBOutlet weak var collectionTitle: UILabel!
    
    var collectionItem: CollectionItem!
    var collectionType: String!
    
    override func viewDidLoad() {
        let urlString = "\(self.collectionItem.thumbnail ?? "nothing")/portrait_fantastic.\(self.collectionItem.thumbFormat ?? "nothing")"
        
        self.collectionImage.af_setImage(withURL: URL(string: urlString)!, placeholderImage: UIImage(named: "placeholder_search"), imageTransition: UIImageView.ImageTransition.crossDissolve(0.3))
        self.collectionTitle.text = self.collectionItem.name
        
        self.navigationItem.title = self.collectionType
    }
    
}
