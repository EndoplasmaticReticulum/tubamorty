//
//  GameViewController.swift
//  tubamorty
//
//  Created by Jonas Treumer on 18.01.17.
//  Copyright © 2017 TU Bergakademie Freiberg. All rights reserved.
//

import UIKit
import SpriteKit

class GameViewController: UIViewController
{
    //The scene:
    private let mainScene = MainScene()
    
    //The current touch or nil:
    private var touch: UITouch?
    
    override func viewWillLayoutSubviews()
    {
        //Call to super:
        super.viewWillLayoutSubviews()
        
        //Get the view:
        guard let gameView = (self.view as! SKView?) else
        {
            print("Failed to obtain base view.")
            return
        }
        
        //Present the scene:
        gameView.presentScene(self.mainScene)
    }
    
    //Handle touches:
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?)
    {
        super.touchesBegan(touches, with: event)
        
        //If there is already a touch, we ignore this:
        guard let touch = touches.first, (self.touch == nil) else
        {
            return
        }
        
        //Take the first one:
        self.touch = touch
        
        //Notify the scene:
        self.mainScene.beginCut(withTouch: touch)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?)
    {
        super.touchesMoved(touches, with: event)
        
        //Do we have a touch?
        guard let touch = self.touch, touches.contains(touch) else
        {
            return
        }
        
        //Notify the scene:
        self.mainScene.proceedCut(withTouch: touch)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?)
    {
        super.touchesEnded(touches, with: event)
        
        //Do we have a touch?
        guard let touch = self.touch, touches.contains(touch) else
        {
            return
        }
        
        //Reset our touch:
        self.touch = nil
        
        //Notify the scene:
        self.mainScene.endCut(withTouch: touch)
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?)
    {
        super.touchesCancelled(touches, with: event)
        
        //Do we have a touch?
        guard let touch = self.touch, touches.contains(touch) else
        {
            return
        }
        
        //Reset our touch:
        self.touch = nil
        
        //Notify the scene:
        self.mainScene.endCut(withTouch: touch)
    }
    
    //Always hide the status bar:
    override var prefersStatusBarHidden: Bool
    {
        return true
    }
}
