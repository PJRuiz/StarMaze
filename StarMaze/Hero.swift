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
    case Up, Down, Right, Left, None
}


class Hero: SKNode {
    
    //MARK: - Properties
    var objectSprite: SKSpriteNode?
    
    var currentSpeed: Float = 5
    
    var currentDirection = Direction.Right
    var desiredDirection = DesiredDirection.None
    
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
    
    init(theDict: [String: AnyObject]) {
        super.init( )
        
        let image = theDict["HeroImage"] as AnyObject? as! String
        
        objectSprite = SKSpriteNode(imageNamed: image)
        self.addChild(objectSprite!)
        
        if let atlasName = theDict["MovingAtlasFile"] as AnyObject? as? String {
            let frameArray: AnyObject = theDict["MovingFrames"]!
            if let framesAsNSArray = frameArray as? NSArray {
                setupAnimationWithArray(framesAsNSArray, andAtlasNamed: atlasName)
                runAnimation()
            }
        } else {
            setupAnimation()
            runAnimation()
        }
        
        
        
        //MARK: Physics
        let largerSize = CGSize(width: objectSprite!.size.width * 1.2 , height: objectSprite!.size.height * 1.2)

        
        let bodyShape = theDict["BodyShape"] as AnyObject? as! String
        
        if bodyShape == "circle" {
            self.physicsBody = SKPhysicsBody(circleOfRadius: objectSprite!.size.width/2)
        } else {
            self.physicsBody = SKPhysicsBody(rectangleOfSize: largerSize)
        }
        
        
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
        self.physicsBody!.collisionBitMask = 0
        
        // Who do you want to be notified if you come in contact with
        self.physicsBody!.contactTestBitMask = BodyType.boundary.rawValue | BodyType.star.rawValue
        
        
        nodeUp = SKNode()
        addChild(nodeUp!)
        nodeUp!.position = CGPoint(x:0, y:buffer)
        createUpSensorPhysicsBody( whileTravellingUpOrDown: false )
        
        nodeDown = SKNode()
        addChild(nodeDown!)
        nodeDown!.position = CGPoint(x:0, y: -buffer )
        createDownSensorPhysicsBody( whileTravellingUpOrDown: false)
        
        nodeRight = SKNode()
        addChild(nodeRight!)
        nodeRight!.position = CGPoint(x: buffer, y:0 )
        createRightSensorPhysicsBody( whileTravellingLeftOrRight: true)
        
        nodeLeft = SKNode()
        addChild(nodeLeft!)
        nodeLeft!.position = CGPoint(x: -buffer, y:0 )
        createLeftSensorPhysicsBody( whileTravellingLeftOrRight: true)
        

        
        
        
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
        if (upBlocked == true) {
            
            desiredDirection = DesiredDirection.Up
            
        } else {
            
            runAnimation()
            
            currentDirection = .Up
            desiredDirection = .None
            downBlocked = false
            
            self.physicsBody?.dynamic = true
            
            createUpSensorPhysicsBody(whileTravellingUpOrDown: true)
            createDownSensorPhysicsBody(whileTravellingUpOrDown: true )
            createLeftSensorPhysicsBody(whileTravellingLeftOrRight: false )
            createRightSensorPhysicsBody(whileTravellingLeftOrRight: false )
            
        }
    }
    
    func goDown(){

        if (downBlocked == true) {
            
            desiredDirection = DesiredDirection.Down
            
        } else {
            
            
            currentDirection = .Down
            desiredDirection = .None
            runAnimation()
            
            upBlocked = false
            
            self.physicsBody?.dynamic = true
            
            createUpSensorPhysicsBody(whileTravellingUpOrDown: true)
            createDownSensorPhysicsBody(whileTravellingUpOrDown: true )
            createLeftSensorPhysicsBody(whileTravellingLeftOrRight: false )
            createRightSensorPhysicsBody(whileTravellingLeftOrRight: false )
            
        }
    }

    func goRight( ) {

        if (rightBlocked == true) {
            
            desiredDirection = DesiredDirection.Right
            
        } else {
            
            
            currentDirection = .Right
            desiredDirection = .None
            runAnimation()
            
            leftBlocked = false
            
            self.physicsBody?.dynamic = true
            
            createUpSensorPhysicsBody(whileTravellingUpOrDown: false)
            createDownSensorPhysicsBody(whileTravellingUpOrDown: false )
            createLeftSensorPhysicsBody(whileTravellingLeftOrRight: true )
            createRightSensorPhysicsBody(whileTravellingLeftOrRight: true )
            
        }

    }
    
    func goLeft ( ) {

        if (leftBlocked == true) {
            
            desiredDirection = DesiredDirection.Left
            
        } else {
            
            currentDirection = .Left
            desiredDirection = .None
            runAnimation()
            
            rightBlocked = false
            
            self.physicsBody?.dynamic = true
            
            createUpSensorPhysicsBody(whileTravellingUpOrDown: false)
            createDownSensorPhysicsBody(whileTravellingUpOrDown: false )
            createLeftSensorPhysicsBody(whileTravellingLeftOrRight: true )
            createRightSensorPhysicsBody(whileTravellingLeftOrRight: true )
            
        }
    }
    
    
    //MARK: - Animations
    
