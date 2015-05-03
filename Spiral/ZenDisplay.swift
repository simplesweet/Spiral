//
//  ZenDisplay.swift
//  Spiral
//
//  Created by 杨萧玉 on 15/5/3.
//  Copyright (c) 2015年 杨萧玉. All rights reserved.
//

import SpriteKit

class ZenDisplay: SKNode, DisplayData {
    let scoreLabel = SKLabelNode(text: NSLocalizedString("SCORE ", comment: "")+"\(Data.score)")
    let levelLabel = SKLabelNode(text:NSLocalizedString("LEVEL ", comment: "")+"\(Data.level)")
    let highScoreLabel = SKLabelNode(text: NSLocalizedString("HIGHSCORE ", comment: "")+"\(Data.highScore)")
    let gameOverLabel = SKLabelNode(text: NSLocalizedString("GAME OVER", comment: ""))
    let pauseLabel = SKLabelNode(text: NSLocalizedString("PAUSE", comment: ""))
    let reaperIcon = SKSpriteNode(imageNamed: "reaper")
    let reaperNumLabel = SKLabelNode(text: String.localizedStringWithFormat("%d", Data.reaperNum))
    let tipsLabel = SKLabelNode(text: NSLocalizedString("TIPS", comment: ""))
    let share = ShareButton()
    let replay = ReplayButton()
    let gameCenter = GameCenterButton()
    let help = HelpButton(mode: .Zen)
    
    required init(coder: NSCoder) {
        fatalError("NSCoding not supported")
    }
    
    override init(){
        super.init()
        gameOverLabel.fontSize = 60
        pauseLabel.fontSize = 60
        pauseLabel.alpha = 0
        reaperIcon.size = CGSize(width: 20, height: 20)
        reaperNumLabel.fontSize = 20
        tipsLabel.fontSize = 12
        scoreLabel.setDefaultFont()
        highScoreLabel.setDefaultFont()
        levelLabel.setDefaultFont()
        gameOverLabel.setDefaultFont()
        pauseLabel.setDefaultFont()
        reaperNumLabel.setDefaultFont()
        tipsLabel.setDefaultFont()
        self.addChild(scoreLabel)
        self.addChild(levelLabel)
        self.addChild(pauseLabel)
        self.addChild(reaperIcon)
        self.addChild(reaperNumLabel)
    }
    
    func setPosition() {
        scoreLabel.position = CGPointMake(CGRectGetMidX(self.scene!.frame), CGRectGetMaxY(self.scene!.frame)/8)
        highScoreLabel.position = CGPointMake(CGRectGetMidX(self.scene!.frame), CGRectGetMinY(self.scene!.frame)+5)
        levelLabel.position = CGPointMake(CGRectGetMidX(self.scene!.frame), 4*CGRectGetMaxY(self.scene!.frame)/5)
        gameOverLabel.position = CGPointMake(CGRectGetMidX(self.scene!.frame), CGRectGetMidY(self.scene!.frame))
        share.position = CGPointMake(CGRectGetMaxX(self.scene!.frame)*3/4, CGRectGetMaxY(self.scene!.frame)/4)
        replay.position = CGPointMake(CGRectGetMaxX(self.scene!.frame)/4, CGRectGetMaxY(self.scene!.frame)/4)
        gameCenter.position = CGPoint(x: gameCenter.size.width/2, y: self.scene!.size.height-gameCenter.size.height/2)
        pauseLabel.position = CGPointMake(CGRectGetMidX(self.scene!.frame), CGRectGetMidY(self.scene!.frame))
        reaperIcon.position = CGPoint(x: reaperIcon.size.width/2, y: reaperIcon.frame.height/2)
        reaperNumLabel.position = CGPoint(x: CGRectGetMaxX(reaperIcon.frame) + 5 + reaperNumLabel.frame.width/2, y: reaperNumLabel.frame.height/4)
        help.position = CGPoint(x: self.scene!.size.width-help.size.width/2, y: self.scene!.size.height-help.size.height/2)
        tipsLabel.position = CGPoint(x: gameOverLabel.position.x, y: (gameOverLabel.position.y + share.position.y)/2)
        
    }
    
    func updateData() {
        scoreLabel.text = NSLocalizedString("SCORE ", comment: "")+"\(Data.score)"
        levelLabel.text = NSLocalizedString("LEVEL ", comment: "")+"\(Data.level)"
        reaperNumLabel.text = String.localizedStringWithFormat("%d", Data.reaperNum)
    }
    
    func levelUp() {
        levelLabel.runAction(SKAction.sequence([SKAction.scaleTo(1.5, duration: 0.5),SKAction.scaleTo(1, duration: 0.5)]))
        let scene = self.scene as! ZenModeScene
        scene.speedUp()
        scene.soundManager.playLevelUp()
    }
    
    func gameOver() {
        addChild(gameOverLabel)
        addChild(share)
        addChild(replay)
        addChild(gameCenter)
        addChild(help)
        let tipNum = Int(arc4random_uniform(9))
        tipsLabel.text = NSLocalizedString(tips[tipNum], comment: "tips")
        addChild(tipsLabel)
        reaperIcon.removeFromParent()
        reaperNumLabel.removeFromParent()
        highScoreLabel.text = NSLocalizedString("HIGHSCORE ", comment: "")+"\(Data.highScore)"
        addChild(highScoreLabel)
        let scene = self.scene as! ZenModeScene
        scene.hideGame()
        scene.soundManager.playGameOver()
        (UIApplication.sharedApplication().keyWindow?.rootViewController as! GameViewController).removeGestureRecognizers()
    }
    
    func restart() {
        gameOverLabel.removeFromParent()
        share.removeFromParent()
        replay.removeFromParent()
        gameCenter.removeFromParent()
        help.removeFromParent()
        highScoreLabel.removeFromParent()
        tipsLabel.removeFromParent()
        if reaperNumLabel.parent == nil && reaperIcon.parent == nil {
            self.addChild(reaperNumLabel)
            self.addChild(reaperIcon)
        }
        (self.scene as! ZenModeScene).restartGame()
        (UIApplication.sharedApplication().keyWindow?.rootViewController as! GameViewController).addGestureRecognizers()
    }
    
    func pause(){
        pauseLabel.text = NSLocalizedString("PAUSE", comment: "")
        pauseLabel.alpha = 1
        (self.scene as! ZenModeScene).hideGame()
    }
    
    func resume(){
        pauseLabel.text = ""
        pauseLabel.alpha = 0
        if !Data.gameOver{
            (self.scene as! ZenModeScene).showGame()
        }
    }
}