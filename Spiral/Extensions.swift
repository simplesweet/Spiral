//
//  Extensions.swift
//  Spiral
//
//  Created by 杨萧玉 on 15/6/5.
//  Copyright (c) 2015年 杨萧玉. All rights reserved.
//

import SpriteKit

extension SKScene {
    class func unarchiveFromFile(file:String) -> SKNode? {
        if let path = NSBundle.mainBundle().pathForResource(file, ofType: "sks") {
            var sceneData = NSData(contentsOfFile: path, options: .DataReadingMappedIfSafe, error: nil)!
            var archiver = NSKeyedUnarchiver(forReadingWithData: sceneData)
            
            archiver.setClass(self.classForKeyedUnarchiver(), forClassName: "SKScene")
            let scene = archiver.decodeObjectForKey(NSKeyedArchiveRootObjectKey) as! SKScene
            scene.size = GameKitHelper.sharedGameKitHelper().getRootViewController().view.frame.size
            archiver.finishDecoding()
            return scene
        } else {
            return nil
        }
    }
}

extension SKLabelNode {
    func setDefaultFont(){
        self.fontName = NSLocalizedString("HelveticaNeue-Thin", comment: "")
    }
}

extension SKNode {
    
    class func yxy_swizzleAddChild() {
        let cls = SKNode.self
        let originalSelector = Selector("addChild:")
        let swizzledSelector = Selector("yxy_addChild:")
        let originalMethod = class_getInstanceMethod(cls, originalSelector)
        let swizzledMethod = class_getInstanceMethod(cls, swizzledSelector)
        method_exchangeImplementations(originalMethod, swizzledMethod)
    }
    
    class func yxy_swizzleRemoveFromParent() {
        let cls = SKNode.self
        let originalSelector = Selector("removeFromParent")
        let swizzledSelector = Selector("yxy_removeFromParent")
        let originalMethod = class_getInstanceMethod(cls, originalSelector)
        let swizzledMethod = class_getInstanceMethod(cls, swizzledSelector)
        method_exchangeImplementations(originalMethod, swizzledMethod)
    }
    
    func yxy_addChild(node: SKNode) {
        if node.parent == nil {
            yxy_addChild(node)
        }
        else {
            println("This node has already a parent!: \(node.description)")
        }
    }
    
    func yxy_removeFromParent() {
        if parent != nil {
            yxy_removeFromParent()
        }
        else {
            println("This node has no parent!: \(description)")
        }
    }
    
}