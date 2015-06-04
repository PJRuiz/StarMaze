//
//  GameScene.swift
//  StarMaze
//
//  Created by Pedro Ruíz on 6/4/15.
//  Copyright (c) 2015 Pedro Ruíz. All rights reserved.
//

//MARK: - Import Frameworks
import SpriteKit


class GameScene: SKScene {
    
    //MARK: - Instance Variables
    var currentSpeed: Float = 0
    var heroLocation: CGPoint = CGPointZero
    var mazeWorld: SKNode?
    var hero:Hero?
    
    
    //MARK: -
    override func didMoveToView(view: SKView) {

        mazeWorld = childNodeWithName("mazeWorld")
        heroLocation = mazeWorld!.childNodeWithName("StartingPoint")!.position
        
        hero = Hero()
        hero!.position = heroLocation
        
        mazeWorld!.addChild(hero!)
        
    }
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        /* Called when a touch begins */
        
        for touch in (touches as! Set<UITouch>) {
            let location = touch.locationInNode(self)
            
        }
    }
   
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
    }
}
