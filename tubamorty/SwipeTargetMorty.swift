//
//  SwipeTargetMorty.swift
//  tubamorty
//
//  Created by Jonas Treumer on 19.01.17.
//  Copyright © 2017 TU Bergakademie Freiberg. All rights reserved.
//

import SpriteKit

class SwipeTargetMorty: SwipeTarget
{
    public static let mortyImages = (1...15).map({ return UIImage(named: "M\($0)")! })
    
    override func didLaunch() -> SKPhysicsBody
    {
        let physics = SKPhysicsBody(circleOfRadius: 0.5 * self.size.height)
        
        physics.affectedByGravity = true
        physics.velocity = CGVector(dx: 0, dy: 1500)
        
        return physics
    }
}
