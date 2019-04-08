//
//  GameScene.swift
//  HoodleGame
//
//  Created by MrChen on 2019/4/6.
//  Copyright © 2019 MrChen. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    // 手指开始点击屏幕的位置
    var touchBeginLocation: CGPoint!
    
    // 小球
    lazy var ballNode: SKSpriteNode = {
        // 先从解档出来的数据里面取ball
        let ball = GameData.shared.ball != nil ? GameData.shared.ball : SKSpriteNode(imageNamed: "ball")
        if GameData.shared.ball == nil {
            ball!.position = CGPoint(x: self.size.width * 0.5, y: self.size.height * 0.5 + 80.0)
            ball!.name = BallCategoryName
            ball!.zPosition = BallzPosition
        }
        GameData.shared.ball = nil
        return ball!
    }()
    
    // 挡板
    lazy var paddle: SKSpriteNode = {
        let paddleNode = GameData.shared.paddle != nil ? GameData.shared.paddle : SKSpriteNode(color: UIColor.red, size: CGSize(width: PaddingWidth(), height: PaddleHeight))
        if GameData.shared.paddle == nil {
            paddleNode!.position = CGPoint(x: self.size.width * 0.5, y: ScreenHeight * 0.2)
            paddleNode!.zPosition = PaddlezPosition
        }
        GameData.shared.paddle = nil
        return paddleNode!
    }()
    
    // 天花板
    private var ceilingNode: SKNode = SKNode()
    
    // 游戏提示文字
    lazy var messageNode: GameMessageNode = {
        let msgNode = GameMessageNode()
        msgNode.name = GameMessageName
        return msgNode
    }()
    
    // 玩家得分节点
    lazy var scoreLabelNode: SKLabelNode = {
        let score = SKLabelNode(fontNamed: "Chalkduster")
        score.fontSize = 16.0
        score.position = CGPoint(x: self.size.width - 55.0,y: self.size.height - 20.0)
        return score
    }()
    
    // 计时节点
    lazy var timeLabelNode: SKLabelNode = {
        let time = SKLabelNode(fontNamed: "Chalkduster")
        time.fontSize = 16.0
        time.position = CGPoint(x: 55.0,y: self.size.height - 20.0)
        time.text = "\(GameData.shared.gameTimeString)"
        return time
    }()
    
    // 游戏状态
    lazy var gameState: GKStateMachine = GKStateMachine(states: [
        WaitingForTap(scene:self),
        Playing(scene: self),
        Pause(scene: self),
        GameOver(scene: self)])
    
    // 游戏赢了还是输了
    var gameWon : Bool = false
   
//MARK: 原始方法
    override func didMove(to view: SKView) {
        GameData.shared.scene = self
        
        // 设置场景(添加Nodes)
        setScene()
        
        // 设置场景内物体的物理体
        setPhysicsBody()
        
        // 初始化游戏
        shuffleGame()
    }
    
    // 每一帧调用一次(调用频率高)
    override func update(_ currentTime: TimeInterval) {
        gameState.update(deltaTime: currentTime)
        
        // 获取小球的位置，看是否在挡板的下面，如果是表示挡板没有接住 游戏结束
        if ballNode.frame.origin.y <= paddle.frame.origin.y {
            // 游戏结束 玩家输了
            gameOver(won: false)
        }
        
        // 显示得分
        scoreLabelNode.text = "score: \(Int(GameData.shared.score))"
        
        // 显示计时
        timeLabelNode.text = GameData.shared.gameTimeString
    }
    
//MARK: 手势事件
    // 点击屏幕
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first
        touchBeginLocation = touch!.location(in: self)
    }
    
    // 手指在屏幕上滑动
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        // 只有游戏处于playing状态的时候挡板才能被拖拽
        if gameState.currentState is Playing {
            // 获取手指的位置 计算移动的距离
            let touch = touches.first
            let touchLocation = touch!.location(in: self)
            let previousLocation = touch!.previousLocation(in: self)
            
            // 计算挡板的x左边值(当前x值加上手指在屏幕上的移动差值)
            var paddleX = paddle.position.x + (touchLocation.x - previousLocation.x)
            // 调整挡板x值 防止移出屏幕外
            paddleX = max(paddleX, paddle.size.width/2)
            paddleX = min(paddleX, size.width - paddle.size.width/2)
            // 更新挡板位置
            paddle.position = CGPoint(x: paddleX, y: paddle.position.y)
        }
    }
    
    // 点击事件结束
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        // 通过计算手指在屏幕上的移动距离来判断是点击屏幕还是滑动
        let touch = touches.first
        let touchEndLocation = touch!.location(in: self)
        // 求x方向和y方向的移动距离绝对值
        let offsetX = abs(touchEndLocation.x - touchBeginLocation.x)
        let offsetY = abs(touchEndLocation.y - touchBeginLocation.y)
        if offsetX < 5 && offsetY < 5 {
            // 如果手指移动范围在5以内 视作点击屏幕 更新游戏状态
            updateGameState()
        }else {
            // 否则视为滑动屏幕 移动逻辑处理在touchesMoved方法里面做
        }
    }
    
