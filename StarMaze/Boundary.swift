//
//  Boundary.swift
//  StarMaze
//
//  Created by Pedro Ruíz on 6/5/15.
//  Copyright (c) 2015 Pedro Ruíz. All rights reserved.
//

import Foundation
import SpriteKit

class Boundary: SKNode {
    
    //MARK: - Initializers
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder): has not been implemented")
    }
    
    init(fromSKSwithRect rect:CGRect) {
        super.init()
        
        let newLocation = CGPoint(x: -(rect.size.width/2), y: -(rect.size.height/2))
        let newRect = CGRect(origin: newLocation, size: rect.size)
        createBoundary(newRect)
        
    }
    
    func createBoundary (rect: CGRect) {
        let shape = SKShapeNode(rect: rect, cornerRadius: 19)
        shape.fillColor = SKColor.clearColor()
        shape.strokeColor = SKColor.whiteColor()
        shape.lineWidth = 1
        
        addChild(shape)
        
        self.physicsBody! = SKPhysicsBody(rectangleOfSize: rect.size)
        self.physicsBody!.dynamic = false
        self.physicsBody!.categoryBitMask = BodyType.boundary.rawValue
        self.physicsBody!.friction = 0
        self.physicsBody!.allowsRotation = false
        
        self.zPosition = 100
    }
}
