//
//  MenuGame.swift
//  SpeedyFast
//
//  Created by Noah Hanover on 6/30/16.
//  Copyright © 2016 Noah Hanover. All rights reserved.
//

import SpriteKit
import GameKit

class MenuGame: SKScene, SKButtonDelegate, GKGameCenterControllerDelegate {
    
    struct ScreenSize
    {
        static let SCREEN_WIDTH = UIScreen.mainScreen().bounds.size.width
        static let SCREEN_HEIGHT = UIScreen.mainScreen().bounds.size.height
        static let SCREEN_MAX_LENGTH = max(ScreenSize.SCREEN_WIDTH, ScreenSize.SCREEN_HEIGHT)
        static let SCREEN_MIN_LENGTH = min(ScreenSize.SCREEN_WIDTH, ScreenSize.SCREEN_HEIGHT)
    }
    
    struct DeviceType
    {
        static let IS_IPHONE_4_OR_LESS = UIDevice.currentDevice().userInterfaceIdiom == .Phone && ScreenSize.SCREEN_MAX_LENGTH < 568.0
        static let IS_IPHONE_5 = UIDevice.currentDevice().userInterfaceIdiom == .Phone && ScreenSize.SCREEN_MAX_LENGTH == 568.0
        static let IS_IPHONE_6 = UIDevice.currentDevice().userInterfaceIdiom == .Phone && ScreenSize.SCREEN_MAX_LENGTH == 667.0
        static let IS_IPHONE_6P = UIDevice.currentDevice().userInterfaceIdiom == .Phone && ScreenSize.SCREEN_MAX_LENGTH == 736.0
        static let IS_IPAD = UIDevice.currentDevice().userInterfaceIdiom == .Pad && ScreenSize.SCREEN_MAX_LENGTH == 1024.0
    }
    
    override func didMoveToView(view: SKView) {
        self.runAction(SKAction.repeatActionForever(SKAction.sequence([SKAction.playSoundFileNamed("main_colored.wav", waitForCompletion: false), SKAction.waitForDuration(86)])))
        
        let title = SKLabelNode(text: "A Colored Run")
        title.fontName = "04b_19"
        title.fontColor = UIColor.whiteColor()
        title.fontSize = 50
        title.position = CGPoint(x: self.view!.frame.width/2, y: self.view!.frame.height-140)
        title.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.Center
        
        let node_player = SKNode()
        node_player.position = CGPoint(x: self.view!.frame.width/2, y: 355)
        
        var player_img: SKShapeNode
        let face_img = SKSpriteNode(imageNamed: "FaceSpeedyFast_Large")
        if (DeviceType.IS_IPHONE_5) {
            title.fontSize = 35
            title.position = CGPoint(x: self.view!.frame.width/2, y: self.view!.frame.height-100)
            face_img.setScale(0.8)
            player_img = SKShapeNode(circleOfRadius: 110)
            
            node_player.position = CGPoint(x: self.view!.frame.width/2, y: 330)
        } else if (DeviceType.IS_IPHONE_4_OR_LESS) {
            title.fontSize = 35
            title.position = CGPoint(x: self.view!.frame.width/2, y: self.view!.frame.height-100)
            face_img.setScale(0.6)
            player_img = SKShapeNode(circleOfRadius: 80)
            
            node_player.position = CGPoint(x: self.view!.frame.width/2, y: 280)
        } else {
            player_img = SKShapeNode(circleOfRadius: 130)
            face_img.setScale(0.95)
        }
    
        player_img.name = "circle_buddy"
        player_img.fillColor = SKColor.greenColor()
        player_img.strokeColor = SKColor.blackColor()
        
        node_player.addChild(player_img)
        node_player.addChild(face_img)
        
        let easy_button = SKButton(color: UIColor.orangeColor())
        easy_button.fontName = "04b_19"
        easy_button.text = "Easy Mode"
        easy_button.fontSize = 30
        easy_button.fontColor = UIColor.whiteColor()
        easy_button.name = "easy_click"
        easy_button.delegate = self
        easy_button.position = CGPointMake(self.view!.frame.width/2, 165)
        easy_button.textOffset = CGPoint(x: 0, y: -13)
        easy_button.size = CGSize(width: 200, height: 50)
        
        let hard_button = SKButton(color: UIColor.orangeColor())
        hard_button.fontName = "04b_19"
        hard_button.text = "Hard Mode"
        hard_button.fontSize = 30
        hard_button.fontColor = UIColor.whiteColor()
        hard_button.name = "hard_click"
        hard_button.delegate = self
        hard_button.position = CGPointMake(self.view!.frame.width/2, 100)
        hard_button.textOffset = CGPoint(x: 0, y: -13)
        hard_button.size = CGSize(width: 200, height: 50)
        
        let leader_button = SKButton(buttonImage: "leaderboard_icon")
        leader_button.name = "leaderboard"
        leader_button.color = UIColor.orangeColor()
        leader_button.delegate = self
        leader_button.position = CGPointMake(self.view!.frame.width/2, 30)
        leader_button.size = CGSize(width: 40, height: 50)
        
        self.addChild(easy_button)
        self.addChild(hard_button)
        self.addChild(leader_button)
        self.addChild(title)
        self.addChild(node_player)
    }
    
    func skButtonTouchEnded(sender: SKButton) {}
    func skButtonTouchBegan(sender: SKButton) {
        if (sender.name! == "easy_click") {
            // Easy Click
            let game = ActualGame(size: self.view!.frame.size)
            game.current_mode = "easy"
            self.view?.presentScene(game, transition: SKTransition.fadeWithDuration(1))
            
        } else if (sender.name! == "hard_click") {
            // Hard Click
            let game = ActualGame(size: self.view!.frame.size)
            game.current_mode = "hard"
            self.view?.presentScene(game, transition: SKTransition.fadeWithDuration(1))
            
        } else {
            // Leaderboards
            
            let gcViewController = GKGameCenterViewController()
            gcViewController.gameCenterDelegate = self
            gcViewController.viewState = GKGameCenterViewControllerState.Leaderboards
            gcViewController.leaderboardIdentifier = "MySecondGameLeaderboard"
            
            // Show leaderboard
            UIApplication.sharedApplication().keyWindow!.rootViewController!.presentViewController(gcViewController, animated: true, completion: nil)
        }
    }
    
    func gameCenterViewControllerDidFinish(gameCenterViewController: GKGameCenterViewController) {
        gameCenterViewController.dismissViewControllerAnimated(true, completion: nil)
    }
    
}
