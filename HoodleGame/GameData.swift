//
//  GameData.swift
//  HoodleGame
//
//  Created by MrChen on 2019/4/7.
//  Copyright © 2019 MrChen. All rights reserved.
//

import UIKit
import GameplayKit

class GameData: NSObject, NSCoding {
    
    //MARK: 把当前类设置为单例

    // 单例对象
    static var shared = GameData()
    
    // 私有化构造方法
    private override init() {}
    
    // 重写copy方法 返回自己 保证对象只有一个
    override func copy() -> Any {
        return self
    }
    
    override func mutableCopy() -> Any {
        return self
    }
    
    //MARK: 归档 解档
    
    // 解档
    required init?(coder aDecoder: NSCoder) {
        super.init()
        
        // 游戏关卡
        levelNumber = aDecoder.decodeInteger(forKey: "level")
        // 玩家得分
        score = aDecoder.decodeObject(forKey: "score") as! CGFloat
        // 游戏时长
        gameTime = aDecoder.decodeDouble(forKey: "time")
        gameTimeString = transToHourMinSec(time: Float(gameTime))
        // 所有剩余的砖块
        remainBricks = aDecoder.decodeObject(forKey: "bricks") as? [SKSpriteNode]
        // 小球
        ball = aDecoder.decodeObject(forKey: "ball") as? SKSpriteNode
        // 挡板
        paddle = aDecoder.decodeObject(forKey: "paddle") as? SKSpriteNode
    }
    
    // 归档
    func encode(with aCoder: NSCoder) {
        // 游戏关卡
        aCoder.encode(levelNumber, forKey: "level")
        // 玩家得分
        aCoder.encode(score, forKey: "score")
        // 游戏时长
        aCoder.encode(gameTime, forKey: "time")
        // 所有剩余的砖块
        aCoder.encode(scene?.remainBricks(), forKey: "bricks")
        // 小球
        aCoder.encode(scene?.ballNode, forKey: "ball")
        // 挡板
        aCoder.encode(scene?.paddle, forKey: "paddle")
    }
    
    //MARK: 自定义属性 方法
    
    // 场景
    weak var scene: GameScene?
    
    // 当前游戏关卡
    var levelNumber: Int = 1
    
    // 玩家得分
    var score: CGFloat = 0.0
    
    var gameTimeString: String = "00:00:00"
    
    // 游戏进行时长（单位s）
    var gameTime: TimeInterval = 0.0{
        didSet {
           gameTimeString = transToHourMinSec(time: Float(gameTime))
        }
    }
    
    
    // 剩余砖块
    var remainBricks: [SKSpriteNode]?
    // 小球
    var ball: SKSpriteNode?
    // 挡板
    var paddle: SKSpriteNode?
    
    // 获取不同关卡小球的速度(不带方向)
    func ballSpeed() -> CGFloat {
        if levelNumber == 1 {
            return BallSpeedLevelOne
        }else if levelNumber == 2 {
            return BallSpeedLevelTwo
        }else {
            return BallSpeedLevelThree
        }
    }
    
    // 获取不同关卡小球的速度(带方向)
    func ballVelocity() -> CGVector {
        // 获取速度值
        let speed = ballSpeed()
        
        // 计算水平和垂直方向速度
        let xSpeed = sqrt(speed * speed / 2.0)
        
        return CGVector(dx: xSpeed, dy: -xSpeed)
    }
    
    // MARK: - 把秒数转换成时分秒（00:00:00）格式
    ///
    /// - Parameter time: time(Float格式)
    /// - Returns: String格式(00:00:00)
    func transToHourMinSec(time: Float) -> String{
        let allTime: Int = Int(time)
        var hours = 0
        var minutes = 0
        var seconds = 0
        var hoursText = ""
        var minutesText = ""
        var secondsText = ""
        
        hours = allTime / 3600
        hoursText = hours > 9 ? "\(hours)" : "0\(hours)"
        
        minutes = allTime % 3600 / 60
        minutesText = minutes > 9 ? "\(minutes)" : "0\(minutes)"
        
        seconds = allTime % 3600 % 60
        secondsText = seconds > 9 ? "\(seconds)" : "0\(seconds)"
        
        return "\(hoursText):\(minutesText):\(secondsText)"
    }
}
