//
//  EndGameScene.swift
//  StarMaze
//
//  Created by Pedro Ruíz on 6/10/15.
//  Copyright (c) 2015 Pedro Ruíz. All rights reserved.
//

import UIKit
import SpriteKit
import AVFoundation

class EndGameScene: SKScene {
    var bgSoundPlayer:AVAudioPlayer?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    
    override init(size: CGSize) {
        super.init(size: size)
        
    }
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        if (bgSoundPlayer != nil) {
            
            bgSoundPlayer!.stop()
            bgSoundPlayer = nil
            
        }
        
        let reveal = SKTransition.fadeWithDuration(0.5)
        let gameScene = GameScene(size: self.size)
        self.view!.presentScene(gameScene, transition: reveal)
    }
    
    
    
    func playBackgroundSound(name:String) {
        
        if (bgSoundPlayer != nil) {
            
            bgSoundPlayer!.stop()
            bgSoundPlayer = nil
            
        }
        
        let fileURL:NSURL = NSBundle.mainBundle().URLForResource( name , withExtension: "mp3")!
        
        bgSoundPlayer = AVAudioPlayer(contentsOfURL: fileURL, error: nil)
        
        
        bgSoundPlayer!.volume = 0.5  //half volume
        bgSoundPlayer!.numberOfLoops = -1
        bgSoundPlayer!.prepareToPlay()
        bgSoundPlayer!.play()
        
        
    }
    
    override func didMoveToView(view: SKView) {
        let gameOverSound = SKAction.playSoundFileNamed("gameOver.mp3", waitForCompletion: false)
        self.runAction(gameOverSound)
        
        //playBackgroundSound("gameOver.mp3")
        self.backgroundColor = SKColor.blackColor()
        
        let scoreLabel = SKLabelNode(fontNamed: "BMgermar")
        scoreLabel.fontSize = 60
        scoreLabel.fontColor = SKColor.whiteColor()
        scoreLabel.position = CGPoint(x: self.size.width / 2, y: self.size.height / 2)
        scoreLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.Center
        scoreLabel.text = String(format: "Score: %d" , GameState.sharedInstance.score)
        addChild(scoreLabel)
        
        let highScoreLabel = SKLabelNode(fontNamed: "BMgermar")
        highScoreLabel.fontSize = 60
        highScoreLabel.fontColor = SKColor.whiteColor()
        highScoreLabel.position = CGPoint(x: self.size.width / 2, y: self.size.height / 2 - 120)
        highScoreLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.Center
        highScoreLabel.text = String(format: "High Score: %d" , GameState.sharedInstance.highScore)
        addChild(highScoreLabel)
        
        let TryAgain = SKLabelNode(fontNamed: "BMgermar")
        TryAgain.fontSize = 30
        TryAgain.fontColor = SKColor.whiteColor()
        TryAgain.position = CGPoint(x: self.size.width / 2, y: 50)
        TryAgain.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.Center
        TryAgain.text = "Tap To Try Again"
        addChild(TryAgain)

    }

    
}
