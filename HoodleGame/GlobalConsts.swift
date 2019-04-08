//
//  GlobalConsts.swift
//  EscapeGame
//
//  Created by MrChen on 2019/4/6.
//  Copyright © 2019 MrChen. All rights reserved.
//

import UIKit

//MARK: 标识场景内的物体的常量
// 小球
let BallCategory   : UInt32 = 0x1 << 0
// 砖头
let BrickCategory  : UInt32 = 0x1 << 1
// 挡板
let PaddleCategory : UInt32 = 0x1 << 2
// 天花板
let CeilingCategory : UInt32 = 0x1 << 3

//MARK: 场景内物体的zPosition值
// 砖块
let BrickzPosition: CGFloat = 10.0
// 挡板
let PaddlezPosition: CGFloat = 20.0
// 小球
let BallzPosition: CGFloat = 50.0
// 游戏内提示信息
let GameMessagezPosition: CGFloat = 80.0

//MARK: 常量字符串
// 游戏内提示文字节点标识
let GameMessageName = "gameMessage"
// 小球标识
let BallCategoryName = "ball"
// 砖块标识
let BrickCategoryName = "brick"
// 天花板
let CeilingCategoryName = "ceiling"

//MARK: 常量
// 屏幕宽度
let ScreenWidth: CGFloat = UIScreen.main.bounds.size.width
// 屏幕高度
let ScreenHeight: CGFloat = UIScreen.main.bounds.size.height
// 砖块的高度
let BrickHeight: CGFloat = 20.0
// 顶部间隙高度
let TopPadding: CGFloat = 80.0
// 挡板高度
let PaddleHeight: CGFloat = 10.0
// 60度正切值
let maxTan: CGFloat = 1.732
// 45度正切值
let minTan: CGFloat = 1.0
// 第一关小球的速度
let BallSpeedLevelOne: CGFloat = 165.0
// 第二关小球的速度
let BallSpeedLevelTwo: CGFloat = 330.0
// 第三关小球的速度
let BallSpeedLevelThree: CGFloat = 500.0

// 添加砖头的行数
func BrickRowNumber() -> CGFloat {
    return 2.0 + CGFloat(GameData.shared.levelNumber)
}
// 每一行砖头的数量
func BrickCountInRow() -> CGFloat {
    return 5.0 + CGFloat(GameData.shared.levelNumber) * 2.0
}
// 挡板宽度
func PaddingWidth() -> CGFloat {
    return ScreenWidth * (0.30 - CGFloat(GameData.shared.levelNumber) * 0.05)
}
// 每一块砖的分数
func oneBrickScore() -> CGFloat {
    let score: CGFloat = 100.0 / (BrickRowNumber() * BrickCountInRow())
    return score
}
// 游戏数据保存路径
func gameDataCodePath() -> String {
    var path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
    path += "/gameData.plist"
    return path
}

//MARK: 常用颜色
// 背景色
let BgColor: UIColor = UIColor(red: 105.0/255.0, green: 105.0/255.0, blue: 105.0/255.0, alpha: 1.0)
// 浅砖红色
let LightBrickColor: UIColor = UIColor(red: 244.0/255.0, green: 119.0/255.0, blue: 69.0/255.0, alpha: 1.0)
// 深砖红色
let DarkBrickColor: UIColor = UIColor(red: 255.0/255.0, green: 69.0/255.0, blue: 0.0/255.0, alpha: 1.0)



