//
//  GameOver.swift
//  EscapeGame
//
//  Created by MrChen on 2019/4/6.
//  Copyright © 2019 MrChen. All rights reserved.
//

import UIKit
import GameplayKit

class GameOver: GameStateBase {

    override func didEnter(from previousState: GKState?) {
        if previousState is Playing {
            // 游戏结束 小球停止运动
            let ball = scene.childNode(withName: BallCategoryName) as! SKSpriteNode
            ball.physicsBody?.isDynamic = false
            
            // 显示游戏结束提示
            gameMessageNode?.show()
        }
    }
    
    // 只对下一个状态是等待开始有效
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        return stateClass is WaitingForTap.Type
    }
}
