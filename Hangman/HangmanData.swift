//
//  HangmanData.swift
//  Hangman
//
//  Created by Enrique Torrendell on 2/16/17.
//  Copyright © 2017 Tor. All rights reserved.
//

import Foundation
import UIKit

class HangmanData {
    
    // MARK: - Properties
    
    static let sharedInstance = HangmanData()
    
    var arrayOfWords: [String] = []
    
    var user = User(id: "", username: "", email: "", profilePic: "")
    
    var chalkboard = UIImage(named: "Chalkboard")
    
    // MARK: - Initializers
    
    private init() {}
    
    // MARK: - Methods
    
//    func getWordFromAPI(completion: @escaping (String) -> Void) {
//        
//        print("We are getting into the Current Data raw information")
//        
//        var currentWord: String = ""
//        
//        HangmanAPI.getHangmanWord { (JSON) in
//            
//            let getWordPosition = Int(arc4random_uniform(UInt32(JSON.count)))
//            
//            
//            print("9a. We just load the CURRENT DATA")
//            print(getWordPosition)
//            
//            currentWord = JSON[getWordPosition - 1]
//            
//            completion(currentWord)
//        }
//    }
    
   }
