//
//  GameViewController.swift
//  Hangman
//
//  Created by Enrique Torrendell on 2/15/17.
//  Copyright © 2017 Tor. All rights reserved.
//

import UIKit
import Foundation
import Firebase

class GameViewController: UIViewController {
    
    // MARK: - Outlets
    
    @IBOutlet weak var background: UIImageView!
    @IBOutlet weak var livesLabel: UILabel!
    @IBOutlet weak var secretWordLabel: UILabel!
    @IBOutlet var keyboardButtons: [UIButton]!
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var hangmanImage: UIImageView!
    
    // MARK: - Variables
    
    let store = HangmanData.sharedInstance
    let database = FIRDatabase.database().reference()
    var lives = 6
    var secretWord = ""
    var wordCharacter = 0
    var hiddenWord = ""
    var points = 0
    var typeOfGame = String()
    var player: User!
    var groupID = ""
    
    // MARK: - Loads
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        background.image = store.chalkboard
        loadPlayerData()
        isKeyboardEnabled(status: false)
        newGame()
    }
    
    /* This method retrieves the user data and link it to our HangmanData store */
    func loadPlayerData() {
        
        database.child("users").child(self.store.user.id).observeSingleEvent(of: .value, with: { (snapshot) in
            
            self.store.user = User(snapshot: snapshot)
        })
    }
    
    // MARK: - Methods
    
    /* This method reset all the variables to be able to play a new game  */
    func newGame() {
        
        lives = 6
        livesLabel?.text = "\(lives)"
        
        secretWord = ""
        hiddenWord = ""
        wordCharacter = 0
        
        points = 0
        scoreLabel.text = "\(points)"
        
        for button in keyboardButtons {
            button.setTitleColor(.white, for: .normal)
        }
        
        letsPlay()
    }
    
    /* This method prepares the game */
    func letsPlay() {
        
        if let wordsFilePath = Bundle.main.path(forResource: "Dictionary", ofType: nil) {
            
            do {
                let wordsString = try String(contentsOfFile: wordsFilePath)
                
                let wordLines = wordsString.components(separatedBy: .newlines)
                
                let randomLine = wordLines[numericCast(arc4random_uniform(numericCast(wordLines.count)))]
                
                secretWord = randomLine.uppercased()
                print(secretWord)
                
                for _ in self.secretWord.characters {
                    
                    self.hiddenWord.append("_")
                }
                
                self.secretWordLabel.text = self.hiddenWord
                self.isKeyboardEnabled(status: true)
                
                
            } catch { // contentsOfFile throws an error
                print("Error: \(error)")
            }
        }
        
        // OLD CODE
        //        let allWords = Int(arc4random_uniform(UInt32(store.arrayOfWords.count)))
        //
        //        secretWord = store.arrayOfWords[allWords - 1].uppercased()
        //
        //        for _ in self.secretWord.characters {
        //
        //            self.hiddenWord.append("_")
        //        }
        //
        //        self.secretWordLabel.text = self.hiddenWord
        //        self.isKeyboardEnabled(status: true)
    }
    
    /* This method sets the keyboard to be enabled or not */
    func isKeyboardEnabled(status: Bool) {
        
        for button in keyboardButtons {
            
            button.isEnabled = status
        }
    }
    
    /* This method check if the letter selected is correct or not */
    func play(isCorrect: Bool, button: UIButton) {
        
        if isCorrect == true {
            
            button.isEnabled = false
            button.setTitleColor(Constants.Colors.chalkGreen, for: .normal)
            
            let buttonChar = button.titleLabel?.text?.characters.first!
            
            for (index, char) in secretWord.characters.enumerated() {
                
                if buttonChar == char {
                    
                    var newWord = ""
                    
                    for (newIndex, newChar) in hiddenWord.characters.enumerated() {
                        
                        if newIndex == index {
                            newWord.append(char)
                        } else {
                            newWord.append(newChar)
                        }
                    }
                    hiddenWord = newWord
                    secretWordLabel.text = hiddenWord
                    
                    updateScore(guessedRight: true)
                }
            }
        }
        
        if isCorrect == false {
            
            button.isEnabled = false
            button.setTitleColor(Constants.Colors.chalkRed, for: .normal)
            updateScore(guessedRight: false)
        }
    }
    
    /* This method updates the score od the user */
    func updateScore(guessedRight: Bool) {
        
        if guessedRight == true {
            points = points + 3
            winOrLose(test: "WON")
        }
        
        if guessedRight == false {
            lives = lives - 1
            livesLabel.text = "\(lives)"
            points = points - 1
            changeHangmanImage()
            winOrLose(test: "LOST")
        }
        
        if points >= 0 {
            scoreLabel.text = "+\(points)"
            
        } else {
            scoreLabel.text = "\(points)"
        }
    }
    
    /* This changes the hangman image as the user loses lives */
    // TODO: We can do this better
    func changeHangmanImage() {
        
        if lives == 6 {
            hangmanImage.image = UIImage(named: "HangmanLogo0")
        }
        
        if lives == 5 {
            hangmanImage.image = UIImage(named: "HangmanLogo1")
        }
        
        if lives == 4 {
            hangmanImage.image = UIImage(named: "HangmanLogo2")
        }
        
        if lives == 3 {
            hangmanImage.image = UIImage(named: "HangmanLogo3")
        }
        
        if lives == 2 {
            hangmanImage.image = UIImage(named: "HangmanLogo4")
        }
        
        if lives == 1 {
            hangmanImage.image = UIImage(named: "HangmanLogo5")
        }
        
        if lives == 0 {
            hangmanImage.image = UIImage(named: "HangmanLogo6")
        }
        
        //        if lives == -1 {
        //            hangmanImage.image = UIImage(named: "HangmanLogo6")
        //
        //        }
    }
    
    /* This method checks if the user won or lost. */
    func winOrLose(test: String) {
        
        if test == "WON" {
            if secretWord == hiddenWord {
                gameEnded(result: "WON", pointsEarned: 10)
            }
        }
        
        if test == "LOST" {
            if lives < 1 {
                gameEnded(result: "LOST", pointsEarned: -10)
            }
        }
    }
    
    /* Once the game finished, this method updates all the different databases. */
    // TODO: We can do this better
    func gameEnded(result: String, pointsEarned: Int) {
        
        isKeyboardEnabled(status: false)
        store.playerWon = result
        points = points + pointsEarned
        
        let root = database.child("game").childByAutoId()
        let gameID = root.key
        
        let newGame = Game(id: gameID, player: store.user.id, type: typeOfGame, date: getDate(date: Date()), result: result, score: "\(points)", lives: "\(lives)")
        
        database.child("games").child(gameID).setValue(newGame.serialize())
        
        if typeOfGame == "SINGLE" {
            database.child("playedSingle").child(store.user.id).child(gameID).setValue(getDate(date: Date()))
            
            if self.store.user.scoreSingle == "" {
                self.store.user.scoreSingle = "\(0 + self.points)"
            }
            else {
                self.store.user.scoreSingle = "\(Int32(self.store.user.scoreSingle)! + self.points)"
            }
            
            self.database.child("users").child(self.store.user.id).child("scoreSingle").setValue(self.store.user.scoreSingle)
            self.database.child("leaderboardSingle").child(self.store.user.id).setValue(self.store.user.scoreSingle)
            
            if result == "WON" {
                
                if self.store.user.singleWon == "" {
                    
                    self.store.user.singleWon = "\(1)"
                    
                } else {
                    
                    self.store.user.singleWon = "\(Int32(self.store.user.singleWon)! + 1)"
                }
                
                self.database.child("users").child(self.store.user.id).child("singleWon").setValue(self.store.user.singleWon)
            }
            
            if result == "LOST" {
                
                if self.store.user.singleLost == "" {
                    
                    self.store.user.singleLost = "\(1)"
                    
                } else {
                    
                    self.store.user.singleLost = "\(Int32(self.store.user.singleLost)! + 1)"
                }
                
                self.database.child("users").child(self.store.user.id).child("singleLost").setValue(self.store.user.singleLost)
            }
        }
        
        if typeOfGame == "CHALLENGE" {
            
            database.child("playedChallenge").child(store.user.id).child(getDate(date: Date())).setValue(gameID)
            
            if self.store.user.scoreChallenge == "" {
                self.store.user.scoreChallenge = "\(0 + self.points)"
            }
            else {
                self.store.user.scoreChallenge = "\(Int32(self.store.user.scoreChallenge)! + self.points)"
            }
            
            self.database.child("users").child(self.store.user.id).child("scoreChallenge").setValue(self.store.user.scoreChallenge)
            self.database.child("leaderboardChallenge").child(self.store.user.id).setValue(self.store.user.scoreChallenge)
        }
        
        if typeOfGame == "MULTIPLAYER" {
            
            if store.user.id == store.groupGame.player1Id {
                
                self.store.groupGame.player1Points = "\(Int32(self.store.groupGame.player1Points)! + self.points)"
                self.store.groupGame.player1Rounds = "\(Int32(self.store.groupGame.player1Rounds)! + 1)"
                
                database.child("multiplayer").child(self.store.groupGame.id).child("player1Points").setValue(store.groupGame.player1Points)
                database.child("multiplayer").child(self.store.groupGame.id).child("player1Rounds").setValue(self.store.groupGame.player1Rounds)
                
                if self.store.user.scoreMultiplayer == "" {
                    self.store.user.scoreMultiplayer = "\(0 + self.points)"
                }
                else {
                    self.store.user.scoreMultiplayer = "\(Int32(self.store.user.scoreMultiplayer)! + self.points)"
                }
                
                self.database.child("users").child(self.store.user.id).child("scoreMultiplayer").setValue(self.store.user.scoreMultiplayer)
                self.database.child("leaderboardMultiplayer").child(self.store.user.id).setValue(self.store.user.scoreMultiplayer)
            }
            
            if store.user.id == store.groupGame.player2Id {
                
                self.store.groupGame.player2Points = "\(Int32(self.store.groupGame.player2Points)! + self.points)"
                self.store.groupGame.player2Rounds = "\(Int32(self.store.groupGame.player2Rounds)! + 1)"
                
                database.child("multiplayer").child(self.store.groupGame.id).child("player2Points").setValue(store.groupGame.player2Points)
                database.child("multiplayer").child(self.store.groupGame.id).child("player2Rounds").setValue(self.store.groupGame.player2Rounds)
                
                if self.store.user.scoreMultiplayer == "" {
                    self.store.user.scoreMultiplayer = "\(0 + self.points)"
                }
                else {
                    self.store.user.scoreMultiplayer = "\(Int32(self.store.user.scoreMultiplayer)! + self.points)"
                }
                
                self.database.child("users").child(self.store.user.id).child("scoreMultiplayer").setValue(self.store.user.scoreMultiplayer)
                self.database.child("leaderboardMultiplayer").child(self.store.user.id).setValue(self.store.user.scoreMultiplayer)
            }
            
            if store.user.id == store.groupGame.player3Id {
                
                self.store.groupGame.player3Points = "\(Int32(self.store.groupGame.player3Points)! + self.points)"
                self.store.groupGame.player3Rounds = "\(Int32(self.store.groupGame.player3Rounds)! + 1)"
                
                database.child("multiplayer").child(self.store.groupGame.id).child("player3Points").setValue(store.groupGame.player3Points)
                database.child("multiplayer").child(self.store.groupGame.id).child("player3Rounds").setValue(self.store.groupGame.player3Rounds)
                
                if self.store.user.scoreMultiplayer == "" {
                    self.store.user.scoreMultiplayer = "\(0 + self.points)"
                }
                else {
                    self.store.user.scoreMultiplayer = "\(Int32(self.store.user.scoreMultiplayer)! + self.points)"
                }
                
                self.database.child("users").child(self.store.user.id).child("scoreMultiplayer").setValue(self.store.user.scoreMultiplayer)
                self.database.child("leaderboardMultiplayer").child(self.store.user.id).setValue(self.store.user.scoreMultiplayer)
            }
            
            if store.user.id == store.groupGame.player4Id {
                
                self.store.groupGame.player4Points = "\(Int32(self.store.groupGame.player4Points)! + self.points)"
                self.store.groupGame.player4Rounds = "\(Int32(self.store.groupGame.player4Rounds)! + 1)"
                
                database.child("multiplayer").child(self.store.groupGame.id).child("player4Points").setValue(store.groupGame.player4Points)
                database.child("multiplayer").child(self.store.groupGame.id).child("player4Rounds").setValue(self.store.groupGame.player4Rounds)
                
                if self.store.user.scoreMultiplayer == "" {
                    self.store.user.scoreMultiplayer = "\(0 + self.points)"
                }
                else {
                    self.store.user.scoreMultiplayer = "\(Int32(self.store.user.scoreMultiplayer)! + self.points)"
                }
                
                self.database.child("users").child(self.store.user.id).child("scoreMultiplayer").setValue(self.store.user.scoreMultiplayer)
                self.database.child("leaderboardMultiplayer").child(self.store.user.id).setValue(self.store.user.scoreMultiplayer)
            }
        }
        performSegue(withIdentifier: "resultSegue", sender: self)
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "resultSegue" {
            
            guard let dest = segue.destination as? ResultViewController else { return }
            
            if store.playerWon == "WON" {
                
                dest.gameResult = "YOU WON"
                dest.secretWord = secretWord
                dest.points = points
                newGame()
                loadPlayerData()
                
            }
            if store.playerWon == "LOST" {
                
                dest.gameResult = "YOU LOST"
                dest.secretWord = secretWord
                dest.points = points
                newGame()
                loadPlayerData()
            }
        }
    }
    
    /* Retrieves today's Date */
    func getDate(date: Date) -> String {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        return dateFormatter.string(from: date).uppercased()
    }
    
    // MARK: - Actions
    
    /* Method that check if the letter pressed is correct or not. */
    @IBAction func letterPressed(_ sender: UIButton) {
        
        let buttonTitle = sender.titleLabel?.text
        
        if secretWord.range(of: buttonTitle!) != nil {
            play(isCorrect: true, button: sender)
        }
        else {
            play(isCorrect: false, button: sender)
        }
    }
    
}


