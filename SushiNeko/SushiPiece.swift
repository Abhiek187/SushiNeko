//
//  SushiPiece.swift
//  SushiNeko
//
//  Created by Basanta Chaudhuri on 7/11/17.
//  Copyright © 2017 Abhishek Chaudhuri. All rights reserved.
//

import SpriteKit

class SushiPiece: SKSpriteNode {
    /* Sushi type */
    var side: Side = .none {
        didSet {
            switch side {
            case .left:
                /* Show left chopstick */
                leftChopstick.isHidden = false
            case .right:
                /* Show right chopstick */
                rightChopstick.isHidden = false
            case .none:
                /* Hide all chopsticks */
                leftChopstick.isHidden = true
                rightChopstick.isHidden = true
            }
        }
    }
    
    /* Chopstick objects */
    var leftChopstick: SKSpriteNode!
    var rightChopstick: SKSpriteNode!
    
    /* You are required to implement this for your subclass to work */
    override init(texture: SKTexture?, color: UIColor, size: CGSize) {
        super.init(texture: texture, color: color, size: size)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func connectChopsticks() {
        /* Connect our child chopstick nodes */
        leftChopstick = childNode(withName: "leftChopstick") as! SKSpriteNode
        rightChopstick = childNode(withName: "rightChopstick") as! SKSpriteNode
        
        /* Set the default side */
        side = .none
    }
}
