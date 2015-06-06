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
    
    //MARK: - Navigational Properties
    
    var downBlocked = false
    var upBlocked = false
    var leftBlocked = false
    var rightBlocked = false
    
    var nodeUp: SKNode?
    var nodeDown: SKNode?
    var nodeLeft: SKNode?
    var nodeRight: SKNode?
    
    var buffer = 25
    
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
        
        //MARK: Physics
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
        
        
        nodeUp = SKNode()
        addChild(nodeUp!)
        nodeUp!.position = CGPoint(x: 0, y: buffer)
        createUpSensorPhysicsBody(whileTravellingUpOrDown: false)
        
        nodeDown = SKNode()
        addChild(nodeDown!)
        nodeDown!.position = CGPoint(x: 0, y: -buffer)
        createDownSensorPhysicsBody(whileTravellingUpOrDown: false)
        
        nodeLeft = SKNode()
        addChild(nodeLeft!)
        nodeLeft!.position = CGPoint(x: buffer, y: 0)
        createRightSensorPhysicsBody(whileTravellingLeftOrRight: true)
        
        nodeRight = SKNode()
        addChild(nodeRight!)
        nodeRight!.position = CGPoint(x: -buffer, y: 0)
        createLeftSensorPhysicsBody(whileTravellingLeftOrRight: false)
        
        
        
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
    func goUp ( ) {
        currentDirection = .Up
        runAnimation()
        
        createUpSensorPhysicsBody(whileTravellingUpOrDown: true)
        createDownSensorPhysicsBody(whileTravellingUpOrDown: true)
        createLeftSensorPhysicsBody(whileTravellingLeftOrRight: false)
        createRightSensorPhysicsBody(whileTravellingLeftOrRight: false)
    }
    
    func goDown(){
        currentDirection = .Down
        runAnimation()
        
        createUpSensorPhysicsBody(whileTravellingUpOrDown: true)
        createDownSensorPhysicsBody(whileTravellingUpOrDown: true)
        createLeftSensorPhysicsBody(whileTravellingLeftOrRight: false)
        createRightSensorPhysicsBody(whileTravellingLeftOrRight: false)
    }

    func goRight( ) {
        currentDirection = .Right
        runAnimation()
        
        createUpSensorPhysicsBody(whileTravellingUpOrDown: false)
        createDownSensorPhysicsBody(whileTravellingUpOrDown: false)
        createLeftSensorPhysicsBody(whileTravellingLeftOrRight: true)
        createRightSensorPhysicsBody(whileTravellingLeftOrRight: true)
    }
    
    func goLeft ( ) {
        currentDirection = .Left
        runAnimation()
        
        createUpSensorPhysicsBody(whileTravellingUpOrDown: false)
        createDownSensorPhysicsBody(whileTravellingUpOrDown: false)
        createLeftSensorPhysicsBody(whileTravellingLeftOrRight: true)
        createRightSensorPhysicsBody(whileTravellingLeftOrRight: true)
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
    
    //MARK: - Physics Sensors
    
    func createUpSensorPhysicsBody (#whileTravellingUpOrDown: Bool) {
       var size = CGSizeZero
        
        if whileTravellingUpOrDown == true {
            size = CGSize(width: 32, height: 9)
        } else {
            size = CGSize(width: 32.4, height: 36)
        }
        
        nodeUp!.physicsBody = nil
        let bodyUp = SKPhysicsBody(rectangleOfSize: size)
        
        nodeUp!.physicsBody = bodyUp
        nodeUp!.physicsBody!.categoryBitMask = BodyType.sensorUp.rawValue
        nodeUp!.physicsBody!.collisionBitMask = 0
        nodeUp!.physicsBody!.contactTestBitMask = BodyType.boundary.rawValue
        nodeUp!.physicsBody!.pinned = true
        nodeUp!.physicsBody!.allowsRotation = false
        
    }
    
    func createDownSensorPhysicsBody (#whileTravellingUpOrDown: Bool) {
        var size = CGSizeZero
        
        if whileTravellingUpOrDown == true {
            size = CGSize(width: 32, height: 9)
        } else {
            size = CGSize(width: 32.4, height: 36)
        }
        
        nodeDown!.physicsBody = nil
        let bodyDown = SKPhysicsBody(rectangleOfSize: size)
        
        nodeDown!.physicsBody = bodyDown
        nodeDown!.physicsBody!.categoryBitMask = BodyType.sensorDown.rawValue
        nodeDown!.physicsBody!.collisionBitMask = 0
        nodeDown!.physicsBody!.contactTestBitMask = BodyType.boundary.rawValue
        nodeDown!.physicsBody!.pinned = true
        nodeDown!.physicsBody!.allowsRotation = false
        
    }

    func createLeftSensorPhysicsBody (#whileTravellingLeftOrRight: Bool) {
        var size = CGSizeZero
        
        if whileTravellingLeftOrRight == true {
            size = CGSize(width: 9, height: 32)
        } else {
            size = CGSize(width: 36, height: 32.4)
        }
        
        nodeLeft!.physicsBody = nil
        let bodyLeft = SKPhysicsBody(rectangleOfSize: size)
        
        nodeLeft!.physicsBody = bodyLeft
        nodeLeft!.physicsBody!.categoryBitMask = BodyType.sensorLeft.rawValue
        nodeLeft!.physicsBody!.collisionBitMask = 0
        nodeLeft!.physicsBody!.contactTestBitMask = BodyType.boundary.rawValue
        nodeLeft!.physicsBody!.pinned = true
        nodeLeft!.physicsBody!.allowsRotation = false
        
    }
    
    func createRightSensorPhysicsBody (#whileTravellingLeftOrRight: Bool) {
        var size = CGSizeZero
        
        if whileTravellingLeftOrRight == true {
            size = CGSize(width: 9, height: 32)
        } else {
            size = CGSize(width: 36, height: 32.4)
        }
        
        nodeRight!.physicsBody = nil
        let bodyRight = SKPhysicsBody(rectangleOfSize: size)
        
        nodeRight!.physicsBody = bodyRight
        nodeRight!.physicsBody!.categoryBitMask = BodyType.sensorRight.rawValue
        nodeRight!.physicsBody!.collisionBitMask = 0
        nodeRight!.physicsBody!.contactTestBitMask = BodyType.boundary.rawValue
        nodeRight!.physicsBody!.pinned = true
        nodeRight!.physicsBody!.allowsRotation = false
        
    }

    
    
}
