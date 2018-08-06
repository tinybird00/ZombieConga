//
//  GameScene.swift
//  ZombieConga
//
//  Created by mark on 2018/7/2.
//  Copyright © 2018年 3dragons. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    //MARK:- 变量声明
    var zombieNode = SKSpriteNode()
    let nodeScale:CGFloat = 0.4
    var lastUpdateTime:TimeInterval = 0
    var dt:TimeInterval = 0
    let zombieMovePointPerSecond = 120
    let catMovePointPerSecond = 120
    let zombieRotateRadiansPerSec:CGFloat = CGFloat(4*Double.pi)
    var amtToRotate:CGFloat = 0
    //zombie走路动画
    lazy var zombieAnimateAction:SKAction = {
        var textures:[SKTexture] = []
        
        for i in 1...4 {
            textures.append(SKTexture(imageNamed: "zombie\(i)"))
        }
        textures.append(textures[3])
        textures.append(textures[2])
        let zombieAction = SKAction.animate(with: textures, timePerFrame: 0.1)
        
        return zombieAction
    }()
    //碰撞音效
    let catCollisionSound:SKAction = SKAction.playSoundFileNamed("hitCat.wav", waitForCompletion: false)
    let enemyCollisionSound:SKAction = SKAction.playSoundFileNamed("hitCatLady.wav", waitForCompletion: false)
    //zombie闪烁状态
    var _zombieProtected:Bool = false
    var zombieProtected:Bool? {
        set{
            _zombieProtected = newValue!
            zombieNode.run(blinkAction) {
                self._zombieProtected = false
            }
        }
        get{
            return _zombieProtected
        }
    }
    //闪烁动作
    lazy var blinkAction:SKAction = {
        let blink:CGFloat = 10
        let duration:CGFloat = 3
        let customAction:SKAction = SKAction.customAction(withDuration: TimeInterval(duration), actionBlock: { (node, elapsedTime) in
            let slice = duration/blink
            let reminder:CGFloat = elapsedTime.truncatingRemainder(dividingBy: CGFloat(slice))
            node.isHidden = reminder>CGFloat(slice)/2
        })
        return customAction
    }()
    //目的地坐标
    var destination:CGPoint?
    //zombie单位向量
    var velocity:CGPoint? {
        didSet{
            guard oldValue != nil else {
                return
            }
            let lastAngel = oldValue?.angle
            let currentAngel = velocity?.angle
            amtToRotate = shortestAngleBetween(angle1: lastAngel!, angle2: currentAngel!)
        }
    }
    //胜败条件
    var lives = 5//等于0时失败
    var trainCount = 0//大于15时胜利
    var gameOver = false
    //相机
    let cameraNode = SKCameraNode()
    let cameraMovePointPerSecond = 200
    
    //MARK:- 主程序
    override func didMove(to view: SKView) {
        backgroundColor = SKColor.black
        velocity = CGPoint.zero
        for i in 0...1 {
            let background = backgroundNode()
            background.anchorPoint = CGPoint.zero
            background.position = CGPoint.init(x: CGFloat(i)*background.size.width, y: 0)
            background.zPosition = -1
            addChild(background)
        }
        //添加节点
        zombieNode = addZombie(position: CGPoint(x: 100, y: 100))
        let spawnEnemyAction = SKAction.run {
            self.spawnEnemy()
        }
        let sequene = SKAction.sequence([spawnEnemyAction,SKAction.wait(forDuration: 2)])
        let repeatAction = SKAction.repeatForever(sequene)
        run(repeatAction)
        
        let spawnCatAction = SKAction.run {
            self.spawnCat()
        }
        let catSequene = SKAction.sequence([spawnCatAction,SKAction.wait(forDuration: 2)])
        let repeatSpawnCat = SKAction.repeatForever(catSequene)
        run(repeatSpawnCat)
        //播放音乐
        playBackgroundMusic(fileName: "backgroundMusic.mp3")
        //添加cameraNode
        camera = cameraNode
        setCameraPosition(position: CGPoint.init(x: size.width/2, y: size.height/2))
    }
    
    func backgroundNode() -> SKSpriteNode {
        let backgroundNode = SKSpriteNode()
        backgroundNode.anchorPoint = CGPoint.zero
        backgroundNode.name = "background"
        
        let background1 = SKSpriteNode.init(imageNamed: "background1")
        background1.anchorPoint = CGPoint.zero
        background1.position = CGPoint.init(x: 0, y: 0)
        background1.size = size
        backgroundNode.addChild(background1)
        
        let background2 = SKSpriteNode.init(imageNamed: "background2")
        background2.anchorPoint = CGPoint.zero
        background2.position = CGPoint.init(x: background1.size.width, y: 0)
        background2.size = size
        backgroundNode.addChild(background2)
        
        backgroundNode.size = CGSize.init(width: background1.size.width+background2.size.width, height: background1.size.height)

        return backgroundNode
    }
    
    //MARK:cat
    func spawnCat() {
        let cat = SKSpriteNode(imageNamed: "cat")
        cat.name = "cat"
        cat.position = CGPoint(x: CGFloat.random(min:frame.minX, max: frame.maxX), y: CGFloat.random(min: frame.minY, max: frame.maxY))
        cat.setScale(0)
        addChild(cat)
        
        let appear = SKAction.scale(to: 0.5, duration: 0.5)
        
        cat.zRotation = -CGFloat.pi/16
        let leftWiggle = SKAction.rotate(byAngle: CGFloat.pi/8, duration: 0.5)
        let rightWiggle = leftWiggle.reversed()
        let fullWiggle = SKAction.sequence([leftWiggle,rightWiggle])

        let scaleUp = SKAction.scale(by: 1.2, duration: 0.5)
        let scaleDown = scaleUp.reversed()
        let fullScale = SKAction.sequence([scaleUp,scaleDown])
        let scaleWiggleWait = SKAction.group([fullWiggle,fullScale])
        let wait = SKAction.repeat(scaleWiggleWait, count: 10)
        
        
        let disappear = SKAction.scale(to: 0, duration: 0.5)
        let remove = SKAction.removeFromParent()
        
        let sequene = SKAction.sequence([appear,wait,disappear,remove])
        
        cat.run(sequene)
    }
    
    func moveTrain(dt:TimeInterval) {
        var target = zombieNode.position
        
        enumerateChildNodes(withName: "train") { (node, _) in
        
            if !node.hasActions() {
                self.catMove(cat: node as! SKSpriteNode, velocity: self.velocityBetweenCat(fromCatPosition: node.position, toCatPosition: target), dt: dt)
            }
            target = node.position
        }
    }
    
    func catMove(cat:SKSpriteNode,velocity:CGPoint,dt:TimeInterval) {
        let movepoint = velocity*CGFloat(dt)
        cat.position += movepoint
    }
    
    func velocityBetweenCat(fromCatPosition:CGPoint,toCatPosition:CGPoint) -> CGPoint {
        let offset = toCatPosition - fromCatPosition
        let normal = offset.normalized()
        
        return normal*CGFloat(catMovePointPerSecond)
    }
    
    func loseCats(count:NSInteger) {
        var lostCount = 0
        enumerateChildNodes(withName: "train") { (node, stop) in
            
            var randomSpot = node.position
            randomSpot.x += CGFloat.random(min: -100, max: 100)
            randomSpot.y += CGFloat.random(min: -100, max: 100)
            node.name = ""
            node.run(SKAction.sequence([
                        SKAction.group([
                            SKAction.rotate(byAngle: CGFloat(Double.pi*4), duration: 1.0),
                            SKAction.move(to: randomSpot, duration: 1.0),
                            SKAction.scale(to: 0, duration: 1.0)
                            ]),
                        SKAction.removeFromParent()
                        ]))
            lostCount += 1
            self.trainCount -= 1
            if lostCount>count {
                stop.initialize(to: true)
            }
        }
    }
    
    //MARK:enemy
    func spawnEnemy() {
        let enemy = SKSpriteNode(imageNamed: "enemy")
        enemy.name = "enemy"
        enemy.setScale(nodeScale)
        enemy.position = CGPoint(x: size.width+enemy.size.width/2, y: CGFloat.random(min: 0, max: size.height))
        addChild(enemy)
        
        let moveAction = SKAction.moveTo(x: -enemy.size.width/2, duration: 2)
        let removeAction = SKAction.removeFromParent()
        enemy.run(SKAction.sequence([moveAction,removeAction]))
    }
    
    //MARK:zombie
    func addZombie(position:CGPoint) -> SKSpriteNode{
       let zombie = SKSpriteNode(imageNamed: "zombie1")
        zombie.position = position;
        zombie.setScale(nodeScale)
        
        addChild(zombie)
        return zombie
    }
    
    func zombieMove(zombie:SKSpriteNode,velocity:CGPoint,dt:TimeInterval) {
        let movepoint = velocity*CGFloat(dt)
        zombie.position += movepoint
    }
    
    func moveZombieToward(location:CGPoint) -> CGPoint {
        let offset = location - zombieNode.position
        let normal = offset.normalized()
        
        return normal*CGFloat(zombieMovePointPerSecond)
    }
    
    func startZombieAnimation() {
        if zombieNode.action(forKey: "animation") == nil {
            zombieNode.run(zombieAnimateAction, withKey: "animation")
        }
    }
    
    func stopZombieAnimation() {
        if zombieNode.action(forKey: "animation") != nil {
            zombieNode.removeAction(forKey: "animation")
        }
    }
    
    func touchScene(location:CGPoint) {
        velocity = moveZombieToward(location: location)
    }
    
    func checkBound() {
        let size = UIScreen.main.bounds.size
//        print("size:\(size)")
        if zombieNode.position.x < 0 {
            velocity?.x = -velocity!.x
        }
        if zombieNode.position.x > size.width {
            velocity?.x = -velocity!.x
        }
        if zombieNode.position.y < 0 {
            velocity?.y = -velocity!.y
        }
        if zombieNode.position.y > size.height {
            velocity?.y = -velocity!.y
        }
    }
    
    func checkDestination() -> Bool{
        guard destination != nil else {
            return true
        }

        let distance = destination! - zombieNode.position
        
        if distance.length() < CGFloat(zombieMovePointPerSecond)*CGFloat(dt){
            return true
        }
        
        return false
    }
    
    func zombieTurnRotation(dt:TimeInterval) {
        
        guard amtToRotate != 0 else {
            return
        }
        if amtToRotate.sign()*amtToRotate < zombieRotateRadiansPerSec*CGFloat(dt){
            zombieNode.zRotation += amtToRotate
            amtToRotate = 0
        } else {
            zombieNode.zRotation += amtToRotate.sign()*zombieRotateRadiansPerSec*CGFloat(dt)
            amtToRotate -= amtToRotate.sign()*zombieRotateRadiansPerSec*CGFloat(dt)
        }
    }
    
    //MARK:camera
    func moveCamera(dt:TimeInterval) {
        let backgroundVeclocity = CGPoint.init(x: cameraMovePointPerSecond, y: 0)
        let amountToMove = backgroundVeclocity*CGFloat(dt)
        cameraNode.position += amountToMove
        
    }
    
    //MARK:碰撞检测
    func zombieHitCat(cat:SKSpriteNode) {
        cat.name = "train"
        cat.removeAllActions()
        cat.setScale(0.5)
        cat.zRotation = 0
        cat.run(SKAction.colorize(with: UIColor.green, colorBlendFactor: 1.0, duration: 0.2))
        trainCount += 1
        if trainCount>=15 && !gameOver {
            print("you win")
            gameOver = true
            showGameOverScene(won: true)
            stopPlayBackgroundMusic()
        }
        run(catCollisionSound)
    }

    func zombieHitEnemy(enemy:SKSpriteNode) {
        zombieProtected = true
        lives -= 1
        if lives<=0 && !gameOver {
            print("you lose")
            gameOver = true
            showGameOverScene(won: false)
            stopPlayBackgroundMusic()
        }
        run(enemyCollisionSound)
    }
    
    func showGameOverScene(won:Bool) {
        let gameOverScene = GameOverScene.init(size: size, won: false)
        gameOverScene.scaleMode = .aspectFit
        let reavel = SKTransition.flipHorizontal(withDuration: 0.5)
        view?.presentScene(gameOverScene, transition: reavel)
    }
    
    func checkCollisions() {
        var hitCats:[SKSpriteNode] = []
        
        enumerateChildNodes(withName: "cat") { (node, _) in
            let cat = node as! SKSpriteNode
            if self.zombieNode.intersects(cat) {
                hitCats.append(cat)
            }
        }
        for cat in hitCats {
            zombieHitCat(cat: cat)
        }
        if !zombieProtected! {
            var hitEnemies:[SKSpriteNode] = []
            enumerateChildNodes(withName: "enemy") { (node, _) in
                let enemy = node as! SKSpriteNode
                if self.zombieNode.frame.intersects(enemy.frame) {
                    hitEnemies.append(enemy)
                }
            }
            for enemy in hitEnemies {
                zombieHitEnemy(enemy: enemy)
            }
        }
    }
    
    //MARK:触摸事件
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else {
            return
        }
        touchScene(location: touch.location(in: self))
        destination = touch.location(in: self)
    }
    //MARK:刷新
    override func update(_ currentTime: TimeInterval) {
        
        if lastUpdateTime > 0 {
            dt = currentTime - lastUpdateTime
        } else {
            dt = 0
        }
        lastUpdateTime = currentTime

        checkBound()
        zombieTurnRotation(dt: dt)
        moveTrain(dt: dt)
        moveCamera(dt: dt)
        
        if !checkDestination() {
            zombieMove(zombie: zombieNode, velocity: velocity!,dt: dt)
            startZombieAnimation()
        } else {
            guard destination != nil else {
                return
            }
            zombieNode.position = destination!
            stopZombieAnimation()
        }
    }
    
    override func didEvaluateActions() {
        checkCollisions()
    }
    
    //MARK:camera
    func overlapAmount() -> CGFloat {
        
        guard let view = self.view else {
            return 0
        }
        let scale = view.bounds.width/self.size.width
        let scaledHeight = self.size.height*scale
        let scaledOverlap = scaledHeight - view.bounds.height
        
        return scaledOverlap/scale
    }
    
    func getCamerPosition() -> CGPoint {
        return CGPoint(x: cameraNode.position.x, y: cameraNode.position.y+overlapAmount()/2)
    }
    
    func setCameraPosition(position:CGPoint) {
        cameraNode.position = CGPoint(x: position.x, y: position.y-overlapAmount()/2)
    }
}










