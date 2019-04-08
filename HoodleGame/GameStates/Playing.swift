//
//  Playing.swift
//  EscapeGame
//
//  Created by MrChen on 2019/4/6.
//  Copyright © 2019 MrChen. All rights reserved.
//

import UIKit
import GameplayKit

class Playing: GKState {
    unowned let scene: GameScene
    
    // 游戏开始进入playing状态时间点
    var startPlayDate: Date = Date()
    
    // 记录保存时候已经有的时间
    var saveTime: TimeInterval = 0.0
    
    init(scene: SKScene) {
        self.scene = scene as! GameScene
        super.init()
    }
    
    // 游戏开始
    override func didEnter(from previousState: GKState?) {
        if previousState is WaitingForTap {
            // 给小球添加一个随机方向的力
            let ball: SKSpriteNode = scene.childNode(withName: BallCategoryName) as! SKSpriteNode
            ball.physicsBody?.velocity = GameData.shared.ballVelocity()
            
            // 记录时间点
            saveTime = GameData.shared.gameTime
            startPlayDate = Date()
        }
    }
    
    // playing状态下 每一帧调用一次
    override func update(deltaTime seconds: TimeInterval) {
        // 计算playing状态下经过的时间
        let now:Date = Date()
        let times = now.timeIntervalSince(startPlayDate)
        GameData.shared.gameTime = times + saveTime
        
        // 获取小球节点
        let ball = scene.childNode(withName: BallCategoryName) as! SKSpriteNode

        // 计算速度
        let speed = GameData.shared.ballSpeed()
//        print("当前小球速度:\(speed)")

        // 水平 垂直方向的速度
        let xVelocity: CGFloat = ball.physicsBody?.velocity.dx ?? 0.0
        let yVelocity: CGFloat = ball.physicsBody?.velocity.dy ?? 0.0

        // 如果小球当前速度为0, 给小球一个随机方向的力
        if speed == 0 {
            ball.physicsBody?.velocity = GameData.shared.ballVelocity()
            return
        }

        // 小球速度不变的情况下,保证小球运动方向和水平方向的夹角在45度和60度之间

        // 水平方向速度为0，当前小球垂直方向运动，在实际速度不变的情况下，重新分配水平速度和垂直速度
        // 以速度方向和水平方向夹角为60度的目标,计算水平和垂直方向应该分配的速度
        if xVelocity == 0 {
            updateSpeed(actualVelocityX: xVelocity, actualVelocityY: yVelocity, speed: speed, tan: maxTan, ball: ball)
            return
        }

        // 计算当前小球与水平方向夹角的正切值
        let tan: CGFloat = abs(yVelocity) / abs(xVelocity)
        if tan < minTan {
            // 如果夹角小于45度 重新分配水平和垂直方向上的速度，让夹角变成45度
            updateSpeed(actualVelocityX: xVelocity, actualVelocityY: yVelocity, speed: speed, tan: minTan, ball: ball)
        }else if (tan > maxTan){
            // 如果夹角大于60度 重新分配水平和垂直方向上的速度，让夹角变成60度
            updateSpeed(actualVelocityX: xVelocity, actualVelocityY: yVelocity, speed: speed, tan: maxTan, ball: ball)
        }
    }
    
    // 重新分配速度
    func updateSpeed(actualVelocityX: CGFloat, actualVelocityY: CGFloat, speed:CGFloat, tan: CGFloat, ball:SKSpriteNode) {
        // 水平方向
        let xDirection: CGFloat = actualVelocityX > 0 ? 1.0 : -1.0
        // 垂直方向
        let yDirection: CGFloat = actualVelocityY > 0 ? 1.0 : -1.0
        
        // 计算分配速度
        let resultVelocityX = CGFloat(sqrt((speed * speed) / (tan * tan + 1.0))) * xDirection
        let resultVelocityY = tan * resultVelocityX * yDirection
        ball.physicsBody?.velocity = CGVector(dx: resultVelocityX, dy: resultVelocityY)
    }
    
    // 游戏开始 给小球一个随机方向
    func randomDirection() -> CGFloat {
        let speedFactor: CGFloat = 1.0
        if randomFloat(from: 0.0, to: 100.0) >= 50 {
            return -speedFactor
        } else {
            return speedFactor
        }
    }
    
    // 产生一个随机数让开始的时候小球有一个随机方向
    func randomFloat(from: CGFloat, to: CGFloat) -> CGFloat {
        let rand: CGFloat = CGFloat(Float(arc4random()) / 0xFFFFFFFF)
        return (rand) * (to - from) + from
    }
    
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        return stateClass is GameOver.Type || stateClass is Pause.Type
    }

}
