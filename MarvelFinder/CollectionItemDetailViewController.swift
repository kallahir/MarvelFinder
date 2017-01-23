
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
    @IBOutlet weak var collectionLinkButton: UIButton!
    
    var collectionItem: CollectionItem!
    var collectionType: String!
    
    override func viewDidLoad() {
        let urlString = "\(self.collectionItem.thumbnail ?? "nothing")/portrait_incredible.\(self.collectionItem.thumbFormat ?? "nothing")"
        
        self.collectionImage.af_setImage(withURL: URL(string: urlString)!, placeholderImage: UIImage(named: "placeholder_collection_item"), imageTransition: UIImageView.ImageTransition.crossDissolve(0.3))
        self.collectionTitle.text = self.collectionItem.name
        
        self.navigationItem.title = NSLocalizedString(self.collectionType, comment: "")
        
        let label = self.collectionLinkButton.titleLabel
        label?.minimumScaleFactor = 0.5
        label?.adjustsFontSizeToFitWidth = true
        self.collectionLinkButton.setTitle(NSLocalizedString("Cell.marvelAck", comment: ""), for: .normal)
    }
    
    @IBAction func linkBackToMarvel(_ sender: Any) {
        UIApplication.shared.open(NSURL(string:"http://www.marvel.com/") as! URL, options: [:], completionHandler: nil)
    }
    
}
