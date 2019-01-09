//
//  lineClass.swift
//  Gravity Line
//
//  Created by Elias Stevenson on 6/3/17.
//  Copyright © 2017 Elias Stevenson. All rights reserved.
//

import Foundation
import SpriteKit

struct ColliderType{
    static let PLAYER: UInt32 = 0;
    static let WALL: UInt32 = 1;
}

class lineClass: SKSpriteNode {
    
    func initialize(){
        physicsBody?.categoryBitMask = ColliderType.PLAYER
        physicsBody?.collisionBitMask = ColliderType.WALL
        physicsBody?.contactTestBitMask = ColliderType.WALL
    }
    
    func moveLine(){
        self.position.x += 4.0
        if self.position.y < -640{
            self.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 10))
        }
        if self.position.y > 640{
            self.physicsBody?.applyImpulse(CGVector(dx: 0, dy: -10))
        }
    }
    
    func moveTip(){
        self.zRotation -= 0.27
    }
}
