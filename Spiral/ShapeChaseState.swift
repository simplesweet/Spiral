//
//  ShapeChaseState.swift
//  Spiral
//
//  Created by 杨萧玉 on 15/9/30.
//  Copyright © 2015年 杨萧玉. All rights reserved.
//

import GameplayKit

class ShapeChaseState: ShapeState {
    private let ruleSystem = GKRuleSystem()
    private var hunting: Bool = false {
        willSet {
            if hunting != newValue && !newValue {
                let playerPos = scene.playerEntity.gridPosition
                //将目标点设为 player 周围的随机点
                let targets = [vector_int2(playerPos.x, playerPos.y + 2),
                    vector_int2(playerPos.x + 2, playerPos.y),
                    vector_int2(playerPos.x, playerPos.y - 2),
                    vector_int2(playerPos.x - 2, playerPos.y),
                    vector_int2(playerPos.x, playerPos.y + 3),
                    vector_int2(playerPos.x + 3, playerPos.y),
                    vector_int2(playerPos.x, playerPos.y - 3),
                    vector_int2(playerPos.x - 3, playerPos.y)].flatMap({ (position) -> GKGridGraphNode? in
                        return scene.map.pathfindingGraph.nodeAtGridPosition(position)
                    })
                
                if let positions = scene.random.arrayByShufflingObjectsInArray(targets) as? [GKGridGraphNode] {
                    scatterTarget = positions.first!
                }
            }
        }
    }
    
    private var scatterTarget = GKGridGraphNode(gridPosition: vector_int2(0, 0))
    
    override init(scene s: MazeModeScene, entity e: Entity) {
        
        super.init(scene: s, entity: e)

        let playerFar = NSPredicate(format: "$distanceToPlayer.floatValue >= 12.0")
        ruleSystem.addRule(GKRule(predicate: playerFar, assertingFact: "hunt", grade: 1.0))
        
        let playerNear = NSPredicate(format: "$distanceToPlayer.floatValue < 12.0")
        ruleSystem.addRule(GKRule(predicate: playerNear, retractingFact: "hunt", grade: 1.0))
    }
    
//    MARK: - GKState Life Cycle
    
    override func isValidNextState(stateClass: AnyClass) -> Bool {
        return stateClass == ShapeFleeState.self
    }
    
    override func didEnterWithPreviousState(previousState: GKState?) {
        // Set the shape sprite to its normal appearance, undoing any changes that happened in other states.
        if let component = entity.componentForClass(SpriteComponent.self) {
            component.useNormalAppearance()
        }
    }
    
    override func updateWithDeltaTime(seconds: NSTimeInterval) {
        // If the shape has reached its target, choose a new target.
        let position = entity.gridPosition
        if position == scatterTarget.gridPosition {
            hunting = true
        }
        
        if let distanceToPlayer = pathToPlayer()?.count {
            ruleSystem.state["distanceToPlayer"] = distanceToPlayer
            ruleSystem.reset()
            ruleSystem.evaluate()
        }
        
        hunting = ruleSystem.gradeForFact("hunt") > 0.0
        if hunting {
            startFollowingPath(pathToPlayer())
        }
        else {
            startFollowingPath(pathToNode(scatterTarget))
        }
    }
}
