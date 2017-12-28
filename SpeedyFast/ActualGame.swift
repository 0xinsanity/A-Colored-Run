//
//  ActualGame.swift
//  SpeedyFast
//
//  Created by Noah Hanover on 6/25/16.
//  Copyright © 2016 Noah Hanover. All rights reserved.
//

import SpriteKit
import GameKit
import GoogleMobileAds
//import StoreKit

class ActualGame: SKScene, SKPhysicsContactDelegate, SKButtonDelegate, GKGameCenterControllerDelegate/*, SKProductsRequestDelegate, SKPaymentTransactionObserver*/ {
    var node_player: SKNode!
    var node_world: SKNode!
    var node_camera: SKNode!
    var top_bar: SKShapeNode!
    var middle_bar: SKShapeNode!
    var bottom_bar: SKShapeNode!
    var current_color: SKColor!
    let possible_colors = [SKColor.greenColor(), SKColor.redColor(), SKColor.blueColor(), SKColor.yellowColor(), SKColor.magentaColor(), SKColor.brownColor(), SKColor.lightGrayColor(), SKColor.whiteColor(), SKColor.grayColor(), SKColor.cyanColor(), SKColor.orangeColor(), SKColor.purpleColor()]
    var score: ShadowLabelNode!
    var score_num: Int!
    var high_score_easy: Int!
    var high_score_hard: Int!
    var started_swipe: Bool!
    var try_number: Int!
    var interstitial_ads: GADInterstitial!
    var swipe_to_start: SKMultilineLabel!
    var easy_button: SKButton!
    var hard_button: SKButton!
    var leaderboard: SKButton!
    var current_mode: String!
    
