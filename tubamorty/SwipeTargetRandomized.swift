//
//  SwipeTargetRandomized.swift
//  tubamorty
//
//  Created by Jonas Treumer on 19.01.17.
//  Copyright © 2017 TU Bergakademie Freiberg. All rights reserved.
//

import SpriteKit

class SwipeTargetRandomized: SwipeTarget
{
    //The velocity:
    let velocity: CGVector
    
    //The angular velocity:
    let angularVelocity: CGFloat
    
    init(image: UIImage, color: SKColor, size: CGSize, launchTime: TimeInterval, screenSize: CGSize, velocity: CGVector, angularVelocity: CGFloat)
    {
        self.velocity = velocity
        self.angularVelocity = angularVelocity
        
        super.init(image: image, color: color, size: size, launchTime: launchTime)
        
        //Put below screen border:
        self.position = CGPoint(x: -300 + CGFloat(arc4random_uniform(600)), y: -0.5 * (size.height + screenSize.height))
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didLaunch() -> SKPhysicsBody
    {
        let physics = SKPhysicsBody(circleOfRadius: 0.5 * self.size.height)
        
        physics.affectedByGravity = true
        physics.allowsRotation = true
        physics.velocity = self.velocity
        physics.angularVelocity = self.angularVelocity
        
        return physics
    }
}
