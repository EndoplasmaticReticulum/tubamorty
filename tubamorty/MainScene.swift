//
//  MainScene.swift
//  tubamorty
//
//  Created by Jonas Treumer on 18.01.17.
//  Copyright © 2017 TU Bergakademie Freiberg. All rights reserved.
//

import AVFoundation
import SpriteKit

class MainScene: SKScene, AVAudioPlayerDelegate
{
    //Have we already done the initialization?
    private var isInitialized = false
    
    //The current time:
    private var currentTime: TimeInterval = 0
    
    //The background:
    private let background = SKSpriteNode(imageNamed: "Background")
    
    //The label for Lost, Won etc.:
    private let label = SKLabelNode(fontNamed: "Chalkduster")
    
    //The walls:
    private let leftWall = SKNode()
    private let rightWall = SKNode()
    private let topWall = SKNode()
    
    //The cut line:
    private let cutLine = CutLine()
    
    //All the targets that are currently around:
    private var targets = [SwipeTarget]()
    
    //In which wave are we currently?
    private var waveCounter = 0
    
    //How many lifes do we have left?
    private var lifeCounter = 3
    
    //Did we blow up?
    //That's a safe death, no chance to collect some lifes on the fly:
    private var blownUp = false
    
    //Is the game currently running?
    private var gamePaused = false
    
    //A reference to an audio player:
    private var audioPlayer: AVAudioPlayer!
    
    private class func selectRandomImage(fromImages images: [UIImage]) -> UIImage
    {
        return images[Int(arc4random_uniform(UInt32(images.count)))]
    }
    
    override init()
    {
        super.init()
        commonInit()
    }
    