    //var list = [SKProduct]()
    //var p = SKProduct()
    
    
    override func didMoveToView(view: SKView) {
        createAndLoadInterstitial()
        try_number = 0
        
        if (NSUserDefaults.standardUserDefaults().valueForKey("HighScoreEasy") != nil) {
            high_score_easy = NSUserDefaults.standardUserDefaults().valueForKey("HighScoreEasy") as! Int
        } else {
            high_score_easy = 0
        }
        
        if (NSUserDefaults.standardUserDefaults().valueForKey("HighScoreHard") != nil) {
            high_score_hard = NSUserDefaults.standardUserDefaults().valueForKey("HighScoreHard") as! Int
        } else {
            high_score_hard = 0
        }
        
        let leaderboardRequest_easy = GKLeaderboard(players: [GKLocalPlayer.localPlayer()]) as GKLeaderboard!
        leaderboardRequest_easy.identifier = "high_score_speedy_fast"
        
        if leaderboardRequest_easy != nil {
            leaderboardRequest_easy.loadScoresWithCompletionHandler({ (scores: [GKScore]?, error: NSError?) in
                if error != nil {
                    //handle error
                }
                else {
                    if (scores != nil) {
                        for score in scores! {
                            if (self.high_score_easy < Int(score.value)) {
                                self.high_score_easy = Int(score.value)
                                NSUserDefaults.standardUserDefaults().setInteger(self.high_score_easy, forKey: "HighScoreEasy")
                            }

                        }
                    }
                }
            })
        }
        
        let leaderboardRequest_hard = GKLeaderboard(players: [GKLocalPlayer.localPlayer()]) as GKLeaderboard!
        leaderboardRequest_hard.identifier = "high_score_hard"
        
        if leaderboardRequest_hard != nil {
            leaderboardRequest_hard.loadScoresWithCompletionHandler({ (scores: [GKScore]?, error: NSError?) in
                if error != nil {
                    //handle error
                }
                else {
                    if (scores != nil) {
                        for score in scores! {
                            if (self.high_score_hard < Int(score.value)) {
                                self.high_score_hard = Int(score.value)
                                NSUserDefaults.standardUserDefaults().setInteger(self.high_score_hard, forKey: "HighScoreHard")
                            }
                        
                        }
                    }
                }
            })
        }
        
        
        started_swipe = false
        node_world = SKNode()
        self.addChild(node_world)
        
        node_camera = SKNode()
        node_camera.name = "Camera"
        node_world.addChild(node_camera)
        
        physicsWorld.gravity = CGVectorMake(0, 0)
        physicsWorld.contactDelegate = self
        
        node_player = SKNode()
        
        let player_img = SKShapeNode(circleOfRadius: 30)
        player_img.name = "circle_buddy"
        player_img.fillColor = SKColor.greenColor()
        player_img.strokeColor = SKColor.blackColor()
        let face_img = SKSpriteNode(imageNamed: "FaceSpeedyFast")
        
        node_player.addChild(player_img)
        node_player.addChild(face_img)
        node_player.physicsBody = SKPhysicsBody.init(circleOfRadius: 30)
        node_player.position = CGPointMake(0, 30)
        node_player.physicsBody?.velocity = CGVectorMake(320, 0)
        node_player.physicsBody?.dynamic = true
        node_player.zPosition = 1
        node_player.physicsBody?.collisionBitMask = 0
        node_player.physicsBody?.contactTestBitMask = 0
        node_world.addChild(node_player)
        
        /*let skyTexture = SKTexture(imageNamed: "sky")
        skyTexture.filteringMode = .Nearest
        
        let sprite = SKSpriteNode(texture: skyTexture)
        sprite.setScale(2.0)
        sprite.zPosition = -1
        sprite.position = CGPoint(x: 0, y: 0)
        var number: CGFloat = 0
        sprite.runAction(SKAction.repeatActionForever(SKAction.sequence([SKAction.waitForDuration(6), SKAction.runBlock({
            number += 1
            let copy_spr = sprite.copy() as! SKSpriteNode
            copy_spr.position = CGPoint(x: sprite.frame.width+(sprite.position.x*number), y: 0)
            self.node_world.addChild(copy_spr)
        })])))
        node_world.addChild(sprite)*/
        
        if (current_mode == nil) {
            current_mode = "easy"
        }
        
        swipe_to_start = SKMultilineLabel(text: "Swipe Up or Down to Start", labelWidth: 160, pos: CGPointMake(node_player.position.x+65, 30), fontName: "04b_19", fontSize: 20, fontColor: SKColor(white: 1, alpha: 1), leading: 25, alignment: SKLabelHorizontalAlignmentMode.Center, shouldShowBorder: false)
        //swipe_to_start.fontColor = SKColor(white: 1, alpha: 1)
        //swipe_to_start.fontSize = 20
        //swipe_to_start.text = "Swipe Up or\nDown to Start"
        swipe_to_start.zPosition = 2
        node_world.addChild(swipe_to_start)
        
        score = ShadowLabelNode(fontNamed: "04b_19")
        score.fontColor = SKColor(white: 1, alpha: 1)
        score.fontSize = 100
        score_num = 0
        score.text = "\(score_num)"
        score.zPosition = 2
        node_world.addChild(score)
        
        let swipeUp:UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(swipedUp))
        swipeUp.direction = .Up
        view.addGestureRecognizer(swipeUp)
        
