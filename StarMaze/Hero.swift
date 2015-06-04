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
    
    
    //MARK: - Initializers
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder): has not been implemented")
    }
    
    override init( ) {
        super.init( )
        
        objectSprite = SKSpriteNode(imageNamed: "hero")
        self.addChild(objectSprite!)
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
    }
    
    func goLeft ( ) {
        currentDirection = .Left
    }
    
    func goUp ( ) {
        currentDirection = .Up
    }
    
    func goDown(){
        currentDirection = .Down
    }
    
    //MARK: - Animations
    
    func setupAnimation () {
        
    }
    
    func runAnimation ( ){
        
    }
    
    func stopAnimation () {
        
    }
    
    func degreesToRadians(degrees: Double) -> Double {
        return degrees / 180 * Double(M_PI)
    }
}
