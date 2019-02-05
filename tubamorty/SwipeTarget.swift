//
//  SwipeTarget.swift
//  tubamorty
//
//  Created by Jonas Treumer on 18.01.17.
//  Copyright © 2017 TU Bergakademie Freiberg. All rights reserved.
//

import SpriteKit

//What is the life state of the target?
enum SwipeTargetLifeState
{
    case sleeping //Before launch
    case alive //In the air
    case wasOutside //First stage of hit
    case wasInside //Second stage of hit
    case survived //Left the screen
    case killed //Has been killed
}

//Actions that can be triggered:
enum SwipeTargetAction
{
    case lifeGained
    case lifeLost
    case blowUp
    case playAudio(String)
    case spawnEmitter(String, CGPoint, TimeInterval)
}

//A target on the screen that can be influenced by a swipe:
class SwipeTarget: SKSpriteNode
{
    //Did we hit the bottom? -> Survived!
    private static let bottomTolerance = CGFloat(100)
    
    //When do we launch the target?
    private let launchTime: TimeInterval
    
    //Life state of this target:
    private(set) var lifeState = SwipeTargetLifeState.sleeping
    
    init(image: UIImage, color: SKColor, size: CGSize, launchTime: TimeInterval)
    {
        //Set the launch time:
        self.launchTime = launchTime
        
        //Call SKSpriteNode's initializer:
        super.init(texture: SKTexture(image: image), color: color, size: size)
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        //Initialize with defaults:
        self.launchTime = 0
        
        //Call SKSpriteNode's initializer:
        super.init(coder: aDecoder)
    }
    
    private func launch()
    {
        //We are alive now.
        self.lifeState = .alive
        
        //Obtain our physics:
        self.physicsBody = didLaunch()
    }
    
    //Manage hitting a point:
    func tryHit(withPoint point: CGPoint)
    {
        //Inside?
        if self.contains(point)
        {
            if self.lifeState == .wasOutside
            {
                self.lifeState = .wasInside
            }
        }
        else if self.lifeState == .alive
        {
            self.lifeState = .wasOutside
        }
        else if self.lifeState == .wasInside
        {
            if killedByHit()
            {
                self.lifeState = .killed
            }
            else
            {
                self.lifeState = .wasOutside
            }
        }
    }
    
    //The current cut has ended. No hitting!
    func cancelHit()
    {
        if (self.lifeState == .wasOutside) || (self.lifeState == .wasInside)
        {
            self.lifeState = .alive
        }
    }
    
    func update(_ currentTime: TimeInterval, withSceneSize sceneSize: CGSize)
    {
        //Is the target still sleeping?
        if self.lifeState == .sleeping
        {
            //Already time for this?
            if currentTime >= self.launchTime
            {
                launch()
            }
            else
            {
                return
            }
        }
        
        //Now we are definitely launched.
        //Are we already killed?
        if self.lifeState == .killed
        {
            return
        }
        
        //Check bottom.
        //Maybe we survived.
        if (self.position.y < (-0.5 * (sceneSize.height + self.size.height + SwipeTarget.bottomTolerance)))
        {
            self.lifeState = .survived
        }
        
        //One of the intermediate alive states:
        //Nothing to do.
    }
    
    //For overriding:
    func didLaunch() -> SKPhysicsBody
    {
        //Default returns a rectangle with gravity and rotation:
        let physics = SKPhysicsBody(rectangleOf: self.size)
        
        physics.affectedByGravity = true
        physics.allowsRotation = true
        
        return physics
    }
    
    //For overriding:
    func killedByHit() -> Bool
    {
        //Default is a kill:
        return true
    }
    
    //For overriding:
    func handleSurvival() -> [SwipeTargetAction]
    {
        //Default is nothing:
        return []
    }
    
    //For overriding:
    func handleKill() -> [SwipeTargetAction]
    {
        //Default is nothing:
        return []
    }
}
