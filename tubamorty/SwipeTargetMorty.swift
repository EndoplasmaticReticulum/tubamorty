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
    //Load the Morty textures into an array:
    static let mortyImages = (1...15).map({ return UIImage(named: "M\($0)")! })
    
    //TODO: Override some methods.
}
