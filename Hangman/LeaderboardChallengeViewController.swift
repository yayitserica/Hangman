//
//  LeaderboardChallengeViewController.swift
//  Hangman
//
//  Created by Enrique Torrendell on 2/17/17.
//  Copyright © 2017 Tor. All rights reserved.
//

import UIKit
import Firebase

class LeaderboardChallengeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    /* Please find same comments in LeaderboardSingleViewController */

    // MARK: - Outlets 
    
    @IBOutlet weak var background: UIImageView!
    @IBOutlet weak var challengeButton: UITabBarItem!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var userPic: UIImageView!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var userPoints: UILabel!
    @IBOutlet weak var userPosition: UILabel!
    
    // MARK: - Variables
    
    let store = HangmanData.sharedInstance
    let database = FIRDatabase.database().reference()
    var userSimplePosition = String()
    
    // MARK: - Loads
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        retrieveUserPoints()
        
        background.image = store.chalkboard
        tabBarController?.tabBar.transparentNavigationBar()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        tableView.reloadData()
    }
    
    // MARK: - Methods 
    
    func retrieveUserInfo(url: String, image: UIImageView, position: String, name: String, points: String) {
        
        let profileImgUrl = URL(string: url)
        
        image.contentMode = .scaleAspectFill
        image.setRounded()
        image.clipsToBounds = true
        image.sd_setImage(with: profileImgUrl)
        
        userPosition.text = position + "."
        userName.text = name
        userPoints.text = points
    }
    
    func retrieveUserPoints() {
        
        database.child("leaderboardChallenge").observe(.value, with: { (snapshot) in
            
            if snapshot.exists() == false {
                
                self.retrieveUserInfo(url: self.store.user.profilePic, image: self.userPic, position: "???", name: self.store.user.username, points: self.store.user.scoreChallenge)
                
            } else {
                
                guard let data = snapshot.value as? [String : String] else { return }
                
                var key = Array(data.keys)
                
                key.sort { (o1, o2) -> Bool in
                    
                    return Int32(data[o1]!)! > Int32(data[o2]!)!
                }
                
                self.store.leaderboardChallenge = key
                
                if let position = self.store.leaderboardChallenge.index(where: {$0 == self.store.user.id}) {
                    
                    self.userSimplePosition = "\(Int(position) + 1)" 
                    self.retrieveUserInfo(url: self.store.user.profilePic, image: self.userPic, position: self.userSimplePosition, name: self.store.user.username, points: self.store.user.scoreChallenge)
                    self.tableView.reloadData()
                    
                } else {
                    
                    self.retrieveUserInfo(url: self.store.user.profilePic, image: self.userPic, position: "???", name: self.store.user.username, points: "???")
                    self.tableView.reloadData()
                }
            }
        })
    }
    
    // MARK: - Methods TableView 
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.store.leaderboardChallenge.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "challengeCell", for: indexPath) as! ChallengeTableViewCell
        let user = self.store.leaderboardChallenge[indexPath.row]
        
        
        self.database.child("users").child(user).observeSingleEvent(of: .value, with: { (snapshot) in
            
            let data = snapshot.value as? [String:Any]
            let user = User(id: "", username: "", email: "", profilePic: "", scoreSingle: "", singleWon: "", singleLost: "", scoreChallenge: "", scoreMultiplayer: "")
            let userSelected = user.deserialize(data!)
            
            DispatchQueue.main.async {
                
                cell.retrieveUserInfo(url: userSelected.profilePic, image: cell.userPic, position: indexPath.row + 1, name: userSelected.username, points: userSelected.scoreChallenge)
                
                cell.backgroundColor = UIColor.clear
                cell.selectionStyle = .none
            }
        })
        
        return cell
    }
}

class ChallengeTableViewCell: UITableViewCell {
    
    // MARK: - Outlets
    
    @IBOutlet weak var userPic: UIImageView!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var userPoints: UILabel!
    @IBOutlet weak var userPosition: UILabel!
    
    // MARK: - Methods 
    
    func retrieveUserInfo(url: String, image: UIImageView, position: Int, name: String, points: String) {
        
        let profileImgUrl = URL(string: url)
        
        image.contentMode = .scaleAspectFill
        image.setRounded()
        image.clipsToBounds = true
        image.sd_setImage(with: profileImgUrl)
        
        userPosition.text = "\(position)."
        userName.text = name
        userPoints.text = points
    }

}
