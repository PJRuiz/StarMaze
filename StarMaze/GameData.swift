//
//  GameData.swift
//  StarMaze
//
//  Created by Pedro Ruíz on 6/8/15.
//  Copyright (c) 2015 Pedro Ruíz. All rights reserved.
//

import Foundation

var livesLeft = 3
var currentLevel = 0
var firstSKSFile = "GameScene"
var currentSKSFile = firstSKSFile

class GameState {
    var score: Int
    var highScore: Int
    var stars: Int
    
    class var sharedInstance: GameState {
        struct Singleton {
            static let instance = GameState()
        }
        
        return Singleton.instance
    }
    
    init() {
        // Init
        score = 0
        highScore = 0
        stars = 0
        
        // Load game state
        let defaults = NSUserDefaults.standardUserDefaults()
        
        highScore = defaults.integerForKey("highScore")
        stars = defaults.integerForKey("stars")
    }
    
    func saveState() {
        // Update highScore if the current score is greater
        highScore = max(score, highScore)
        
        // Store in user defaults
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setInteger(highScore, forKey: "highScore")
        NSUserDefaults.standardUserDefaults().synchronize()
        
        GameState.sharedInstance.score = 0
    }
}
