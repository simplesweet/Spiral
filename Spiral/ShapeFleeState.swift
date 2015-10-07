//
//  ShapeFleeState.swift
//  Spiral
//
//  Created by 杨萧玉 on 15/9/30.
//  Copyright © 2015年 杨萧玉. All rights reserved.
//

import GameplayKit

class ShapeFleeState: ShapeState {
    private var target: GKGridGraphNode?
    private let ruleSystem = GKRuleSystem()
    private var fleeting: Bool = false {
        willSet {
            if fleeting != newValue && !newValue {
                if let positions = scene.random.arrayByShufflingObjectsInArray(scene.map.shapeStartPositions) as? [GKGridGraphNode] {
                    target = positions.first!
                }
            }
            
        }
    }
    
    override init(scene s: MazeModeScene, entity e: Entity) {
        
//        target = (scene.random.arrayByShufflingObjectsInArray(scene.map.shapeStartPositions).first as? GKGridGraphNode)!
        
        super.init(scene: s, entity: e)
        
        let playerFar = NSPredicate(format: "$distanceToPlayer.floatValue >= 20.0")
        ruleSystem.addRule(GKRule(predicate: playerFar, retractingFact: "flee", grade: 1.0))
        
        let playerNear = NSPredicate(format: "$distanceToPlayer.floatValue < 20.0")
        ruleSystem.addRule(GKRule(predicate: playerNear, assertingFact: "flee", grade: 1.0))

    }
    
//    MARK: - GKState Life Cycle
    
    override func isValidNextState(stateClass: AnyClass) -> Bool {
        return stateClass == ShapeChaseState.self || stateClass == ShapeDefeatedState.self
    }
    
    override func didEnterWithPreviousState(previousState: GKState?) {
        if let component = entity.componentForClass(SpriteComponent.self) {
            component.useFleeAppearance()
        }
        
        // Choose a location to flee towards.
        target = (scene.random.arrayByShufflingObjectsInArray(scene.map.shapeStartPositions).first as? GKGridGraphNode)!
    }
    
    override func updateWithDeltaTime(seconds: NSTimeInterval) {
        // If the shape has reached its target, choose a new target.
        let position = entity.gridPosition
        if position == target!.gridPosition {
            fleeting = true
        }
        
        if let distanceToPlayer = pathToPlayer()?.count {
            ruleSystem.state["distanceToPlayer"] = distanceToPlayer
            ruleSystem.reset()
            ruleSystem.evaluate()
        }
        
        fleeting = ruleSystem.gradeForFact("flee") > 0.0
        if fleeting {
            nearestTarget()
            startRunToNode(target!)
        }
        else {
            startFollowingPath(pathToNode(target!))
        }
        
    }
    
    func nearestTarget() {
        let position = entity.gridPosition
        let graph = scene.map.pathfindingGraph
        if let path = pathToPlayer() where path.count > 1 {
            let negativeNode = path[1] // path[0] is the shape's current position.
            let delta = position - negativeNode.gridPosition
            let expectPos = position + delta
            let expectTarget: GKGridGraphNode
            if let expectNode = graph.nodeAtGridPosition(expectPos) {
                expectTarget =  expectNode
            }
            else {
                let orthoDelta = vector_int2(delta.y, delta.x)
                if let expectNode = graph.nodeAtGridPosition(position + orthoDelta) {
                    expectTarget = expectNode
                }
                else if let expectNode = graph.nodeAtGridPosition(position - orthoDelta) {
                    expectTarget = expectNode
                }
                else {
                    expectTarget = graph.nodeAtGridPosition(position)!
                }
            }
            if graph.findPathFromNode(expectTarget, toNode: graph.nodeAtGridPosition(scene.playerEntity.gridPosition)!).count <= path.count {
                target = graph.nodeAtGridPosition(position)!
            }
            else {
                target = expectTarget
            }
        }
    }
}