    override init(size: CGSize)
    {
        super.init(size: size)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit()
    {
        guard !self.isInitialized else
        {
            return
        }
        
        //Add background:
        self.background.position = CGPoint(x: 0, y: 0)
        self.addChild(self.background)
        
        //Add label:
        self.label.position = CGPoint(x: 0, y: 0)
        self.label.fontSize = 65
        self.label.isHidden = true
        
        self.addChild(self.label)
        
        //Add walls:
        self.addChild(self.leftWall)
        self.addChild(self.rightWall)
        self.addChild(self.topWall)
        
        //Add cutline:
        self.cutLine.strokeColor = SKColor(red: 0.85, green: 0, blue: 0, alpha: 0.3)
        self.cutLine.lineWidth = 20
        self.cutLine.lineJoin = .round
        self.cutLine.lineCap = .round
        
        self.addChild(self.cutLine)
        
        //Set gravity:
        self.physicsWorld.gravity = CGVector(dx: 0, dy: -5)
        
        //We are done:
        self.isInitialized = true
    }
    
    private func processHits(atPoints points: [CGPoint])
    {
        //Process the points:
        for point in points
        {
            //Try to hit:
            self.targets.forEach({ $0.tryHit(withPoint: point) })
        }
    }
    
    override func didMove(to view: SKView)
    {
        //Set size and scale mode:
        self.size = view.bounds.size
        self.scaleMode = .aspectFill
        
        //Fix anchor point at center:
        self.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        
        //Set background size:
        self.background.size = self.size
        
        //Set walls:
        //Left:
        let leftPhysics = SKPhysicsBody(edgeFrom: CGPoint(x: -0.5 * self.size.width, y: -0.5 * self.size.height), to: CGPoint(x: -0.5 * self.size.width, y: 0.5 * self.size.height))
        
        leftPhysics.affectedByGravity = false
        leftPhysics.categoryBitMask = PhysicsCategory.Wall
        leftPhysics.collisionBitMask = PhysicsCategory.None
        
        self.leftWall.physicsBody = leftPhysics
        
        //Right:
        let rightPhysics = SKPhysicsBody(edgeFrom: CGPoint(x: 0.5 * self.size.width, y: -0.5 * self.size.height), to: CGPoint(x: 0.5 * self.size.width, y: 0.5 * self.size.height))
        
        rightPhysics.affectedByGravity = false
        rightPhysics.categoryBitMask = PhysicsCategory.Wall
        rightPhysics.collisionBitMask = PhysicsCategory.None
        
        self.rightWall.physicsBody = rightPhysics
        
        //Top:
        let topPhysics = SKPhysicsBody(edgeFrom: CGPoint(x: -0.5 * self.size.width, y: 0.5 * self.size.height), to: CGPoint(x: 0.5 * self.size.width, y: 0.5 * self.size.height))
        
        topPhysics.affectedByGravity = false
        topPhysics.categoryBitMask = PhysicsCategory.Wall
        topPhysics.collisionBitMask = PhysicsCategory.None
        
        self.topWall.physicsBody = topPhysics
    }
    
    override func update(_ currentTime: TimeInterval)
    {
        //Superclass:
        super.update(currentTime)
        
        //Save the current time:
        self.currentTime = currentTime
        
        //Are we paused?
        guard !self.gamePaused else
        {
            return
        }
        
        //Did we lose all lives or blow up?
        if (self.lifeCounter == 0) || self.blownUp
        {
            self.targets.forEach({ $0.removeFromParent() })
            self.targets.removeAll()
            self.gamePaused = true
            gameLost(byBlowUp: self.blownUp)
            
            return
        }
        
        //Are we done with the wave?
        if self.targets.count == 0
        {
            //Spawn the next one:
            self.waveCounter += 1
            self.targets = spawnWave()
            
            //Add the targets:
            self.targets.forEach({ self.addChild($0) })
            
            //Did we win?
            if self.targets.count == 0
            {
                self.gamePaused = true
                gameWon()
                
                return
            }
        }
        
        //Update all the targets:
        self.targets = self.targets.filter()
        {
            //Update the target:
            switch $0.update(currentTime, withSceneSize: self.size)
            {
            case .survived:
                
                //Remove the target from the scene and invoke the callback:
                $0.removeFromParent()
                targetSurvived($0)
                
                //Reduce the life:
                self.lifeCounter = max(0, self.lifeCounter - $0.lifesLostOnSurvival)
                
                //Remove from array:
                return false
                
            case .killed:
                
                //Remove the target from the scene and invoke the callback:
                $0.removeFromParent()
                targetKilled($0)
                
                //Remove from array:
                return false
                
            default:
                
                //Keep the target:
                return true
            }
        }
    }
    
    //Manage cuts:
    func beginCut(withTouch touch: UITouch)
    {
        processHits(atPoints: self.cutLine.beginCut(withPoint: touch.location(in: self)))
    }
    
    func proceedCut(withTouch touch: UITouch)
    {
        processHits(atPoints: self.cutLine.proceedCut(withPoint: touch.location(in: self)))
    }
    
    func endCut(withTouch touch: UITouch)
    {
        self.cutLine.endCut()
        
        //Cancel the hits:
        self.targets.forEach({ $0.cancelHit() })
    }
    
    
    
    
    //*******************
    //*** Start here! ***
    //*******************
    
    //TODO: Manage the waves.
    func spawnWave() -> [SwipeTarget]
    {
        let mortys: [SwipeTarget] = (0..<((self.waveCounter / 3) + 1)).map()
        {
            _ in
            
            SwipeTargetMorty(image: MainScene.selectRandomImage(fromImages: SwipeTargetMorty.mortyImages), color: SKColor.clear, size: CGSize(width: 100, height: 100), launchTime: self.currentTime + 3, screenSize: self.size, velocity: CGVector(dx: -400 + CGFloat(arc4random_uniform(800)), dy: CGFloat(1000 + arc4random_uniform(1000))), angularVelocity: CGFloat(arc4random_uniform(100)) / 100.0)
        }
        
        let linclers: [SwipeTarget] = (0..<(self.waveCounter / 5)).map()
        {
            _ in
            
            let lincler = SwipeTargetBomb(image: UIImage(named: "Lincler")!, color: SKColor.clear, size: CGSize(width: 150, height: 260), launchTime: self.currentTime + 3, screenSize: self.size, velocity: CGVector(dx: -400 + CGFloat(arc4random_uniform(800)), dy: CGFloat(1000 + arc4random_uniform(1000))), angularVelocity: CGFloat(arc4random_uniform(100)) / 100.0)
            
            lincler.lifesLostOnSurvival = 0
            
            return lincler
        }
        
        return mortys + linclers
    }
    
    //TODO: A swipe target has survived.
    func targetSurvived(_ swipeTarget: SwipeTarget)
    {
        //swipeTarget.lifesLostOnSurvival determines the number of lifes that will be lost.
        //It is subtracted after this call.
    }
    
    //TODO: A swipe target has been killed.
    func targetKilled(_ swipeTarget: SwipeTarget)
    {
        //Grant some points to the player.
        //Or blow him/her up by setting self.blownUp.
        if swipeTarget is SwipeTargetBomb
        {
            self.blownUp = true
        }
    }
    
    //TODO: We won the game.
    func gameWon()
    {
        self.label.isHidden = false
        self.label.text = "You won!"
        self.label.fontColor = SKColor.green
    }
    
    //TODO: We lost the game.
    func gameLost(byBlowUp blowUp: Bool)
    {
        self.label.isHidden = false
        self.label.text = "Game over"
        self.label.fontColor = SKColor.red
        
        //Scream:
        let soundURL = URL(fileURLWithPath: Bundle.main.path(forResource: "Scream", ofType: "mp3")!)
        
        self.audioPlayer = try! AVAudioPlayer(contentsOf: soundURL)
        self.audioPlayer.play()
    }
}








