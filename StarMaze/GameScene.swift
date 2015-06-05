//
//  GameScene.swift
//  StarMaze
//
//  Created by Pedro Ruíz on 6/4/15.
//  Copyright (c) 2015 Pedro Ruíz. All rights reserved.
//

//MARK: - Import Frameworks
import SpriteKit

enum BodyType:UInt32 {
    case hero = 1
    case boundary = 2
    case sensorUp = 4
    case sensorDown = 8
    case sensorRight = 16
    case sensorLeft = 32
    case star = 64
    case enemy = 128
    case boundary2 = 256
}

class GameScene: SKScene {
    
    //MARK: - Instance Variables
    var currentSpeed: Float = 5
    var heroLocation: CGPoint = CGPointZero
    var mazeWorld: SKNode?
    var hero:Hero?
    
    
    //MARK: - Initialize View
    override func didMoveToView(view: SKView) {
        
        self.backgroundColor = SKColor.blackColor()
        view.showsPhysics = true
        
        self.physicsWorld.gravity = CGVector(dx: 0, dy: 0)

        mazeWorld = childNodeWithName("mazeWorld")
        heroLocation = mazeWorld!.childNodeWithName("StartingPoint")!.position
        
        hero = Hero()
        hero!.position = heroLocation
        
        mazeWorld!.addChild(hero!)
        
        hero!.currentSpeed = currentSpeed
        
        //MARK: Gestures
        
        let waitAction = SKAction.waitForDuration(0.5)
        self.runAction(waitAction, completion: {
            let swipeRight = UISwipeGestureRecognizer(target: self, action: Selector("swipedRight:"))
            swipeRight.direction = .Right
            view.addGestureRecognizer(swipeRight)
            
            let swipeLeft = UISwipeGestureRecognizer(target: self, action: Selector("swipedLeft:"))
            swipeLeft.direction = .Left
            view.addGestureRecognizer(swipeLeft)
            
            let swipeUp = UISwipeGestureRecognizer(target: self, action: Selector("swipedUp:"))
            swipeUp.direction = .Up
            view.addGestureRecognizer(swipeUp)
            
            let swipeDown = UISwipeGestureRecognizer(target: self, action: Selector("swipedDown:"))
            swipeDown.direction = .Down
            view.addGestureRecognizer(swipeDown)
            
        })
        
        
    }
    
    //MARK: - Touch Functions
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        /* Called when a touch begins */
        
        for touch in (touches as! Set<UITouch>) {
            let location = touch.locationInNode(self)
            
        }
    }
    
    func swipedRight (sender: UISwipeGestureRecognizer) {
        hero!.goRight()
    }
    
    func swipedLeft (sender: UISwipeGestureRecognizer) {
        hero!.goLeft()
    }
    
    func swipedUp (sender: UISwipeGestureRecognizer) {
         hero!.goUp()
    }
    
    func swipedDown (sender: UISwipeGestureRecognizer) {
        hero!.goDown()
    }
    
   
    //MARK: - Update Cycle
    override func update(currentTime: CFTimeInterval) {
        hero!.update()
    }
    
    
    
}
