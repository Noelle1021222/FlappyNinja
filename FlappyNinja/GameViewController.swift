//
//  GameViewController.swift
//  FlappyNinja
//
//  Created by 許雅筑 on 2016/9/26.
//  Copyright (c) 2016年 hsu.ya.chu. All rights reserved.
//

import UIKit
import SpriteKit
import AVFoundation


class GameViewController: UIViewController {
    var skView: SKView?

    override func viewDidLoad() {
        super.viewDidLoad()
//        self.skView = self.view as? SKView
//        self.skView!.showsFPS = true
//        self.skView!.showsNodeCount = true
//        
////        self.skView = self.view as? SKView


        if let scene = GameScene(fileNamed:"GameScene") {
            // Configure the view.
            let skView = self.view as! SKView
            skView.showsFPS = true
            skView.showsNodeCount = true
            
            /* Sprite Kit applies additional optimizations to improve rendering performance */
            skView.ignoresSiblingOrder = true
            
            /* Set the scale mode to scale to fit the window */
            scene.scaleMode = .AspectFill
            scene.size = self.view.bounds.size
          
            skView.presentScene(scene)
    }

    }


    
    override func shouldAutorotate() -> Bool {
        return true
    }

//    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
//        if UIDevice.currentDevice().userInterfaceIdiom == .Phone {
//            return .AllButUpsideDown
//        } else {
//            return .All
//        }
//    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
}
