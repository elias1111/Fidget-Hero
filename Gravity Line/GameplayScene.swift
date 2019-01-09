//
//  GameplayScene.swift
//  Gravity Line
//
//  Created by Elias Stevenson on 6/2/17.
//  Copyright © 2017 Elias Stevenson. All rights reserved.
//

import Foundation
import SpriteKit
import GameKit
import GoogleMobileAds

class GameplayScene: SKScene, SKPhysicsContactDelegate, GKGameCenterControllerDelegate, GADInterstitialDelegate{
    
    var gcEnabled = Bool()
    var gcDefaultLeaderBoard = String()
    var score = 0
    var highScore =  UserDefaults.standard.integer(forKey: "HIGHSCORE")
    let defaults = UserDefaults.standard
    let LEADERBOARD_ID = "com.score.fidgethero"
    var ad : GADInterstitial!
    private var BG1: BGClass?
    private var BG2: BGClass?
    private var BG3: BGClass?
    private var pause: SKNode?
    private var scoreLabel: SKLabelNode?
    private var tap: SKLabelNode?
    private var taphold: SKLabelNode?
    private var location = CGPoint()
    var player: lineClass?
    var minHeight = 200
    var maxHeight = 900
    var impulse1 = CGVector(dx: 0, dy: 19)
    var impulse2 = CGVector(dx: 0, dy: 13)
    private var wallCon = wallController()
    let tgr = UITapGestureRecognizer()
    let lpgr = UILongPressGestureRecognizer()
    var ISlpgr: Bool = false
    var gameOver: Bool = false
    var scoreRepeat: Bool = true
    let launchedBefore = UserDefaults.standard.bool(forKey: "launchedBefore")
    
    private var mainCamera: SKCameraNode?;
    
    func gameCenterViewControllerDidFinish(_ gameCenterViewController: GKGameCenterViewController) {
        gameCenterViewController.dismiss(animated: true, completion: nil)
    }
    
    override func didMove(to view: SKView) {
        if launchedBefore != true{
            let alert = UIAlertController(title: "Controls" , message: "Tap to jump // Tap & Hold to glide", preferredStyle: .alert)
            let defaultAction = UIAlertAction(title: "Dismiss", style: .default, handler: nil)
            alert.addAction(defaultAction)
            self.view?.window?.rootViewController?.present(alert, animated: true, completion: nil)
            UserDefaults.standard.set(true, forKey: "launchedBefore")
        }
        self.view?.showsFPS = false
        self.view?.showsNodeCount = false
        self.ad = GADInterstitial(adUnitID: "ca-app-pub-8240706232956319/5460256659")
        self.lpgr.minimumPressDuration = 0.13
        self.view?.addGestureRecognizer(self.lpgr)
        self.view?.addGestureRecognizer(self.tgr)
        self.tgr.numberOfTapsRequired = 1
        let request = GADRequest()
        self.ad.load(request)
        initializeGame()
    }
    
