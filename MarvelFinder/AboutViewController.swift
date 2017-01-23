//
//  AboutViewController.swift
//  MarvelFinder
//
//  Created by Itallo Rossi Lucas on 02/01/17.
//  Copyright © 2017 Kallahir Labs. All rights reserved.
//

import UIKit

class AboutViewController: UITableViewController {
    
    @IBOutlet weak var appIcon: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.appIcon.layer.cornerRadius = 20.0
        self.appIcon.clipsToBounds = true
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.section == 1 {
            UIApplication.shared.open(NSURL(string:"https://www.linkedin.com/in/itallorossi") as! URL, options: [:], completionHandler: nil)
        }
        if indexPath.section == 2 {
            UIApplication.shared.open(NSURL(string:"itms-apps://itunes.apple.com/app/id1198060663") as! URL, options: [:], completionHandler: nil)
        }
    }
    
    override func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        if indexPath.section == 2 {
            UIApplication.shared.open(NSURL(string:"itms-apps://itunes.apple.com/app/id1198060663") as! URL, options: [:], completionHandler: nil)
        }
    }
    
    @IBAction func openReviconSite(_ sender: Any) {
        UIApplication.shared.open(NSURL(string:"http://www.flaticon.com/authors/revicon") as! URL, options: [:], completionHandler: nil)
    }
    
    @IBAction func openFlaticonSite(_ sender: Any) {
        UIApplication.shared.open(NSURL(string:"http://www.flaticon.com/") as! URL, options: [:], completionHandler: nil)
    }
    
    @IBAction func openIcons8Site(_ sender: Any) {
        UIApplication.shared.open(NSURL(string:"http://www.icons8.com/") as! URL, options: [:], completionHandler: nil)
    }
    
    @IBAction func openMarvelSite(_ sender: Any) {
        UIApplication.shared.open(NSURL(string:"http://www.marvel.com/") as! URL, options: [:], completionHandler: nil)
    }
}
