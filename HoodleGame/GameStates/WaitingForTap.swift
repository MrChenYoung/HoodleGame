//
//  WaitingForTap.swift
//  EscapeGame
//
//  Created by MrChen on 2019/4/6.
//  Copyright © 2019 MrChen. All rights reserved.
//

import UIKit
import GameplayKit

class WaitingForTap: GameStateBase {
    
    // 游戏状态成为等待开始调用
    override func didEnter(from previousState: GKState?) {
        super.didEnter(from: previousState)
    
    }
    
    // 游戏从等待开始状态变为正在玩状态调用
    override func willExit(to nextState: GKState) {
        // 如果进入playing状态 TapToPlay提示消失
        if nextState is Playing {
            gameMessageNode?.dismiss()
        }
    }
    
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        return stateClass is Playing.Type
    }
}