    func setupAnimation () {
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
    
    func setupAnimationWithArray (theArray: NSArray, andAtlasNamed theAtlas: String) {
        let atlas = SKTextureAtlas(named: theAtlas)
        
        var atlasTextures:[SKTexture] = [ ]
        
        for (var i = 0; i < theArray.count; i++) {
            let texture = atlas.textureNamed(theArray[i] as! String)
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
    
    func createUpSensorPhysicsBody(#whileTravellingUpOrDown:Bool) {
        
        var size:CGSize = CGSizeZero
        
        if (whileTravellingUpOrDown == true) {
            
            size = CGSize(width: 32, height: 4)
        } else {
            
            size = CGSize(width: 32.4, height: 36)
        }
        
        
        nodeUp!.physicsBody = nil // get rid of any existing physics body
        let bodyUp:SKPhysicsBody = SKPhysicsBody(rectangleOfSize: size)
        nodeUp!.physicsBody = bodyUp
        nodeUp!.physicsBody?.categoryBitMask = BodyType.sensorUp.rawValue
        nodeUp!.physicsBody?.collisionBitMask = 0
        nodeUp!.physicsBody?.contactTestBitMask = BodyType.boundary.rawValue
        nodeUp!.physicsBody?.pinned = true
        nodeUp!.physicsBody?.allowsRotation = false
        
        
    }
    
    func createDownSensorPhysicsBody(#whileTravellingUpOrDown:Bool){
        
        var size:CGSize = CGSizeZero
        
        if (whileTravellingUpOrDown == true) {
            
            size = CGSize(width: 32, height: 4)
        } else {
            
            size = CGSize(width: 32.4 , height:36 )
        }
        
        
        
        nodeDown?.physicsBody = nil
        let bodyDown:SKPhysicsBody = SKPhysicsBody(rectangleOfSize: size )
        
        
        
        nodeDown!.physicsBody = bodyDown
        nodeDown!.physicsBody?.categoryBitMask = BodyType.sensorDown.rawValue
        nodeDown!.physicsBody?.collisionBitMask = 0
        nodeDown!.physicsBody?.contactTestBitMask = BodyType.boundary.rawValue
        nodeDown!.physicsBody!.pinned = true
        nodeDown!.physicsBody!.allowsRotation = false
        
        
    }
    
    func createLeftSensorPhysicsBody( #whileTravellingLeftOrRight:Bool){
        
        var size:CGSize = CGSizeZero
        
        if (whileTravellingLeftOrRight == true) {
            
            size = CGSize(width: 4, height: 32)
        } else {
            
            size = CGSize(width: 36, height: 32.4)
        }
        
        
        
        nodeLeft?.physicsBody = nil
        let bodyLeft:SKPhysicsBody = SKPhysicsBody(rectangleOfSize: size )
        nodeLeft!.physicsBody = bodyLeft
        nodeLeft!.physicsBody?.categoryBitMask = BodyType.sensorLeft.rawValue
        nodeLeft!.physicsBody?.collisionBitMask = 0
        nodeLeft!.physicsBody?.contactTestBitMask = BodyType.boundary.rawValue
        nodeLeft!.physicsBody!.pinned = true
        nodeLeft!.physicsBody!.allowsRotation = false
        
        
        
    }
    
    func createRightSensorPhysicsBody( #whileTravellingLeftOrRight:Bool){
        
        
        var size:CGSize = CGSizeZero
        
        if (whileTravellingLeftOrRight == true) {
            
            size = CGSize(width: 4, height: 32)
        } else {
            
            size = CGSize(width: 36, height: 32.4)
        }
        
        
        
        
        nodeRight?.physicsBody = nil
        let bodyRight:SKPhysicsBody = SKPhysicsBody(rectangleOfSize: size )
        nodeRight!.physicsBody = bodyRight
        nodeRight!.physicsBody?.categoryBitMask = BodyType.sensorRight.rawValue
        nodeRight!.physicsBody?.collisionBitMask = 0
        nodeRight!.physicsBody?.contactTestBitMask = BodyType.boundary.rawValue
        nodeRight!.physicsBody!.pinned = true
        nodeRight!.physicsBody!.allowsRotation = false
        
        
    }
    
    
    //MARK: - Functions for Sensor Contacts
    //MARK: ContactStart
    func upSensorContactStart() {
        
        upBlocked = true
        
        if (currentDirection == Direction.Up) {
            
            currentDirection = Direction.None
            self.physicsBody?.dynamic = false
            stopAnimation()
        }
        
        
    }
    
    func downSensorContactStart() {
        
        
        downBlocked = true
        
        if (currentDirection == Direction.Down) {
            
            currentDirection = Direction.None
            self.physicsBody?.dynamic = false
            stopAnimation()
        }
        
    }
    
    func leftSensorContactStart() {
        
        
        leftBlocked = true
        
        if (currentDirection == Direction.Left) {
            
            currentDirection = Direction.None
            self.physicsBody?.dynamic = false
            stopAnimation()
        }
        
    }
    
    func rightSensorContactStart() {
        
        
        rightBlocked = true
        
        if (currentDirection == Direction.Right) {
            
            currentDirection = Direction.None
            self.physicsBody?.dynamic = false
            stopAnimation()
        }
        
    }
    
    //MARK: ContactEnd
    func upSensorContactEnd() {
        
        upBlocked = false
        
        if (desiredDirection == DesiredDirection.Up) {
            
            goUp()
            desiredDirection == DesiredDirection.None
        }
        
        
    }
    
    func downSensorContactEnd() {
        
        
        downBlocked = false
        
        if (desiredDirection == DesiredDirection.Down) {
            goDown()
            desiredDirection == DesiredDirection.None
        }
    }
    
    func leftSensorContactEnd() {
        leftBlocked = false
        
        if (desiredDirection == DesiredDirection.Left) {
            
            goLeft()
            desiredDirection == DesiredDirection.None
        }
        
        
    }
    
    func rightSensorContactEnd() {

        rightBlocked = false
        
        if (desiredDirection == DesiredDirection.Right) {
            
            goRight ()
            desiredDirection == DesiredDirection.None
        }
        
        
    }
    
    
}
