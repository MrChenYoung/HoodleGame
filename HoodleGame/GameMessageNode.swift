//
//  GameMessageNode.swift
//  HoodleGame
//
//  Created by MrChen on 2019/4/6.
//  Copyright © 2019 MrChen. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit

class GameMessageNode: SKNode {
    
    // 背景
    lazy var backgroundNode: SKSpriteNode = {
        let bgNode = SKSpriteNode(color: UIColor.clear, size: CGSize.zero)
        bgNode.size = CGSize(width: ScreenWidth * 0.8, height: ScreenHeight * 0.3)
        bgNode.position = CGPoint(x: ScreenWidth * 0.5, y: ScreenHeight * 0.5)
        bgNode.setScale(0.0)
        return bgNode
    }()
    
    // 游戏提示主标题
    lazy var mainNode: SKSpriteNode = {
        let messageNode = SKSpriteNode(imageNamed: "TapToPlay")
        messageNode.name = GameMessageName
        messageNode.zPosition = GameMessagezPosition
        messageNode.setScale(1.0)
        return messageNode
    }()
    
    // 游戏提示副标题
    lazy var subLabelNode: SKLabelNode = {
        let labelNode = SKLabelNode(fontNamed: "Chalkduster")
        labelNode.setScale(1.0)
        return labelNode
    }()
    
    // 重写初始化方法
    override init() {
        super.init()
        
        // 设置子节点
        setChildNodes()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // 设置子节点
    func setChildNodes() {
        // 添加背景
        self.addChild(backgroundNode)
        // 设置zposition 保证不会被其他节点挡住
        self.zPosition = 200.0
        
        // 添加主提示节点
        backgroundNode.addChild(mainNode)
        
        // 添加副标题节点
        backgroundNode.addChild(subLabelNode)
    }
    
    // 显示提示
    func show() {
        let scene: GameScene = self.scene as! GameScene
        switch scene.gameState.currentState {
            case is WaitingForTap:
                // 等待点击开始 动画显示点击开始提示
                subLabelNode.text = "level \(GameData.shared.levelNumber)"
                subLabelNode.fontSize = 18.0
                mainNode.texture = SKTexture(imageNamed: "TapToPlay")
            case is Pause:
                // 暂停状态提示点击继续
                mainNode.isHidden = true
                subLabelNode.text = "TAP TO CONTINUE"
                subLabelNode.fontSize = 28.0
            case is GameOver:
                // 进制用户继续操作
                scene.isUserInteractionEnabled = false
                
                // 游戏结束 根据玩家是否赢了提示
                let textureName = scene.gameWon ? "YouWon" : "GameOver"
                mainNode.isHidden = false
                mainNode.texture = SKTexture(imageNamed: textureName)
                
                // 子标题节点提示文字
                var subMessage = ""
                if scene.gameWon {
                    // 赢了  判断是不是最后一关 是最后一关提示已通关
                    subMessage = GameData.shared.levelNumber >= 3 ? "CONGRATULATION" : "TAP TO NEXT LEVEL"
                }else {
                    // 输了
                    subMessage = "TAP AGAIN"
                }
                subLabelNode.text = subMessage
                subLabelNode.fontSize = 18.0
                self.position = CGPoint(x: 0.0, y: ScreenHeight * 0.5)
                backgroundNode.setScale(1.0)
            default:
                break
        }
        
        // 更新frame
        updateChildNodeFrame()
        
        if scene.gameState.currentState is GameOver {
            // 游戏结束动画
            let animationAction = SKAction.move(by: CGVector(dx:0, dy:-ScreenHeight * 0.5), duration: 0.5)
            self.run(animationAction) {
                // 动画结束以后 玩家可以继续操作
                scene.isUserInteractionEnabled = true
            }
        }else {
            // 非游戏结束状态下的动画
            let animationAction = SKAction.scale(to: 1.0, duration: 0.25)
            backgroundNode.run(animationAction) {
                // 动画结束以后 玩家可以继续操作
                scene.isUserInteractionEnabled = true
            }
        }
        
    }
    
    // 隐藏提示
    func dismiss() {
        let scaleAction = SKAction.scale(to: 0.0, duration: 0.25)
        backgroundNode.run(scaleAction)
    }
    
    // 更新frame
    func updateChildNodeFrame() {
        let scene: GameScene = self.scene as! GameScene
        // 背景节点size
        var bgNodeSize: CGSize = backgroundNode.size
        // 子标题position
        var subNodePosition: CGPoint = subLabelNode.position
        
        if mainNode.isHidden {
            // 如果主标题节点被隐藏
            bgNodeSize = subLabelNode.frame.size
        }else {
            // 如果主标题节点没有被隐藏
            // 获取mainNode宽和高
            let mainNodeWidth: CGFloat = mainNode.texture?.size().width ?? 0.0
            let mainNodeHeight: CGFloat = mainNode.texture?.size().height ?? 0.0
            bgNodeSize = CGSize(width: mainNodeWidth, height: mainNodeHeight + 60.0)
            
            // 更新mainNode frame
            if scene.gameState.currentState is GameOver {
                // 游戏结束状态
                mainNode.position = CGPoint(x: 0.0, y: 20.0)
                // 子标题节点position
                subNodePosition = CGPoint(x: subLabelNode.position.x, y: subLabelNode.position.y - 20.0)
            }else {
                mainNode.position = CGPoint(x: 0.0, y: backgroundNode.size.height * 0.5 + 30.0)
                // 子标题节点position
                subNodePosition = CGPoint(x: subLabelNode.position.x, y: subLabelNode.position.y - 30.0)
            }
        }
        
        // 更新背景node frame
        backgroundNode.size = bgNodeSize
        
        // 更新subNode frame
        subLabelNode.position = subNodePosition
    }
    
}
