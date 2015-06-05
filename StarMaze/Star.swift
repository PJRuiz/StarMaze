//
//  Star.swift
//  StarMaze
//
//  Created by Pedro Ruíz on 6/5/15.
//  Copyright (c) 2015 Pedro Ruíz. All rights reserved.
//

import Foundation
import SpriteKit

class Star: SKNode {
    var starSprite:SKSpriteNode?
    
    //MARK: - Initializers
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder): has not been implemented")
    }
    
    override init() {
        super.init()
        starSprite = SKSpriteNode(imageNamed: "star")
        addChild(starSprite!)
        
        createPhysicsBody()
        
    }
    
    init(fromTMXFileWithDict theDict:Dictionary<NSObject, AnyObject>) {
        super.init()
        
        let theX:String = theDict["x"] as AnyObject? as! String
        let x:Int = theX.toInt( )!
        
        let theY:String = theDict["y"] as AnyObject? as! String
        let y:Int = theY.toInt( )!
        
        let location = CGPoint(x: x, y: y * -1)
        
        starSprite = SKSpriteNode(imageNamed: "star")
        addChild(starSprite!)
        
        self.position = CGPoint(x: location.x + starSprite!.size.width/2, y: location.y - starSprite!.size.height/2)
        
        createPhysicsBody()

        
    }
    
    func createPhysicsBody () {
        self.physicsBody = SKPhysicsBody(circleOfRadius: starSprite!.size.width/2)
        
        self.physicsBody!.categoryBitMask = BodyType.star.rawValue
        self.physicsBody!.collisionBitMask = 0
        self.physicsBody!.contactTestBitMask = BodyType.hero.rawValue
        
        self.zPosition = 90
    }
    
}
