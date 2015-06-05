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
    
    var useTMXFiles: Bool = true
    
    
    //MARK: - Initialize View
    override func didMoveToView(view: SKView) {
        
        self.backgroundColor = SKColor.blackColor()
        view.showsPhysics = true
        
        self.physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        
        physicsWorld.contactDelegate = self
        
        //TODO: - Set up based on TMX or SKS
        
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
        
        //TODO: - Set up based on TMX or SKS
        
        if (useTMXFiles == false) {
            println("setup with SKS")
            setUpBoundaryFromSKS()
        } else {
            parseTMXFileWithName("Maze")
            mazeWorld!.position = CGPoint(x: mazeWorld!.position.x, y: mazeWorld!.position.y + 800)
        }
    }
    
    //MARK: - Boundary Setup
    func setUpBoundaryFromSKS() {
        mazeWorld!.enumerateChildNodesWithName("boundary") {
            node, stop in
            
            if let boundary = node as? SKSpriteNode {
                let rect = CGRect(origin: boundary.position, size: boundary.size)
                
                let newBoundary = Boundary(fromSKSwithRect: rect)
                
                self.mazeWorld!.addChild(newBoundary)
                newBoundary.position = boundary.position
                
                boundary.removeFromParent( )
                
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
    
    //MARK: - Contact Delegates
    
    func didBeginContact(contact: SKPhysicsContact) {
        let contactMask = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask
        
        switch(contactMask) {
            case BodyType.hero.rawValue | BodyType.boundary.rawValue:
                println("Ran into wall")
        default:
            return
        }
    }
    
    func didEndContact(contact: SKPhysicsContact) {
        let contactMask = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask
        
        switch(contactMask) {
        case BodyType.hero.rawValue | BodyType.boundary.rawValue:
            println("Not touching wall")
        default:
            return
        }

    }
    
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
                let newBoundary = Boundary(theDict: attributeDict)
                mazeWorld!.addChild(newBoundary)
            }
        }
    }
    
    
    
}