//MARK: SKPhysicsContactDelegate
    // 监听场景内物体碰撞
    func didBegin(_ contact: SKPhysicsContact) {
        // 只有游戏正在进行中处理碰撞
        if gameState.currentState is Playing {
            var firstBody: SKPhysicsBody
            var secondBody: SKPhysicsBody
            
            // 获取碰撞的两个物体，并区分大小
            if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
                firstBody = contact.bodyA
                secondBody = contact.bodyB
            }else {
                firstBody = contact.bodyB
                secondBody = contact.bodyA
            }
            
            // 小球和砖块碰撞
            if firstBody.categoryBitMask == BallCategory && secondBody.categoryBitMask == BrickCategory {
                // 移除碰撞到的砖块
                secondBody.node?.removeFromParent()
                
                // 计分
                GameData.shared.score = 100.0 - oneBrickScore() * CGFloat(remainBricks().count)
                
                // 检测玩家是否赢了
                if isGameWon() {
                    gameOver(won: true)
                }
            }
        }
        
    }
    
// MARK: 自定义方法
    
    // 设置场景(添加Nodes)
    func setScene() {
        // 设置场景的背景色
        self.backgroundColor = SKColor(cgColor: BgColor.cgColor)
        
        // 添加计分节点
        addChild(scoreLabelNode)
        
        // 添加计时节点
        addChild(timeLabelNode)
        
        // 添加天花板
        addChild(ceilingNode)
        
        // 添加砖块
        addBricks()
        
        // 添加小球
        addChild(ballNode)
        
        // 添加挡板
        addChild(paddle)
        
        // 添加游戏提示节点
        addChild(messageNode)
    }
    
    // 添加砖块
    func addBricks() {
        // 移除残留的砖块
        for vestigitalBrick in self.children where vestigitalBrick.name == BrickCategoryName {
            vestigitalBrick.removeFromParent()
        }
        
        // 如果保存过游戏数据 直接拿保存的砖块来用
        if GameData.shared.remainBricks != nil && GameData.shared.remainBricks!.count > 0 {
            for i in 0..<GameData.shared.remainBricks!.count {
                let brick: SKSpriteNode = GameData.shared.remainBricks![i]
                addChild(brick)
            }
            GameData.shared.remainBricks = nil
            return
        }
        
        // 砖块与砖块 砖块与屏幕边缘的间隙
        let brickPadding: CGFloat = 1.0
        // 计算每一块砖头的宽度
        let brickWidth: CGFloat = (self.size.width - (CGFloat(BrickCountInRow()) + 1.0) * brickPadding) / BrickCountInRow()
        // 循环把所有的砖添加上(双循环添加BrickRowNumber行blockCountInRow列的砖块)
        for i in 0..<Int(BrickRowNumber()) {
            for j in 0..<Int(BrickCountInRow()) {
                // 获取砖块的index
                let brickIndex = i * Int(BrickCountInRow()) + j
                // 设置砖块的颜色
                let brickColor: UIColor = brickIndex % 2 == 0 ? LightBrickColor : DarkBrickColor
                
                // 计算当前砖块的position
                let brickX = brickWidth * 0.5 + brickWidth * CGFloat(j) + CGFloat(j) + 1.0
                let brickY = self.size.height - BrickHeight * 0.5 - CGFloat(i) * BrickHeight - CGFloat(i) - 1.0 - TopPadding
                let brick: SKSpriteNode = SKSpriteNode(color: brickColor, size: CGSize(width: brickWidth, height: BrickHeight))
                brick.name = BrickCategoryName
                brick.position = CGPoint(x: brickX, y: brickY)
                brick.size = CGSize(width: brickWidth, height: BrickHeight)
                brick.zPosition = BrickzPosition
                addChild(brick)
                
                // 设置砖头物理体
                let brickPhysicsBody: SKPhysicsBody = SKPhysicsBody(rectangleOf: brick.frame.size)
                // 不允许旋转
                brickPhysicsBody.allowsRotation = false
                // 摩擦系数为0
                brickPhysicsBody.friction = 0.0
                // 不受重力影响
                brickPhysicsBody.affectedByGravity = false
                // 不受物理因素影响
                brickPhysicsBody.isDynamic = false
                // 标识
                brickPhysicsBody.categoryBitMask = BrickCategory
                brick.physicsBody = brickPhysicsBody
            }
        }
    }
    
    // 设置场景内物体的物理体
    func setPhysicsBody() {
        // 给场景添加一个物理体，这个物理体就是一条沿着场景四周的边，限制了游戏范围，其他物理体就不会跑出这个场景
        self.physicsBody = SKPhysicsBody(edgeLoopFrom: self.frame)
        // 物理世界的碰撞检测代理为场景自己，这样如果这个物理世界里面有两个可以碰撞接触的物理体碰到一起了就会通知他的代理
        self.physicsWorld.contactDelegate = self
        
        // 设置挡板的物理体
        let paddlePhysicsBody = SKPhysicsBody(rectangleOf: paddle.size)
        // 挡板摩擦系数设为0
        paddlePhysicsBody.friction = 0.0
        // 恢复系数1.0
        paddlePhysicsBody.restitution = 1.0
        // 不受物理环境因素影响
        paddlePhysicsBody.isDynamic = false
        paddlePhysicsBody.categoryBitMask = PaddleCategory
        paddle.physicsBody = paddlePhysicsBody
        
        // 设置天花板物理体
        let ceilingPhysicsBody = SKPhysicsBody(edgeLoopFrom: CGRect(x: frame.origin.x, y: ScreenHeight - TopPadding, width: size.width, height: 1.0))
        ceilingPhysicsBody.categoryBitMask = CeilingCategory
        ceilingNode.physicsBody = ceilingPhysicsBody
        
        
        // 设置小球的物理体
        let ballPhysicsBody = SKPhysicsBody(texture: ballNode.texture!, size: ballNode.size)
        // 不允许小球旋转
        ballPhysicsBody.allowsRotation = false
        // 摩擦系数为0
        ballPhysicsBody.friction = 0.0
        // 小球恢复系数为1(与物体碰撞以后，小球以相同的力弹回去)
        ballPhysicsBody.restitution = 1.0
        // 小球线性阻尼(小球是否收到空气阻力,设为0表示不受空气阻力)
        ballPhysicsBody.linearDamping = 0.0
        // 小球角补偿(因为不允许旋转所以设置为0)
        ballPhysicsBody.angularDamping = 0.0
        ballPhysicsBody.categoryBitMask = BallCategory
        // 小球和地面、砖头接触会发生碰撞
        ballPhysicsBody.contactTestBitMask = BrickCategory | PaddleCategory | CeilingCategory
        ballNode.physicsBody = ballPhysicsBody
        
        // 小球不受物理环境影响
        ballNode.physicsBody?.isDynamic = false
    }
    
    // 初始化游戏
    func shuffleGame() {
        
        // 小球受物理环境影响
        ballNode.physicsBody?.isDynamic = true
        
        // 去掉重力加速度
        physicsWorld.gravity = CGVector(dx: 0.0, dy: 0.0)
        
        // 设置游戏初始状态
        gameState.enter(WaitingForTap.self)
    }
    
    // 更新游戏状态
    func updateGameState() {
        switch gameState.currentState {
        case is WaitingForTap:
            // 当前是等待点击开始状态 点击屏幕开始游戏
            gameState.enter(Playing.self)
        case is Playing:
            // 当前是正在游戏状态 点击屏幕暂停
            gameState.enter(Pause.self)
            print("游戏暂停了")
        case is Pause:
            // 当前是暂停状态 点击屏幕继续游戏
            gameState.enter(Playing.self)
            print("游戏继续了")
        case is GameOver:
            // 当前是游戏结束状态 点击重新开始游戏
            // 创建新的场景替换当前场景
            let newScene = GameScene(size: self.size)
            newScene.scaleMode = .aspectFit
            let reveal = SKTransition.flipVertical(withDuration: 0.5)
            self.view?.presentScene(newScene, transition: reveal)
            GameData.shared.scene = newScene
            
            // 重置时间
            GameData.shared.gameTime = 0.0
            // 重置得分
            GameData.shared.score = 0.0
        default:
            break
        }
    }
    
    // 判断游戏是否赢了
    func isGameWon() -> Bool {
        // 遍历所有子节点 计算剩余砖块数量
        let remainBricksArray = remainBricks()
        return remainBricksArray.count == 0
    }
    
    // 获取剩余砖头
    func remainBricks() -> [SKNode] {
        var bricks = [SKNode]()
        self.enumerateChildNodes(withName: BrickCategoryName) { (node, stop) in
            bricks.append(node)
        }
        return bricks
    }
    
    // 游戏结束 won: 玩家是否赢了
    func gameOver(won: Bool) {
        // 玩家是否赢了
        gameWon = won
        
        // 切换为游戏结束
        gameState.enter(GameOver.self)
        
        // 如果玩家赢了 根据当前关卡处理逻辑
        if won {
            if GameData.shared.levelNumber < 3 {
                // 当前关卡在最大关卡范围内 关卡加1
                GameData.shared.levelNumber += 1
            }else {
                // 已经是最后一关 重置关卡
                GameData.shared.levelNumber = 1
            }
        }
    }
    
}
