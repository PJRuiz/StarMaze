//
//  Hero.swift
//  StarMaze
//
//  Created by Pedro Ruíz on 6/4/15.
//  Copyright (c) 2015 Pedro Ruíz. All rights reserved.
//

import Foundation
import SpriteKit

enum Direction {
    case Up, Down, Right, Left, None
}

enum DesiredDirection {
    case Up, Down, RIght, Left, None
}


class Hero: SKNode {
    
    //MARK: - Properties
    var objectSprite: SKSpriteNode?
    
    var currentSpeed: Float = 5
    
    var currentDirection = Direction.Right
    var desiredDirection = Direction.None
    
    var movingAnimation:SKAction?
    
    
    //MARK: - Initializers
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder): has not been implemented")
    }
    
    override init( ) {
        super.init( )
        
        objectSprite = SKSpriteNode(imageNamed: "hero")
        self.addChild(objectSprite!)
        
        setupAnimation()
        runAnimation()
        
        let sizeMultiplier = 1.2
        
        let largerSize = CGSize(width: objectSprite!.size.width * 1.2 , height: objectSprite!.size.height * 1.2)
        self.physicsBody = SKPhysicsBody(rectangleOfSize: largerSize)
        // Frictionless
        self.physicsBody!.friction = 0
        // Kees the object within boundaries
        self.physicsBody!.dynamic = true
        // Bouncy
        self.physicsBody!.restitution = 0
        self.physicsBody!.allowsRotation = false
        self.physicsBody!.affectedByGravity = false
        
        //self.physicsBody!.mass
        //self.physicsBody!.density
        
        // What kind of Body Type is it
        self.physicsBody!.categoryBitMask = BodyType.hero.rawValue
        
        // Who is it going to interact with, by default it collides with everything
        //self.physicsBody!.collisionBitMask = 0
        
        // Who do you want to be notified if you come in contact with
        self.physicsBody!.contactTestBitMask = BodyType.boundary.rawValue | BodyType.star.rawValue
        
        
        
    }
    
    //MARK: - Update Cycle
    func update ( ) {
        
        switch currentDirection {
            case .Right:
                self.position = CGPoint(x: self.position.x + CGFloat(currentSpeed), y: self.position.y)
                objectSprite!.zRotation = CGFloat(degreesToRadians(0))
            
            case .Left:
                self.position = CGPoint(x: self.position.x - CGFloat(currentSpeed), y: self.position.y)
                objectSprite!.zRotation = CGFloat(degreesToRadians(180))

            case .Up:
                self.position = CGPoint(x: self.position.x, y: self.position.y + CGFloat(currentSpeed))
                objectSprite!.zRotation = CGFloat(degreesToRadians(90))

            case .Down:
                self.position = CGPoint(x: self.position.x , y: self.position.y - CGFloat(currentSpeed))
                objectSprite!.zRotation = CGFloat(degreesToRadians(270))

            
            case .None:
                self.position = CGPoint(x: self.position.x , y: self.position.y)
        
        }
        
    }
    
    //MARK: - Directional Movement Logic
    
    func goRight( ) {
        currentDirection = .Right
        runAnimation()
    }
    
    func goLeft ( ) {
        currentDirection = .Left
        runAnimation()
    }
    
    func goUp ( ) {
        currentDirection = .Up
        runAnimation()
    }
    
    func goDown(){
        currentDirection = .Down
        runAnimation()
    }
    
    //MARK: - Animations
    
    func setupAnimation () {
        //TODO: Implementation
        let atlas = SKTextureAtlas(named: "moving")
        let array = ["moving0001", "moving0002", "moving0003", "moving0004", "moving0003", "moving0002"]
        
        var atlasTextures:[SKTexture] = [ ]
        
        for (var i = 0; i < array.count; i++) {
            let texture = atlas.textureNamed(array[i])
            atlasTextures.insert(texture, atIndex: i)
        }
        
        let atlasAnimation = SKAction.animateWithTextures(atlasTextures, timePerFrame: 1.0/30, resize: true, restore: false)
        movingAnimation = SKAction.repeatActionForever(atlasAnimation)
    }
    
    func runAnimation ( ){
        objectSprite!.runAction(movingAnimation)
    }
    
    func stopAnimation () {
        objectSprite!.removeAllActions()
    }
    
    func degreesToRadians(degrees: Double) -> Double {
        return degrees / 180 * Double(M_PI)
    }
}
