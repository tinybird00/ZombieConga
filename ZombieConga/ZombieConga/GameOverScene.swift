//
//  GameOverScene.swift
//  ZombieConga
//
//  Created by mark on 2018/7/20.
//  Copyright © 2018年 3dragons. All rights reserved.
//

import Foundation
import SpriteKit

class GameOverScene: SKScene {
    
    var won:Bool?
    
    init(size: CGSize,won:Bool) {
        self.won = won
        super.init(size: size)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError(" init( coder:) has not been implemented")
    }
 
    override func didMove(to view: SKView) {
        var background:SKSpriteNode
        if won! {
            background = SKSpriteNode.init(imageNamed: "YouWin")
            background.size = size
            background.setScale(0.5)
            run(SKAction.sequence([
                SKAction.wait(forDuration: 0.1),
                SKAction.playSoundFileNamed("win.wav", waitForCompletion: false)
                ]))
        } else {
            background = SKSpriteNode.init(imageNamed: "YouLose")
            background.size = size
            run(SKAction.sequence([
                SKAction.wait(forDuration: 0.1),
                SKAction.playSoundFileNamed("lose.wav", waitForCompletion: false)
                ]))
        }
        background.position = CGPoint.init(x: size.width/2, y: size.height/2)
        addChild(background)
        
        let wait = SKAction.wait(forDuration: 3)
        let block = SKAction.run {
            let gameScene = GameScene.init(size: self.size)
            let reveal = SKTransition.flipVertical(withDuration: 0.5)
            self.view?.presentScene(gameScene, transition: reveal)
        }
        run(SKAction.sequence([wait,block]))
    }
}


