//
//  CutLine.swift
//  tubamorty
//
//  Created by Jonas Treumer on 19.01.17.
//  Copyright © 2017 TU Bergakademie Freiberg. All rights reserved.
//

import SpriteKit

class CutLine: SKShapeNode
{
    //The maximum distance of two cut line points:
    var maxCutLinePointDistance = 100.0
    
    //How long may the cutline be at all?
    var maxCutLinePointCount = 10
    
    //The current cut line points:
    private var cutLinePoints: [CGPoint] = []
    private var lastCutLinePoint: CGPoint? = nil
    
    //Euclidean distance:
    private class func distanceBetweenPoints(_ point1: CGPoint, _ point2: CGPoint) -> Double
    {
        return sqrt(pow(Double(point1.x - point2.x), 2) + pow(Double(point1.y - point2.y), 2))
    }
    
    func draw(inScene scene: SKScene)
    {
        //Specify the path:
        let path = CGMutablePath()
        
        //Anything at all?
        if self.cutLinePoints.count >= 2
        {
            //Start:
            path.move(to: self.cutLinePoints.first!)
            
            for i in 1..<self.cutLinePoints.count
            {
                path.addLine(to: self.cutLinePoints[i])
            }
        }
        
        //Leave the scene:
        self.removeFromParent()
        
        //Apply to shape node:
        self.path = path
        
        //Re-add to scene:
        scene.addChild(self)
    }
    
    //Return the new interpolated cut line points:
    func beginCut(withPoint point: CGPoint) -> [CGPoint]
    {
        self.cutLinePoints.removeAll()
        self.lastCutLinePoint = nil
        
        //Delegate to normal processing:
        return proceedCut(withPoint: point)
    }
    
    //Return the new interpolated cut line points:
    func proceedCut(withPoint point: CGPoint) -> [CGPoint]
    {
        //Collect new points:
        var points = [CGPoint]()
        
        //If there is a last touch point, we interpolate in steps of maxCutPointDistance:
        if let lastPoint = self.lastCutLinePoint
        {
            let distance = CutLine.distanceBetweenPoints(lastPoint, point)
            
            let dx = Double(point.x - lastPoint.x) * self.maxCutLinePointDistance / distance
            let dy = Double(point.y - lastPoint.y) * self.maxCutLinePointDistance / distance
            
            if distance >= self.maxCutLinePointDistance
            {
                for i in 1...Int(distance / self.maxCutLinePointDistance)
                {
                    points.append(CGPoint(x: Double(lastPoint.x) + (Double(i) * dx), y: Double(lastPoint.y) + (Double(i) * dy)))
                }
            }
        }
        
        //Append the new point itself:
        points.append(point)
        
        //Save the new point as last one:
        self.lastCutLinePoint = point
        
        //Append the resulting points to the cut line, truncate it and return them:
        self.cutLinePoints += points
        self.cutLinePoints = [CGPoint](self.cutLinePoints.suffix(self.maxCutLinePointCount))
        
        return points
    }
    
    //Finalize the cut:
    func endCut()
    {
        self.cutLinePoints.removeAll()
        self.lastCutLinePoint = nil
    }
}
