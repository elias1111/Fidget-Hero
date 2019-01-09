//
//  mainMenu.swift
//  Gravity Line
//
//  Created by Elias Stevenson on 6/7/17.
//  Copyright © 2017 Elias Stevenson. All rights reserved.
//

import Foundation
import SpriteKit
import GameKit

var scoreLabel: SKLabelNode?

class mainMenuScene: SKScene, GKGameCenterControllerDelegate {
    var gcEnabled = Bool()
    var gcDefaultLeaderBoard = String()
    let LEADERBOARD_ID = "com.score.fidgethero"
    
    override func didMove(to view: SKView) {
        let highScore = UserDefaults.standard.integer(forKey: "HIGHSCORE")
        scoreLabel = scene?.childNode(withName: "topScore") as? SKLabelNode!
        scoreLabel?.text = String(highScore)
        self.view?.showsFPS = false
        self.view?.showsNodeCount = false
    }
    
    func gameCenterViewControllerDidFinish(_ gameCenterViewController: GKGameCenterViewController) {
        gameCenterViewController.dismiss(animated: true, completion: nil)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let gc = GKGameCenterViewController()
        gc.gameCenterDelegate = self as GKGameCenterControllerDelegate
        for touch in touches{
            
            let location = touch.location(in: self)
            
            if atPoint(location).name == "start"{
                if let scene = GameplayScene(fileNamed: "GameplayScene"){
                    scene.scaleMode = .aspectFill
                    view?.presentScene(scene, transition: SKTransition.doorsOpenVertical(withDuration: 1.0))
                }
            }
            
            if atPoint(location).name == "buySpinner"{
                if let scene = SpinnerScene(fileNamed: "SpinnerScene"){
                    scene.scaleMode = .aspectFill
                    view?.presentScene(scene, transition: SKTransition.push(with: SKTransitionDirection.left, duration: TimeInterval(1)))
                }
            }
            if atPoint(location).name == "buyCoins"{
                if let scene = CoinScene(fileNamed: "CoinScene"){
                    scene.scaleMode = .aspectFill
                    view?.presentScene(scene, transition: SKTransition.push(with: SKTransitionDirection.left, duration: TimeInterval(1)))
                }
            }
            if atPoint(location).name == "gameCenter"{
                    let localPlayer: GKLocalPlayer = GKLocalPlayer.localPlayer()
                    localPlayer.authenticateHandler = {(ViewController, error) -> Void in
                        if((ViewController) != nil) {
                            // 1. Show login if player is not logged in
                            self.view?.window?.rootViewController?.present(ViewController!, animated: true, completion: nil)
                        } else if (localPlayer.isAuthenticated) {
                            // 2. Player is already authenticated & logged in, load game center
                            self.gcEnabled = true
                            // Get the default leaderboard ID
                            localPlayer.loadDefaultLeaderboardIdentifier(completionHandler: { (leaderboardIdentifer, error) in
                                if error != nil { print(error!)
                                } else {
                                    self.gcDefaultLeaderBoard = leaderboardIdentifer!
                                    let gcVC = GKGameCenterViewController()
                                    gcVC.gameCenterDelegate = self as GKGameCenterControllerDelegate
                                    gcVC.viewState = .leaderboards
                                    gcVC.leaderboardIdentifier = self.LEADERBOARD_ID
                                    self.view?.window?.rootViewController?.present(gcVC, animated: true, completion: nil)
                                }
                            })
                            
                        } else {
                            // 3. Game center is not enabled on the users device
                            self.gcEnabled = false
                            print("Local player could not be authenticated!")
                            print(error!)
                        }
                }
                
                // Submit score to GC leaderboard
                let bestScoreInt = GKScore(leaderboardIdentifier: LEADERBOARD_ID)
                bestScoreInt.value = Int64((scoreLabel?.text)!)!
                GKScore.report([bestScoreInt]) { (error) in
                    if error != nil {
                        print(error!.localizedDescription)
                    } else {
                        print("submitted")
                    }
                }
            }
        }
    }
}
