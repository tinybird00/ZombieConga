//
//  GameViewController.swift
//  ZombieConga
//
//  Created by mark on 2018/7/2.
//  Copyright © 2018年 3dragons. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit

class GameViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
//        let scene = GameScene(size: CGSize(width: 2048, height: 1534))
        let scene = GameScene(size: UIScreen.main.bounds.size)

        scene.scaleMode = .aspectFit
        
        let skView = self.view as! SKView
        skView.showsFPS = true
        skView.showsNodeCount = true
        skView.ignoresSiblingOrder = true
        skView.presentScene(scene)
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
}
