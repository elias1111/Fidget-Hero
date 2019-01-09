//
//  BGClass.swift
//  Gravity Line
//
//  Created by Elias Stevenson on 6/3/17.
//  Copyright © 2017 Elias Stevenson. All rights reserved.
//

import Foundation
import SpriteKit

class BGClass: SKSpriteNode{
    
    func moveBG(camera: SKCameraNode){
        if self.position.x + self.size.width < camera.position.x{
            self.position.x += self.size.width * 3
        }
    }

}

