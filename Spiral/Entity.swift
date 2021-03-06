//
//  Entity.swift
//  Spiral
//
//  Created by 杨萧玉 on 15/9/29.
//  Copyright © 2015年 杨萧玉. All rights reserved.
//

import GameplayKit

class Entity: GKEntity {
    var gridPosition = vector_int2(0, 0)
    let shapeType: ShapeType
    
    init(type: ShapeType) {
        shapeType = type
        super.init()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
