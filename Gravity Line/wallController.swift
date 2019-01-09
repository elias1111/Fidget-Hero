//
//  wallController.swift
//  Gravity Line
//
//  Created by Elias Stevenson on 6/5/17.
//  Copyright © 2017 Elias Stevenson. All rights reserved.
//

import Foundation
import SpriteKit


class wallController: SKSpriteNode {
    
    var minHeight = CGFloat(200), maxHeight = CGFloat(900);
    var wall1: SKSpriteNode? = nil
    var wall2: SKSpriteNode? = nil

    func spawnWall1(camera: SKCameraNode, height1: CGFloat) -> SKSpriteNode{
        wall1 = SKSpriteNode(imageNamed: "pipe")
        wall1?.name = "wall1"
        wall1?.position.x = camera.position.x + 800
        wall1?.position.y = -(640 - (height1/2))
        wall1?.size.height = height1
        wall1?.size.width = 161
        wall1?.zPosition = 2
        wall1?.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        wall1?.physicsBody = SKPhysicsBody.init(rectangleOf: (wall1?.size)!)
        wall1?.physicsBody?.categoryBitMask = ColliderType.WALL
        wall1?.physicsBody?.affectedByGravity = false
        wall1?.physicsBody?.usesPreciseCollisionDetection = true;
        return wall1!;
    }
    
    func spawnWall2(camera: SKCameraNode, height2: CGFloat) -> SKSpriteNode{
        wall2 = SKSpriteNode(imageNamed: "pipe")
        wall2?.name = "wall2"
        wall2?.zRotation = -179.068
        wall2?.position.x = camera.position.x + 800
        wall2?.position.y = 640 - (height2/2)
        wall2?.size.height = height2
        wall2?.size.width = 161
        wall2?.zPosition = 2
        wall2?.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        wall2?.physicsBody = SKPhysicsBody.init(rectangleOf: (wall2?.size)!)
        wall2?.physicsBody?.categoryBitMask = ColliderType.WALL
        wall2?.physicsBody?.affectedByGravity = false
        wall2?.physicsBody?.usesPreciseCollisionDetection = true;
        return wall2!;
    }
    
    func randomBetweenNum(firstNum: CGFloat, secondNum: CGFloat) -> CGFloat{
        return CGFloat(arc4random()) / CGFloat(UINT32_MAX) * abs(firstNum - secondNum) + min(firstNum, secondNum)
    }
    
}
