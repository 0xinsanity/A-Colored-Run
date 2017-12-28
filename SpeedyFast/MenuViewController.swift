//
//  ViewController.swift
//  SpeedyFast
//
//  Created by Noah Hanover on 6/25/16.
//  Copyright © 2016 Noah Hanover. All rights reserved.
//

import UIKit
import SpriteKit
import GameKit
import GoogleMobileAds

class MenuViewController: UIViewController, GADBannerViewDelegate {
    var banner_ads: GADBannerView!
    var already_loaded: Bool!
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        let game = MenuGame(size: self.view.frame.size)
        let request = GADRequest()
        //request.testDevices = ["d0b3ead5ca64796bd0a5270efc80c169"]
        if (already_loaded == false) {
            (view as! SKView).presentScene(game)
            banner_ads.loadRequest(request)
            self.view.addSubview(banner_ads)
            already_loaded = true
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        initGameCenter()
        already_loaded = false
        
        let mainView = SKView(frame: self.view.frame)
        //mainView.showsNodeCount = true
        //mainView.showsFPS = true
        //mainView.showsDrawCount = true
        view = mainView
        
        banner_ads = GADBannerView(adSize: kGADAdSizeSmartBannerPortrait)
        banner_ads.adUnitID = "ca-app-pub-8777121736512556/4084639621"
        banner_ads.rootViewController = self
        banner_ads.delegate = self
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // Initialize Game Center
    func initGameCenter() {
        
        // Check if user is already authenticated in game center
        if GKLocalPlayer.localPlayer().authenticated == false {
            
            // Show the Login Prompt for Game Center
            GKLocalPlayer.localPlayer().authenticateHandler = {(viewController, error) -> Void in
                if viewController != nil {
                    self.presentViewController(viewController!, animated: true, completion: nil)
                }
            }
        }
    }
}