    override func update(_ currentTime: TimeInterval) {
        if gameOver != true{
            manageLine()
            manageAngle()
        }
        manageCamera()
        manageBGs()
        self.lpgr.addTarget(self, action: #selector(GameplayScene.longPress(_:)))
        if ISlpgr != true{
            self.tgr.addTarget(self, action: #selector(GameplayScene.touches(_:)))
        }
    }
    
    private func initializeGame(){
        mainCamera = childNode(withName: "MainCamera") as? SKCameraNode!
        player = childNode(withName: "player") as? lineClass!
        player?.initialize()
        BG1 = childNode(withName: "BG1") as? BGClass!
        BG2 = childNode(withName: "BG2") as? BGClass!
        BG3 = childNode(withName: "BG3") as? BGClass!
        pause = mainCamera?.childNode(withName: "paused")
        pause?.isHidden = true
        physicsWorld.contactDelegate = self;
        
        Timer.scheduledTimer(timeInterval: TimeInterval(4), target: self, selector: #selector(GameplayScene.spawnWalls), userInfo: nil, repeats: true)
        
        Timer.scheduledTimer(timeInterval: TimeInterval(1.0), target: self, selector: #selector(GameplayScene.addScore), userInfo: nil, repeats: true)
    }
    
    func touches(_ gesture: UIGestureRecognizer) {
        if (gameOver != true){
            if(ISlpgr != true){
                jump()
            }
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?){
        if (gameOver == true){
            for touch in touches{
                let location = touch.location(in: self)
                if atPoint(location).name == "restart"{
                    restartGame()
                    if(score >= 8){
                        ad.present(fromRootViewController: (self.view?.window?.rootViewController)!)
                    }
                }
                if atPoint(location).name == "home"{
                    if let scene = mainMenuScene(fileNamed: "mainMenuScene"){
                        scene.scaleMode = .aspectFill
                        view?.presentScene(scene, transition: SKTransition.doorsCloseVertical(withDuration: 1.0))
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
                    func gameCenterViewControllerDidFinish(_ gameCenterViewController: GKGameCenterViewController) {
                        gameCenterViewController.dismiss(animated: true, completion: nil)
                    }
                    // Submit score to GC leaderboard
                    let bestScoreInt = GKScore(leaderboardIdentifier: LEADERBOARD_ID)
                    bestScoreInt.value = Int64(score)
                    GKScore.report([bestScoreInt]) { (error) in
                        if error != nil {
                            print(error!.localizedDescription)
                        } else {
                            print("submitted")
                            let gameCenerViewController =  GKGameCenterViewController()
                            gameCenerViewController.dismiss(animated: true, completion: nil)
                        }
                    }
                }
            }
        }
    }
    

    func longPress(_ gesture: UIGestureRecognizer){
            player?.physicsBody?.affectedByGravity = false
            player?.physicsBody?.velocity.dy = 0
            ISlpgr = true
            if gesture.state == .ended{
                player?.physicsBody?.affectedByGravity = true
                ISlpgr = false
            }
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        var firstBody = SKPhysicsBody()
        var secondBody = SKPhysicsBody()

        if contact.bodyA.node?.name == "player"{
            firstBody = contact.bodyA
            secondBody = contact.bodyB
        }else{
            firstBody = contact.bodyB
            secondBody = contact.bodyA
        }
        
        if firstBody.node?.name == "player" && secondBody.node?.name == "wall1" || secondBody.node?.name == "wall2"{
            firstBody.node?.physicsBody?.affectedByGravity = false
            firstBody.node?.physicsBody?.velocity.dy = 0
            firstBody.node?.physicsBody?.isDynamic = false
            if (score > highScore){
                defaults.set(score, forKey: "HIGHSCORE")
            }
            gameOver = true
            pause?.isHidden = false
            scoreRepeat = false
        }
    }

    private func manageCamera(){
        self.mainCamera?.position.x += 4
    }
    
    
    private func manageBGs(){
        BG1?.moveBG(camera: mainCamera!)
        BG2?.moveBG(camera: mainCamera!)
        BG3?.moveBG(camera: mainCamera!)
    }
    
    func spawnWalls(){
        let height1 = randomBetweenNum(firstNum: CGFloat(minHeight), secondNum: CGFloat(maxHeight))
        let height2 = 1060 - height1
        self.scene?.addChild(wallCon.spawnWall1(camera: mainCamera!, height1: height1))
        self.scene?.addChild(wallCon.spawnWall2(camera: mainCamera!, height2: height2))
    }
    
    private func manageLine(){
        player?.moveLine()
    }
    
    func updateScore(){
       
    }
    
    private func manageAngle(){
        if(ISlpgr != true){
            player?.moveTip()
        }else{
            player?.zRotation += 0.15
            
        }
    }
    
    private func jump(){
        if (player?.physicsBody?.velocity.dy)! < CGFloat(-225){
            self.player?.physicsBody?.applyImpulse(impulse1)
        }else{
            self.player?.physicsBody?.applyImpulse(impulse2)
        }
    }
    
    func restartGame(){
        if let scene:GameplayScene = GameplayScene(fileNamed: "GameplayScene") {
            scene.scaleMode = .aspectFill
            view!.presentScene(scene, transition: SKTransition.doorsOpenVertical(withDuration: TimeInterval(1.0)))
        }
    }
    
    func addScore(){
        if (gameOver != true){
            scoreLabel = mainCamera?.childNode(withName: "scoreLabel") as? SKLabelNode!
            score += 1
            scoreLabel?.text = String(score)
        }
    }
    
    func changeGravity(){
        physicsWorld.gravity.dy = -4.8
    }
    
    func randomBetweenNum(firstNum: CGFloat, secondNum: CGFloat) -> CGFloat{
        return CGFloat(arc4random()) / CGFloat(UINT32_MAX) * abs(firstNum - secondNum) + min(firstNum, secondNum)
    }
} 
