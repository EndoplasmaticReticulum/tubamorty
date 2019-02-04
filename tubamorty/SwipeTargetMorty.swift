//
//  SwipeTargetMorty.swift
//  tubamorty
//
//  Created by Jonas Treumer on 27.01.17.
//  Copyright © 2017 TU Bergakademie Freiberg. All rights reserved.
//

import SpriteKit

class SwipeTargetMorty: SwipeTargetRandomized
{
    //Load the Morty textures into an array:
    static let mortyImages = (1...15).map({ return UIImage(named: "M\($0)")! })
    
    override func didLaunch() -> SKPhysicsBody
    {
        let physics = super.didLaunch()
        
        physics.categoryBitMask = PhysicsCategory.Normal
        physics.collisionBitMask = PhysicsCategory.Wall | PhysicsCategory.Special
        
        return physics
    }
    
    override func handleSurvival() -> SwipeTargetSurvivalAction
    {
        return .lifeLost
    }
}