        let swipeDown:UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(swipedDown))
        swipeDown.direction = .Down
        view.addGestureRecognizer(swipeDown)
        
        if (current_mode == "easy") {
            node_world.runAction(SKAction.repeatActionForever(SKAction.sequence([createRow(), SKAction.waitForDuration(1.5)])))
        } else {
            node_world.runAction(SKAction.repeatActionForever(SKAction.sequence([createRow(), SKAction.waitForDuration(1)])))
        }
    }
    
    func didBeginContact(contact: SKPhysicsContact) {
        if (contact.bodyA.collisionBitMask != contact.bodyB.collisionBitMask) {
            started_swipe = false
            // You Lost
            node_world.paused = true
            self.node_world.removeAllChildren()
            node_player.physicsBody?.velocity = CGVectorMake(0, 0)
            
            let cover_everything = SKShapeNode(rectOfSize: self.view!.frame.size)
            cover_everything.name = "Cover"
            cover_everything.fillColor = SKColor.orangeColor()
            cover_everything.strokeColor = SKColor.clearColor()
            cover_everything.position = CGPointMake(self.view!.frame.size.width/2, self.view!.frame.size.height/2)
            cover_everything.alpha = 0
            cover_everything.zPosition = 4
            self.addChild(cover_everything)
            
            /*let remove_ads = SKButton()
            remove_ads.color = UIColor.whiteColor()
            remove_ads.fontColor = UIColor.orangeColor()
            remove_ads.size = CGSize(width: 50, height: 60)
            remove_ads.position = CGPointMake(0, 130)
            remove_ads.text = "Remove Ads"
            remove_ads.fontName = "04b_19"
            remove_ads.textOffset = CGPointMake(0, -13)
            remove_ads.delegate = self
            remove_ads.name = "remove ads"
            cover_everything.addChild(remove_ads)*/
            
            let restart = SKButton()
            restart.color = UIColor.whiteColor()
            restart.fontColor = UIColor.orangeColor()
            restart.size = CGSize(width: 50, height: 60)
            restart.position = CGPointMake(0, 120)
            restart.text = "Restart"
            restart.name = "restart"
            restart.fontName = "04b_19"
            restart.textOffset = CGPointMake(0, -13)
            restart.delegate = self
            cover_everything.addChild(restart)
            
            let leaderboards = SKButton()
            leaderboards.color = UIColor.whiteColor()
            leaderboards.fontColor = UIColor.orangeColor()
            leaderboards.size = CGSize(width: 50, height: 60)
            leaderboards.position = CGPointMake(0, 30)
            leaderboards.text = "Leaderboards"
            leaderboards.name = "leaderboards"
            leaderboards.fontName = "04b_19"
            leaderboards.textOffset = CGPointMake(0, -13)
            leaderboards.delegate = self
            cover_everything.addChild(leaderboards)
            
            let easy_click = SKButton()
            easy_click.fontColor = UIColor.whiteColor()
            easy_click.size = CGSize(width: 50, height: 60)
            easy_click.position = CGPointMake(-50, 225)
            easy_click.text = "Easy"
            easy_click.name = "easy_died"
            easy_click.fontName = "04b_19"
            easy_click.textOffset = CGPointMake(0, -13)
            easy_click.delegate = self
            cover_everything.addChild(easy_click)
            
            let hard_click = SKButton()
            hard_click.color = UIColor.orangeColor()
            hard_click.fontColor = UIColor.whiteColor()
            hard_click.size = CGSize(width: 50, height: 60)
            hard_click.position = CGPointMake(50, 225)
            hard_click.text = "Hard"
            hard_click.name = "hard_died"
            hard_click.fontName = "04b_19"
            hard_click.textOffset = CGPointMake(0, -13)
            hard_click.delegate = self
            cover_everything.addChild(hard_click)
            
            if (self.current_mode == "easy") {
                easy_click.color = UIColor.greenColor()
                hard_click.color = UIColor.orangeColor()
            } else {
                easy_click.color = UIColor.orangeColor()
                hard_click.color = UIColor.greenColor()
            }
            
            if (current_mode == "easy") {
                if (self.high_score_easy == 0 || self.score_num > self.high_score_easy) {
                    self.high_score_easy = score_num
                }
            } else {
                if (self.high_score_hard == 0 || self.score_num > self.high_score_hard) {
                    self.high_score_hard = score_num
                }
            }
            
            NSUserDefaults.standardUserDefaults().setInteger(self.high_score_easy, forKey: "HighScoreEasy")
            NSUserDefaults.standardUserDefaults().setInteger(self.high_score_hard, forKey: "HighScoreHard")
            
            var this_score: SKMultilineLabel
            var high_position: CGPoint
            var high_labelwidth: Int
            var high_fontsize: CGFloat
            if (MenuGame.DeviceType.IS_IPHONE_6 || MenuGame.DeviceType.IS_IPHONE_6P) {
                this_score = SKMultilineLabel(text: "Current Score: \(score_num)", labelWidth: 325, pos: CGPointMake(0, -100), fontName: "04b_19", fontSize: 40, fontColor: SKColor(white: 1,alpha:1), leading: 45, alignment: SKLabelHorizontalAlignmentMode.Center, shouldShowBorder: false)
                high_position = CGPoint(x: 0,y: -200)
                high_fontsize = 40
                high_labelwidth = 250
            } else if (MenuGame.DeviceType.IS_IPHONE_4_OR_LESS) {
                this_score = SKMultilineLabel(text: "Current Score: \(score_num)", labelWidth: 250, pos: CGPointMake(0, -45), fontName: "04b_19", fontSize: 30, fontColor: SKColor(white: 1,alpha:1), leading: 45, alignment: SKLabelHorizontalAlignmentMode.Center, shouldShowBorder: false)
                high_position = CGPoint(x: 0,y: -135)
                hard_click.position = CGPointMake(50, 157)
                easy_click.position = CGPointMake(-50, 157)
                high_fontsize = 30
                high_labelwidth = 175
                restart.position = CGPointMake(0, 80)
                leaderboards.position = CGPointMake(0, -10)
            } else {
                this_score = SKMultilineLabel(text: "Current Score: \(score_num)", labelWidth: 250, pos: CGPointMake(0, -70), fontName: "04b_19", fontSize: 30, fontColor: SKColor(white: 1,alpha:1), leading: 45, alignment: SKLabelHorizontalAlignmentMode.Center, shouldShowBorder: false)
                high_position = CGPoint(x: 0,y: -175)
                hard_click.position = CGPointMake(50, 180)
                easy_click.position = CGPointMake(-50, 180)
                high_fontsize = 30
                high_labelwidth = 175
                restart.position = CGPointMake(0, 80)
                leaderboards.position = CGPointMake(0, -10)
            }
            this_score.name = "current_score"
            this_score.zPosition = 2
            cover_everything.addChild(this_score)
            
            
            let high_score: SKMultilineLabel
            if (current_mode == "easy") {
                high_score = SKMultilineLabel(text: "High Score: \(self.high_score_easy)", labelWidth: high_labelwidth, pos: high_position, fontName: "04b_19", fontSize: high_fontsize, fontColor: SKColor(white: 1,alpha:1), leading: 45, alignment: SKLabelHorizontalAlignmentMode.Center, shouldShowBorder: false)
            } else {
                high_score = SKMultilineLabel(text: "High Score: \(self.high_score_hard)", labelWidth: high_labelwidth, pos: high_position, fontName: "04b_19", fontSize: high_fontsize, fontColor: SKColor(white: 1,alpha:1), leading: 45, alignment: SKLabelHorizontalAlignmentMode.Center, shouldShowBorder: false)
            }
            
            high_score.name = "high_score"
            high_score.zPosition = 2
            cover_everything.addChild(high_score)
            
            self.node_world.addChild(node_player)
            self.node_world.addChild(node_camera)
            self.try_number! += 1
            
            cover_everything.runAction(SKAction.sequence([SKAction.fadeInWithDuration(1)]))
        }
    }
    
    func createAndLoadInterstitial() {
        interstitial_ads = GADInterstitial(adUnitID: "ca-app-pub-8777121736512556/8654440029")
        let request = GADRequest()
        // Request test ads on devices you specify. Your test device ID is printed to the console when
        // an ad request is made.
        //request.testDevices = ["d0b3ead5ca64796bd0a5270efc80c169"]
        interstitial_ads.loadRequest(request)
    }
    
    override func update(currentTime: NSTimeInterval) {
        if (node_world.paused) {
            node_player.physicsBody?.velocity = CGVectorMake(0, 0)
            self.childNodeWithName("top bar")?.physicsBody?.velocity = CGVectorMake(0, 0)
            self.childNodeWithName("middle bar")?.physicsBody?.velocity = CGVectorMake(0, 0)
            self.childNodeWithName("bottom bar")?.physicsBody?.velocity = CGVectorMake(0, 0)
        } else {
            node_player.physicsBody?.velocity = CGVectorMake(320, 0)
        }
        if (MenuGame.DeviceType.IS_IPHONE_5) {
            score.position = CGPointMake(node_player.position.x+115, 100)
        } else if (MenuGame.DeviceType.IS_IPHONE_4_OR_LESS) {
            score.position = CGPointMake(node_player.position.x+115, -250)
        } else {
            score.position = CGPointMake(node_player.position.x+115, 200)
        }
        swipe_to_start.position = CGPointMake(node_player.position.x+65, 30)
        
    }
    
    func createRow() -> SKAction {
        let makeRow = SKAction.runBlock({
            if (!self.started_swipe) {
                return
            }
            var fill_colors = [self.randomColor(self.possible_colors), SKColor(), SKColor()]
            var next_color = self.randomColor(self.possible_colors)
            repeat {
                next_color = self.randomColor(self.possible_colors)
            } while (next_color == fill_colors[0])
            fill_colors[1] = next_color
            
            repeat {
                next_color = self.randomColor(self.possible_colors)
            } while (next_color == fill_colors[0] || next_color == fill_colors[1])
            fill_colors[2] = next_color
            
            var x_position: CGFloat
            if (self.current_mode == "easy") {
                x_position = self.node_player.position.x+400
            } else {
                x_position = self.node_player.position.x+500
            }
            self.top_bar = SKShapeNode(rectOfSize: CGSize(width: 100, height: self.view!.frame.height/3))
            self.top_bar.strokeColor = SKColor.clearColor()
            self.top_bar.fillColor = fill_colors[0]
            self.top_bar.zPosition = 0
            self.top_bar.name = "top bar"
            self.top_bar.physicsBody = SKPhysicsBody.init(rectangleOfSize: CGSize(width: 100, height: (self.view!.frame.height/3)-1))
            self.top_bar.position = CGPointMake(x_position, 255)
            self.node_world.addChild(self.top_bar)
            
            self.middle_bar = self.top_bar.copy() as! SKShapeNode
            self.middle_bar.fillColor = fill_colors[1]
            self.middle_bar.name = "middle bar"
            self.middle_bar.position = CGPointMake(x_position, 32)
            self.node_world.addChild(self.middle_bar)
            
            self.bottom_bar = self.top_bar.copy() as! SKShapeNode
            self.bottom_bar.fillColor = fill_colors[2]
            self.bottom_bar.name = "bottom bar"
            self.bottom_bar.position = CGPointMake(x_position, -190)
            self.node_world.addChild(self.bottom_bar)
            
            if (MenuGame.DeviceType.IS_IPHONE_5 || MenuGame.DeviceType.IS_IPHONE_4_OR_LESS) {
                self.bottom_bar.position = CGPointMake(x_position, -191)
                self.middle_bar.position = CGPointMake(x_position, 0)
                self.top_bar.position = CGPointMake(x_position, 191)
            }
            
            var position: Int
            if (self.node_player.position.y >= 199) {
                position = 0
            } else if (self.node_player.position.y <= -160) {
                position = 2
            } else {
                position = 1
            }
            
            if (self.current_mode == "easy") {
                self.addScoreAndColor(fill_colors, position: position)
            } else {
                self.node_world.runAction(SKAction.sequence([SKAction.waitForDuration(0.7), SKAction.runBlock({
                    self.addScoreAndColor(fill_colors, position: position)
                })]))
            }
            
        })
        return makeRow
    }
    
    func addScoreAndColor(fill_colors: [SKColor], position: Int) {
        var player_color = self.randomColor(fill_colors)
        while (player_color == fill_colors[position]) {
            player_color = self.randomColor(fill_colors)
        }
        (self.node_player.childNodeWithName("circle_buddy") as! SKShapeNode).fillColor = player_color
        
        if (player_color == fill_colors[1]) {
            self.middle_bar.physicsBody?.collisionBitMask = 0
            self.middle_bar.physicsBody?.contactTestBitMask = 0
            
            self.top_bar.physicsBody?.collisionBitMask = 1
            self.top_bar.physicsBody?.contactTestBitMask = 1
            
            self.bottom_bar.physicsBody?.collisionBitMask = 1
            self.bottom_bar.physicsBody?.contactTestBitMask = 1
        } else if (player_color == fill_colors[2]) {
            self.middle_bar.physicsBody?.collisionBitMask = 1
            self.middle_bar.physicsBody?.contactTestBitMask = 1
            
            self.top_bar.physicsBody?.collisionBitMask = 1
            self.top_bar.physicsBody?.contactTestBitMask = 1
            
            self.bottom_bar.physicsBody?.collisionBitMask = 0
            self.bottom_bar.physicsBody?.contactTestBitMask = 0
        } else {
            self.middle_bar.physicsBody?.collisionBitMask = 1
            self.middle_bar.physicsBody?.contactTestBitMask = 1
            
            self.top_bar.physicsBody?.collisionBitMask = 0
            self.top_bar.physicsBody?.contactTestBitMask = 0
            
            self.bottom_bar.physicsBody?.collisionBitMask = 1
            self.bottom_bar.physicsBody?.contactTestBitMask = 1
        }
        self.score_num! += 1
        self.score.text = "\(self.score_num)"
    }
    
    func swipedUp(sender:UISwipeGestureRecognizer){
        if (self.scene!.paused == true) {
            return
        }
        started_swipe = true
        if (swipe_to_start.alpha != 0) {
            swipe_to_start.runAction(SKAction.fadeOutWithDuration(0.5))
        }
        if (node_player.position.y <= 199) {
            let new_position = node_player.position.y+200
            node_player.runAction(SKAction.moveToY(new_position, duration: 0.1))
        }
    }
    
    func swipedDown(sender:UISwipeGestureRecognizer){
        if (self.scene!.paused == true) {
            return
        }
        
        started_swipe = true
        if (swipe_to_start.alpha != 0) {
            swipe_to_start.runAction(SKAction.fadeOutWithDuration(0.5))
        }
        if (node_player.position.y >= -160) {
            let new_position = node_player.position.y-200
            node_player.runAction(SKAction.moveToY(new_position, duration: 0.1))
        }
    }
    
    func restart() {
        if (self.try_number! == 5) {
            self.try_number! = 0
            if (interstitial_ads.isReady) {
                interstitial_ads.presentFromRootViewController(UIApplication.sharedApplication().keyWindow!.rootViewController!)
            }
        }
        
        self.childNodeWithName("Cover")!.runAction(SKAction.fadeOutWithDuration(0.3)) {
            self.node_world.removeAllActions()
            self.childNodeWithName("Cover")!.removeFromParent()
            
            self.node_player.position = CGPointMake(0, 30)
            //self.node_world.addChild(self.node_camera)
            //self.node_world.addChild(self.node_player)
            if (self.score.parent == nil) {
                self.node_world.addChild(self.score)
            }
            self.score_num = 0
            self.score.text = "\(self.score_num)"
            self.node_world.addChild(self.swipe_to_start)
            self.swipe_to_start.alpha = 1
            
            self.node_world.paused = false
            if (self.current_mode == "easy") {
                self.node_world.runAction(SKAction.repeatActionForever(SKAction.sequence([self.createRow(), SKAction.waitForDuration(1.5)])))
            } else {
                self.node_world.runAction(SKAction.repeatActionForever(SKAction.sequence([self.createRow(), SKAction.waitForDuration(1)])))
            }
            self.createAndLoadInterstitial()
        }
    }
    
    override func didFinishUpdate() {
        node_camera.position = CGPoint(x: node_player.position.x, y: 0)
        self.centerOnNode(node_camera)
        
    }
    
    func centerOnNode(node: SKNode) {
        let cameraPositionInScene: CGPoint = node.scene!.convertPoint(node.position, fromNode: node_world)
        node.parent!.position = CGPoint(x:node.parent!.position.x - cameraPositionInScene.x + 80, y:300)
    }
    
    func randomColor(color_array: [SKColor]) -> SKColor {
        let rand_num = arc4random_uniform(UInt32(color_array.count))
        return color_array[Int(rand_num)]
    }
    
    func skButtonTouchEnded(sender: SKButton) {}
    func skButtonTouchBegan(sender: SKButton) {
        //print("click")
        if (sender.name! == "restart") {
            // restart
            restart()
        } else if (sender.name! == "easy_died") {
            // Easy Mode
            sender.color = UIColor.greenColor()
            (sender.parent?.childNodeWithName("hard_died") as! SKButton).color = UIColor.orangeColor()
            (sender.parent?.childNodeWithName("high_score") as! SKMultilineLabel).text = "High Score: \(high_score_easy)"
            (sender.parent?.childNodeWithName("current_score") as! SKMultilineLabel).text = "Current Score: 0"
            current_mode = "easy"
        } else if (sender.name! == "hard_died") {
            // Hard Mode
            sender.color = UIColor.greenColor()
            (sender.parent?.childNodeWithName("easy_died") as! SKButton).color = UIColor.orangeColor()
            (sender.parent?.childNodeWithName("high_score") as! SKMultilineLabel).text = "High Score: \(high_score_hard)"
            (sender.parent?.childNodeWithName("current_score") as! SKMultilineLabel).text = "Current Score: 0"
            current_mode = "hard"
        } else if (sender.name! == "leaderboards") {
            // go to leaderboards
            var newGCScore: GKScore
            if (current_mode == "easy") {
                newGCScore = GKScore(leaderboardIdentifier: "high_score_speedy_fast")
                newGCScore.value = Int64(high_score_easy!)
            } else {
                newGCScore = GKScore(leaderboardIdentifier: "high_score_hard")
                newGCScore.value = Int64(high_score_hard!)
            }
            GKScore.reportScores([newGCScore], withCompletionHandler: nil)
            
            let gcViewController = GKGameCenterViewController()
            gcViewController.gameCenterDelegate = self
            gcViewController.viewState = GKGameCenterViewControllerState.Leaderboards
            gcViewController.leaderboardIdentifier = "MySecondGameLeaderboard"
            
            // Show leaderboard
            UIApplication.sharedApplication().keyWindow!.rootViewController!.presentViewController(gcViewController, animated: true, completion: nil)
            
        } /*else if (sender.name! == "remove ads") {
            // remove ads
            if (SKPaymentQueue.canMakePayments()) {
                var productid = Set<String>()
                productid.insert("removeads_speedyfast")
                let payment = SKProductsRequest(productIdentifiers: productid)
                payment.delegate = self
                payment.start()
                
                for product in list {
                    p = product
                    buyProduct()
                }
            }
        } else {
            // go back
        }*/
    }
    
    func gameCenterViewControllerDidFinish(gameCenterViewController: GKGameCenterViewController) {
        gameCenterViewController.dismissViewControllerAnimated(true, completion: nil)
    }
    /*
    // 4
    func removeAds() {
        print("ads removed")
    }
    
    // 6
    func RestorePurchases() {
        SKPaymentQueue.defaultQueue().addTransactionObserver(self)
        SKPaymentQueue.defaultQueue().restoreCompletedTransactions()
    }
    
    // 2
    func buyProduct() {
        print("buy " + p.productIdentifier)
        let pay = SKPayment(product: p)
        SKPaymentQueue.defaultQueue().addTransactionObserver(self)
        SKPaymentQueue.defaultQueue().addPayment(pay as SKPayment)
    }
    
    //3
    func productsRequest(request: SKProductsRequest, didReceiveResponse response: SKProductsResponse) {
        print("product request")
        let myProduct = response.products
        
        for product in myProduct {
            print("product added")
            print(product.productIdentifier)
            print(product.localizedTitle)
            print(product.localizedDescription)
            print(product.price)
            
            list.append(product as SKProduct)
        }
    }
    
    // 4
    func paymentQueueRestoreCompletedTransactionsFinished(queue: SKPaymentQueue) {
        print("transactions restored")
        
        //let purchasedItemIDS = []
        for transaction in queue.transactions {
            let t: SKPaymentTransaction = transaction as SKPaymentTransaction
            
            let prodID = t.payment.productIdentifier as String
            
            switch prodID {
            case "bundle id":
                print("remove ads")
                removeAds()
            default:
                print("IAP not setup")
            }
            
        }
    }
    
    func paymentQueue(queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        print("add paymnet")
        
        for transaction:AnyObject in transactions {
            let trans = transaction as! SKPaymentTransaction
            print(trans.error)
            
            switch trans.transactionState {
                
            case .Purchased:
                print("buy, ok unlock iap here")
                print(p.productIdentifier)
                
                let prodID = p.productIdentifier as String
                switch prodID {
                case "bundle id":
                    print("remove ads")
                    removeAds()
                default:
                    print("IAP not setup")
                }
                
                queue.finishTransaction(trans)
                break;
            case .Failed:
                print("buy error")
                queue.finishTransaction(trans)
                break;
            default:
                print("default")
                break;
                
            }
        }
    }
    
    // 6
    func finishTransaction(trans:SKPaymentTransaction)
    {
        print("finish trans")
    }
    
    func paymentQueue(queue: SKPaymentQueue, removedTransactions transactions: [SKPaymentTransaction]) {
        print("remove trans")
    }*/
}
