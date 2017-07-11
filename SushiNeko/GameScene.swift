//
//  GameScene.swift
//  SushiNeko
//
//  Created by Basanta Chaudhuri on 7/10/17.
//  Copyright © 2017 Abhishek Chaudhuri. All rights reserved.
//

import SpriteKit

/* Tracking enum for use with character and sushi side */
enum Side {
    case left, right, none
}

class GameScene: SKScene {
    /* Game objects */
    var sushieBasePiece: SushiPiece!
    
    /* Cat character */
    var character: Character!
    
    override func didMove(to view: SKView) {
        super.didMove(to: view)
        
        /* Connect game objects */
        sushieBasePiece = childNode(withName: "sushiBasePiece") as! SushiPiece
        character = childNode(withName: "character") as! Character
        
        /* Setup chopstick connection */
        sushieBasePiece.connectChopsticks()
    }
}
