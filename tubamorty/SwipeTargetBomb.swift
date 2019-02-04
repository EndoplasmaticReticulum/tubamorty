//
//  SwipeTargetBomb.swift
//  tubamorty
//
//  Created by Jonas Treumer on 27.01.17.
//  Copyright © 2017 TU Bergakademie Freiberg. All rights reserved.
//

import SpriteKit

class SwipeTargetBomb: SwipeTargetRandomized
{
    override func didLaunch() -> SKPhysicsBody
    {
        let physics = super.didLaunch()
        
        physics.categoryBitMask = PhysicsCategory.Special
        physics.collisionBitMask = PhysicsCategory.Wall | PhysicsCategory.Normal
        
        return physics
    }
    
    override func handleKill() -> SwipeTargetKillAction
    {
        return .blowUp
    }
}
