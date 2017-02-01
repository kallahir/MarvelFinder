//
//  MarvelRequests.swift
//  MarvelFinder
//
//  Created by Itallo Rossi Lucas on 06/01/17.
//  Copyright © 2017 Kallahir Labs. All rights reserved.
//

import Foundation
import SwiftHash
import ObjectMapper

class MarvelRequests {
    
    var publicKey   = ""
    var privateKey  = ""
    let baseURL     = "https://gateway.marvel.com:443/v1/public/"
    
    init(){
        let path = Bundle.main.path(forResource: "MarvelAPIKeys", ofType: "plist")
        
        if let keys = NSDictionary(contentsOfFile: path!) as? Dictionary<String, String> {
            self.publicKey = keys["PublicKey"]!
            self.privateKey = keys["PrivateKey"]!
        } else {
            return
        }
    }
    
    func getCharacterList(offset: Int, completion: @escaping (_ result: SearchResult?) -> Void) {
        self.startActivity()
        let ts = Date().timeIntervalSince1970.description.replacingOccurrences(of: ".", with: "")
        let hash = MD5("\(ts)\(self.privateKey)\(self.publicKey)")
        let url = URL(string: "\(self.baseURL)characters?orderBy=name&limit=20&offset=\(offset)&ts=\(ts)&apikey=\(self.publicKey)&hash=\(hash.lowercased())")
        
        DispatchQueue.main.async {
            self.getDataFromUrl(url: url!) { (data, response, error) in
                guard let data = data, error == nil else {
                    self.stopActivity()
                    completion(nil)
                    return
                }
                
                let text = String(data: data, encoding: String.Encoding.utf8)
                let result = SearchResult(JSONString: text!)

                if (result?.statusCode)! >= 300 {
                    completion(nil)
                    return
                }
                
                self.stopActivity()
                completion(result!)
            }
        }
    }
    
    func searchCharacter(name: String, offset: Int, completion: @escaping (_ result: SearchResult?) -> Void) {
        self.startActivity()
        let ts = Date().timeIntervalSince1970.description.replacingOccurrences(of: ".", with: "")
        let hash = MD5("\(ts)\(self.privateKey)\(self.publicKey)")
        let url = URL(string: "\(self.baseURL)characters?nameStartsWith=\(name)&orderBy=name&limit=10&offset=\(offset)&ts=\(ts)&apikey=\(self.publicKey)&hash=\(hash.lowercased())")
        
        DispatchQueue.main.async {
            self.getDataFromUrl(url: url!) { (data, response, error) in
                guard let data = data, error == nil else {
                    self.stopActivity()
                    completion(nil)
                    return
                }
                
                let text = String(data: data, encoding: String.Encoding.utf8)
                let result = SearchResult(JSONString: text!)
                
                if (result?.statusCode)! >= 300 {
                    completion(nil)
                    return
                }
                
                self.stopActivity()
                completion(result!)
            }
        }
    }
    
    func getCollectionList(characterId: Int, collectionType: String, offset: Int, completion: @escaping (_ result: Collection?) -> Void) {
        self.startActivity()
        let ts = Date().timeIntervalSince1970.description.replacingOccurrences(of: ".", with: "")
        let hash = MD5("\(ts)\(self.privateKey)\(self.publicKey)")
        let url = URL(string: "\(self.baseURL)characters/\(characterId)/\(collectionType)?limit=20&offset=\(offset)&ts=\(ts)&apikey=\(self.publicKey)&hash=\(hash.lowercased())")
        
        DispatchQueue.main.async {
            self.getDataFromUrl(url: url!) { (data, response, error) in
                guard let data = data, error == nil else {
                    self.stopActivity()
                    completion(nil)
                    return
                }
                
                let text = String(data: data, encoding: String.Encoding.utf8)
                let result = Collection(JSONString: text!)
                
                if (result?.statusCode)! >= 300 {
                    completion(nil)
                    return
                }
                
                self.stopActivity()
                completion(result!)
            }
        }
    }
    
    func getDataFromUrl(url: URL, completion: @escaping (_ data: Data?, _  response: URLResponse?, _ error: Error?) -> Void) {
        URLSession.shared.dataTask(with: url) {
            (data, response, error) in
            completion(data, response, error)
            }.resume()
    }
    
    func startActivity() {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }

    func stopActivity() {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
    
}
