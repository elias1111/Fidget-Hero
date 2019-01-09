//
//  CoinScene.swift
//  Gravity Line
//
//  Created by Elias Stevenson on 6/8/17.
//  Copyright © 2017 Elias Stevenson. All rights reserved.
//

import Foundation
import SpriteKit

class CoinScene: SKScene{
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches{
            let location = touch.location(in: self)
            if atPoint(location).name == "back"{
                if let scene = mainMenuScene(fileNamed: "mainMenuScene"){
                    scene.scaleMode = .aspectFill
                    view?.presentScene(scene, transition: SKTransition.push(with: SKTransitionDirection.right, duration: TimeInterval(1.0)))
                }
            }
        }
    }
}
