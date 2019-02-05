//
//  SwipeTargetPickle.swift
//  tubamorty
//
//  Created by Jonas Treumer on 04.02.19.
//  Copyright © 2019 TU Bergakademie Freiberg. All rights reserved.
//

import SpriteKit

class SwipeTargetPickle: SwipeTargetRandomized
{
    override func didLaunch() -> SKPhysicsBody
    {
        let physics = super.didLaunch()
        
        physics.categoryBitMask = PhysicsCategory.Normal
        physics.collisionBitMask = PhysicsCategory.Wall | PhysicsCategory.Special
        
        return physics
    }
    
    override func handleKill() -> [SwipeTargetAction]
    {
        return [.lifeGained, .playAudio("PickleRick")]
    }
}
