//
//  Hero.swift
//  StarMaze
//
//  Created by Pedro Ruíz on 6/4/15.
//  Copyright (c) 2015 Pedro Ruíz. All rights reserved.
//

import Foundation
import SpriteKit

class Hero: SKNode {
    
    var objectSprite: SKSpriteNode?
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder): has not been implemented")
    }
    
    override init() {
        super.init()
        
        objectSprite = SKSpriteNode(imageNamed: "hero")
        self.addChild(objectSprite!)
        
        
    }
}
