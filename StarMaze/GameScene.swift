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

class GameScene: SKScene, SKPhysicsContactDelegate, NSXMLParserDelegate {
    
    //MARK: - Instance Variables
    var currentSpeed: Float = 5
    var heroLocation: CGPoint = CGPointZero
    var mazeWorld: SKNode?
    var hero:Hero?
    var heroIsDead = false
    
    var starsAcquired = 0
    var starsTotal = 0
    
    var enemyCount = 0
    var enemyDictionary:[String : CGPoint] = [:]
    
    var useTMXFiles: Bool = true
    
    
    //MARK: - Initialize View
    override func didMoveToView(view: SKView) {
        
        self.backgroundColor = SKColor.blackColor()
        view.showsPhysics = true
        
        self.physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        
        physicsWorld.contactDelegate = self
        
        self.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        
        if (useTMXFiles == true) {
            println("setup with tmx")
            
            self.enumerateChildNodesWithName("*") {
                node, stop in
                node.removeFromParent()
            }
            mazeWorld = SKNode()
            addChild(mazeWorld!)
        } else {
            mazeWorld = childNodeWithName("mazeWorld")
            heroLocation = mazeWorld!.childNodeWithName("StartingPoint")!.position

        }


        
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
        
        if (useTMXFiles == false) {
            println("setup with SKS")
            setUpBoundaryFromSKS()
            setUpEdgeFromSKS()
            setUpStarsFromSKS()
            setUpEnemiesFromSKS()
        } else {
            parseTMXFileWithName("Maze")
            mazeWorld!.position = CGPoint(x: mazeWorld!.position.x, y: mazeWorld!.position.y + 800)
        }
    }
    
    //MARK: - Setup from SKS
    func setUpBoundaryFromSKS() {
        mazeWorld!.enumerateChildNodesWithName("boundary") {
            node, stop in
            
            if let boundary = node as? SKSpriteNode {
                let rect = CGRect(origin: boundary.position, size: boundary.size)
                
                let newBoundary = Boundary(fromSKSwithRect: rect, isEdge: false)
                
                self.mazeWorld!.addChild(newBoundary)
                newBoundary.position = boundary.position
                
                boundary.removeFromParent( )
                
            }
            
        }
    }
    
    func setUpEdgeFromSKS() {
        mazeWorld!.enumerateChildNodesWithName("edge") {
            node, stop in
            
            if let edge = node as? SKSpriteNode {
                let rect = CGRect(origin: edge.position, size: edge.size)
                
                let newEdge = Boundary(fromSKSwithRect: rect, isEdge: true)
                
                self.mazeWorld!.addChild(newEdge)
                newEdge.position = edge.position
                
                edge.removeFromParent( )
                
            }
            
        }
    }
    
    func setUpEnemiesFromSKS() {
        mazeWorld!.enumerateChildNodesWithName("enemy*") {
            node, stop in
            
            if let enemy = node as? SKSpriteNode {
                self.enemyCount++
                
                let newEnemy = Enemy(fromSKSWithImage: enemy.name!)
                self.mazeWorld!.addChild(newEnemy)
                newEnemy.position = enemy.position
                newEnemy.name = enemy.name!
                
                self.enemyDictionary.updateValue(newEnemy.position, forKey: newEnemy.name!)
                
                enemy.removeFromParent()
            }
        }
    }
    
