//
//  GameStateBase.swift
//  HoodleGame
//
//  Created by MrChen on 2019/4/6.
//  Copyright © 2019 MrChen. All rights reserved.
//

import UIKit
import GameplayKit

class GameStateBase: GKState {
    unowned let scene: GameScene
    
    // 提示框
    var gameMessageNode: GameMessageNode?
    
    init(scene: SKScene) {
        self.scene = scene as! GameScene
        
        // 获取游戏提示节点
        gameMessageNode = scene.childNode(withName: GameMessageName) as? GameMessageNode
        super.init()
    }
    
    // 游戏状态成为当前状态调用
    override func didEnter(from previousState: GKState?) {
        // 显示提示节点
        gameMessageNode?.show()
    }
}
