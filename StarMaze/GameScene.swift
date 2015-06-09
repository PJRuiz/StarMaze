//
//  GameScene.swift
//  StarMaze
//
//  Created by Pedro Ruíz on 6/4/15.
//  Copyright (c) 2015 Pedro Ruíz. All rights reserved.
//

//MARK: - Import Frameworks
import SpriteKit
import AVFoundation

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
    var enemySpeed:Float = 4
    
    var heroLocation: CGPoint = CGPointZero
    var mazeWorld: SKNode?
    var hero:Hero?
    var heroIsDead = false
    
    var starsAcquired = 0
    var starsTotal = 0
    
    var enemyCount = 0
    var enemyDictionary:[String : CGPoint] = [:]
    var enemyLogic:Double = 5
    
    var useTMXFiles: Bool = true
    
    var currentTMXFile:String?
    
    var nextSKSFile:String?
    
    var bgImage:String?
    
    var gameLabel:SKLabelNode?
    
    //MARK: - Music Player
    
    var backgroundMusicPlayer: AVAudioPlayer!
    
    func playBackgroundMusic(filename: String) {
        let url = NSBundle.mainBundle().URLForResource(
            filename, withExtension: nil)
        if (url == nil) {
            println("Could not find file: \(filename)")
            return
        }
        
        var error: NSError? = nil
        backgroundMusicPlayer =
            AVAudioPlayer(contentsOfURL: url, error: &error)
        if backgroundMusicPlayer == nil {
            println("Could not create audio player: \(error!)")
            return
        }
        
        backgroundMusicPlayer.numberOfLoops = -1
        backgroundMusicPlayer.prepareToPlay()
        backgroundMusicPlayer.play()
    }
    
     var bgSoundPlayer:AVAudioPlayer?
    
    func playBackgroundSound(name:String) {
        
        
        if (bgSoundPlayer != nil) {
            
            bgSoundPlayer!.stop()
            bgSoundPlayer = nil
            
        }
        
        
        let fileURL:NSURL = NSBundle.mainBundle().URLForResource( name , withExtension: "mp3")!
        
        bgSoundPlayer = AVAudioPlayer(contentsOfURL: fileURL, error: nil)
        
        
        bgSoundPlayer!.volume = 0.5  //half volume
        bgSoundPlayer!.numberOfLoops = -1
        bgSoundPlayer!.prepareToPlay()
        bgSoundPlayer!.play()
        
        
    }

    
    //MARK: - SKLabels
    
    func createLabel() {
        gameLabel = SKLabelNode(fontNamed: "BM germar")
        gameLabel!.horizontalAlignmentMode = .Left
        gameLabel!.verticalAlignmentMode = .Center
        gameLabel!.fontColor = SKColor.whiteColor()
        gameLabel!.text = "Lives: \(livesLeft)"
        addChild(gameLabel!)
        
        if UIDevice.currentDevice().userInterfaceIdiom == .Phone {
            gameLabel!.position = CGPoint(x: -(self.size.width / 2.3), y: -(self.size.height / 3))
        }else if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
            gameLabel!.position = CGPoint(x: -(self.size.width / 2.3), y: -(self.size.height / 2.3))
        } else {
            gameLabel!.position = CGPoint(x: -(self.size.width / 2.3), y: -(self.size.height / 3))
        }
    }

    
    
    //MARK: - Initialize View
    override func didMoveToView(view: SKView) {
        
        //MARK: Parse Property List
        
        let path = NSBundle.mainBundle().pathForResource("GameData", ofType: "plist")
        let dict = NSDictionary(contentsOfFile: path!)!
        let heroDict = dict.objectForKey("HeroSettings")! as! NSDictionary
        let gameDict = dict.objectForKey("GameSettings")! as! NSDictionary
        let levelArray: AnyObject = dict.objectForKey("LevelSettings")!
        
        if let levelNSArray:NSArray = levelArray as? NSArray{
            
            //println(levelNSArray)
            
            var levelDict:NSDictionary = levelNSArray[currentLevel] as! NSDictionary
            
            if let tmxFile = levelDict["TMXFile"] as? String {
                
                currentTMXFile = tmxFile
                println("specified a TMX file for this level ")
                println(currentTMXFile)
            }
            
            if let sksFile = levelDict["NextSKSFile"] as? String {
                
                nextSKSFile = sksFile
                println("specified a next SKS file if this level is passed ")
            }
            
            if let speed = levelDict["Speed"] as? Float  {
                
                currentSpeed = speed
                println( currentSpeed )
            }
            if let espeed = levelDict["EnemySpeed"] as? Float  {
                
                enemySpeed = espeed
                println( enemySpeed )
            }
            
            if let elogic = levelDict["EnemyLogic"] as? Double   {
                
                enemyLogic = elogic
                println( enemyLogic )
            }
            
            if let bg = levelDict["Background"] as? String    {
                
                bgImage = bg
            }
            
            if let musicFile = levelDict["Music"] as? String    {
                
                playBackgroundSound(musicFile)
            }
            
        }
        
        livesLeft = 1
        
        
        self.backgroundColor = SKColor.blackColor()
        view.showsPhysics = gameDict["ShowPhysics"] as! Bool
        
        self.physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        
        physicsWorld.contactDelegate = self
        
        self.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        
        //MARK: Play Background Music
        playBackgroundMusic("HungryWolf.mp3")
        
        
        useTMXFiles = gameDict["UseTMXFile"] as! Bool

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

        hero = Hero(theDict: heroDict as! Dictionary)
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
            parseTMXFileWithName(currentTMXFile!)
            mazeWorld!.position = CGPoint(x: mazeWorld!.position.x, y: mazeWorld!.position.y + 800)
        }
        
        tellEnemiesWhereHeroIs()
        createLabel()
        
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
                newEnemy.enemySpeed = self.enemySpeed
                
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
        if heroIsDead == false {
            hero!.update()
            
            mazeWorld!.enumerateChildNodesWithName("enemy*") {
                node, stop in
                
                if let enemy = node as? Enemy {
                    
                    if enemy.isStuck == true {
                        enemy.heroLocationIs = self.returnTheDirection(enemy)
                        enemy.decideDirection()
                        enemy.isStuck = false
                    }
                    enemy.update()
                }
            }
        } else {
            // HERO IS DEAD
            
            resetEnemies()
            hero?.rightBlocked = false
            hero!.position = heroLocation
            heroIsDead = false
            hero!.currentDirection = .Right
            hero!.desiredDirection = .None
            hero!.goRight()
            hero!.runAnimation()

        }
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
            case BodyType.enemy.rawValue | BodyType.enemy.rawValue:
                if let enemy1 = contact.bodyA.node as? Enemy {
                    enemy1.bumped()
                } else if let enemy2 = contact.bodyB.node as? Enemy {
                    enemy2.bumped()
                }
            
            case BodyType.hero.rawValue | BodyType.enemy.rawValue:
                reloadLevel()
            
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
                    loadNextLevel()
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
                newEnemy.enemySpeed = enemySpeed
                
                let location:CGPoint = newEnemy.position
                
                enemyDictionary.updateValue(location, forKey: newEnemy.name!)
            }
        }
    }
    
      //MARK: - Gameplay AI
    
    func tellEnemiesWhereHeroIs () {
        // Refresh location every 5 seconds
        let enemyAction = SKAction.waitForDuration(enemyLogic)
        self.runAction(enemyAction, completion: {
            self.tellEnemiesWhereHeroIs()
        })
        
        mazeWorld!.enumerateChildNodesWithName("enemy*") {
            node, stop in
            
            if let enemy = node as? Enemy {
                
               enemy.heroLocationIs = self.returnTheDirection(enemy)
            }
        }
    }

    
    func returnTheDirection(enemy:Enemy) -> HeroIs {
        
        if (self.hero!.position.x < enemy.position.x && self.hero!.position.y < enemy.position.y) {
            
            return HeroIs.Southwest
            
        } else if (self.hero!.position.x > enemy.position.x && self.hero!.position.y < enemy.position.y) {
            
            return HeroIs.Southeast
            
        } else if (self.hero!.position.x < enemy.position.x && self.hero!.position.y >  enemy.position.y) {
            
            return HeroIs.Northwest
            
        } else if (self.hero!.position.x > enemy.position.x && self.hero!.position.y >  enemy.position.y) {
            
            return HeroIs.Northeast
            
        } else {
            
            return HeroIs.Northeast
        }
        
    }
    
    //MARK: - Reload Level
    
    func reloadLevel() {
        loseLife()
        heroIsDead = true
    }
    
    func loseLife() {
        livesLeft = livesLeft - 1
        if livesLeft == 0 {
            //TODO: Game Over Screen
            
            gameLabel!.text = "Game Over"
            gameLabel!.position = CGPointZero
            gameLabel!.horizontalAlignmentMode = .Center
            
            let scaleAction = SKAction.scaleTo(0.2,duration: 3)
            let fadeAction = SKAction.fadeAlphaTo(0, duration: 3)
            let group = SKAction.group( [scaleAction, fadeAction])
            
            mazeWorld!.runAction(group, completion: {
                self.resetGame()
            })
        } else {
            //TODO: Update Text for Lives Label
            gameLabel!.text = "Lives: \(livesLeft)"
        }
    }
    
    func resetEnemies() {
        for (name, location) in enemyDictionary {
            mazeWorld!.childNodeWithName(name)?.position = location
        }
    }
    
    func resetGame() {
        livesLeft = 3
        currentLevel = 0
        
        if (bgSoundPlayer != nil) {
            
            bgSoundPlayer!.stop()
            bgSoundPlayer = nil
            
        }
        
        if useTMXFiles == true {
            loadNextTMXLevel()
        } else {
            currentSKSFile = firstSKSFile
            
            var scene = GameScene.unarchiveFromFile(currentSKSFile) as? GameScene
            scene!.scaleMode = .AspectFill
            
            self.view?.presentScene(scene, transition: SKTransition.fadeWithDuration(2))
        }
    }
    
    func loadNextLevel() {
        
        currentLevel++
        
        if (bgSoundPlayer != nil) {
            
            bgSoundPlayer!.stop()
            bgSoundPlayer = nil
            
        }
        
        if useTMXFiles == true {
            loadNextTMXLevel()
        } else {
            loadNextSKSLevel()
        }
    }
    
    func loadNextTMXLevel() {
        var scene:GameScene = GameScene(size: self.size)
        scene.scaleMode = .AspectFill
        
        self.view?.presentScene(scene, transition: SKTransition.fadeWithDuration(2))
    }
    
    func loadNextSKSLevel() {
        currentSKSFile = nextSKSFile!
        var scene = GameScene.unarchiveFromFile(currentSKSFile) as? GameScene
        scene!.scaleMode = .AspectFill
        
        self.view?.presentScene(scene, transition: SKTransition.fadeWithDuration(2))
        
    }

    
    //MARK: - Final Closure
}