    func setUpStarsFromSKS() {
        mazeWorld!.enumerateChildNodesWithName("star") {
            node, stop in
            
            if let star = node as? SKSpriteNode {
                let newStar: Star = Star()
                self.mazeWorld!.addChild(newStar)
                newStar.position = star.position
                
                self.starsTotal++
                
                star.removeFromParent()
            }
            
        }
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
    
    override func didSimulatePhysics() {
        if (heroIsDead == false) {
            self.centerOnNode(hero!)
        }
    }
    
    func centerOnNode (node: SKNode) {
        let cameraPositionInScene = self.convertPoint(node.position, fromNode: mazeWorld!)
        mazeWorld!.position = CGPoint(x: mazeWorld!.position.x - cameraPositionInScene.x, y: mazeWorld!.position.y - cameraPositionInScene.y)
    }

    
    //MARK: - Contact Delegates
    
    func didBeginContact(contact: SKPhysicsContact) {
        let contactMask = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask
        
        switch(contactMask) {
            case BodyType.boundary.rawValue | BodyType.sensorUp.rawValue:
                hero!.upSensorContactStart()
            
            case BodyType.boundary.rawValue | BodyType.sensorDown.rawValue:
                hero!.downSensorContactStart()
            
            case BodyType.boundary.rawValue | BodyType.sensorLeft.rawValue:
                hero!.leftSensorContactStart()
            
            case BodyType.boundary.rawValue | BodyType.sensorRight.rawValue:
                hero!.rightSensorContactStart()
            
            
            
            case BodyType.hero.rawValue | BodyType.star.rawValue:
                if let star = contact.bodyA.node as? Star {
                    star.removeFromParent()
                } else if let star = contact.bodyB.node as? Star {
                    star.removeFromParent()
                }
            
                starsAcquired++
            
                if starsAcquired == starsTotal {
                    println("got all the stars")
                }
            
        default:
            return
        }
    }
    
    func didEndContact(contact: SKPhysicsContact) {
        let contactMask = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask
        
        switch(contactMask) {
        case BodyType.boundary.rawValue | BodyType.sensorUp.rawValue:
            hero!.upSensorContactEnd()
            
        case BodyType.boundary.rawValue | BodyType.sensorDown.rawValue:
            hero!.downSensorContactEnd()
            
        case BodyType.boundary.rawValue | BodyType.sensorLeft.rawValue:
            hero!.leftSensorContactEnd()
            
        case BodyType.boundary.rawValue | BodyType.sensorRight.rawValue:
            hero!.rightSensorContactEnd()
            
        
        default:
            return
        }

    }
    
    //MARK: - Tiled Parsing
    func parseTMXFileWithName (name:NSString ) {
        let path:String = NSBundle.mainBundle().pathForResource(name as String, ofType: "tmx")!
        
        let data = NSData(contentsOfFile: path)
        
        let parser:NSXMLParser = NSXMLParser(data: data!)
        
        parser.delegate = self
        
        parser.parse()
    }
    
    func parser(parser: NSXMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [NSObject : AnyObject]) {
        if (elementName == "object") {
            let type: AnyObject? = attributeDict["type"]
            
            if (type as? String == "Boundary") {
                var tmxDict = attributeDict
                
                tmxDict.updateValue("false", forKey: "isEdge")
                
                let newBoundary = Boundary(theDict: tmxDict)
                mazeWorld!.addChild(newBoundary)
                
            } else if type as? String == "Edge"{
                var tmxDict = attributeDict
                
                tmxDict.updateValue("true", forKey: "isEdge")
                
                let newBoundary = Boundary(theDict: tmxDict)
                mazeWorld!.addChild(newBoundary)
                
                
            } else if (type as? String == "Star") {
                let newStar = Star(fromTMXFileWithDict: attributeDict)
                mazeWorld!.addChild(newStar)
                starsTotal++
                
            } else if type as? String == "Portal" {
                let theName = attributeDict["name"] as AnyObject? as! String
                
                if theName == "StartingPoint" {
                    let theX:String = attributeDict["x"] as AnyObject? as! String
                    let x:Int = theX.toInt( )!
                    
                    let theY:String = attributeDict["y"] as AnyObject? as! String
                    let y:Int = theY.toInt( )!
                    
                    hero!.position = CGPoint(x: x, y: y * -1)
                    heroLocation = hero!.position

                }
            } else if type as? String == "Enemy" {
                enemyCount++
                
                let theName:String = attributeDict["name"] as AnyObject? as! String
                
                let newEnemy:Enemy = Enemy(theDict: attributeDict)
                mazeWorld!.addChild(newEnemy)
                
                newEnemy.name = theName
                
                let location:CGPoint = newEnemy.position
                
                enemyDictionary.updateValue(location, forKey: newEnemy.name!)
            }
        }
    }
    
    //MARK: - Final Closure
}
