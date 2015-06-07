//
//  Enemy.swift
//  StarMaze
//
//  Created by Pedro Ruíz on 6/7/15.
//  Copyright (c) 2015 Pedro Ruíz. All rights reserved.
//

import Foundation
import SpriteKit

class Enemy: SKNode {
    //MARK: - Initializers
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder): has not been implemented")
    }

    init (fromSKSWithImage image:String) {
        super.init()
        let enemySprite = SKSpriteNode(imageNamed: image)
        addChild(enemySprite)
    }
    
    init(theDict:Dictionary<NSObject, AnyObject>){
        super.init()
        
        let theX:String = theDict["x"] as AnyObject? as! String
        let x:Int =  theX.toInt()!
        
        
        let theY:String = theDict["y"] as AnyObject? as! String
        let y:Int =  theY.toInt()!
        
        
        let location:CGPoint = CGPoint(x: x, y: y * -1)
        
        let image = theDict["name"] as AnyObject? as! String
        
        let enemySprite = SKSpriteNode( imageNamed:image)
        
        self.position = CGPoint(x: location.x + (enemySprite.size.width / 2) , y: location.y - (enemySprite.size.height / 2)) 
        
        addChild(enemySprite)
    }

    
}
