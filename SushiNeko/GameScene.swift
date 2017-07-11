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

/* Tracking enum for game state */
enum GameState {
    case title, ready, playing, gameOver
}

class GameScene: SKScene {
    /* Game objects */
    var mat: SKSpriteNode!
    var title: SKLabelNode!
    var sushiBasePiece: SushiPiece!
    var healthBar: SKSpriteNode!
    var scoreLabel: SKLabelNode!
    var highScoreLabel: SKLabelNode!
    
    var health: CGFloat = 1.0 {
        didSet {
            /* Cap Health */
            if health > 1.0 { health = 1.0 }
            
            /* Scale health bar between 0.0 -> 1.0 e.g 0 -> 100% */
            healthBar.xScale = health
        }
    }
    
    var score: Int = 0 {
        didSet {
            scoreLabel.text = String(score)
        }
    }
    
    /* Cat character */
    var character: Character!
    
    /* Sushi tower array */
    var sushiTower: [SushiPiece] = []
    
    /* Game management */
    var state: GameState = .title
    var playButton: MSButtonNode!
    
    override func didMove(to view: SKView) {
        super.didMove(to: view)
        
        /* Connect game objects */
        mat = childNode(withName: "mat") as! SKSpriteNode
        title = childNode(withName: "title") as! SKLabelNode
        sushiBasePiece = childNode(withName: "sushiBasePiece") as! SushiPiece
        healthBar = childNode(withName: "healthBar") as! SKSpriteNode
        scoreLabel = childNode(withName: "scoreLabel") as! SKLabelNode
        highScoreLabel = childNode(withName: "highScoreLabel") as! SKLabelNode
        character = childNode(withName: "character") as! Character
        
        /* UI game objects */
        playButton = childNode(withName: "playButton") as! MSButtonNode
        
        /* Setup chopstick connection */
        sushiBasePiece.connectChopsticks()
        
        /* Manually stack the start of the tower */
        addTowerPiece(side: .none)
        addTowerPiece(side: .right)
        
        /* Randomize tower to just outside of the screen */
        addRandomPieces(total: 10)
        
        /* Setup play button selection handler */
        playButton.selectedHandler = {
            /* Start game */
            self.state = .ready
            
            /* Hide title screen */
            self.mat.isHidden = true
            self.title.isHidden = true
        }
    }
    
    func addTowerPiece(side: Side) {
        /* Add a new sushi piece to the sushi tower */
        
        /* Copy original sushi piece */
        let newPiece = sushiBasePiece.copy() as! SushiPiece
        newPiece.connectChopsticks()
        
        /* Access last piece properties */
        let lastPiece = sushiTower.last
        
        /* Add on top of last piece, default on first piece */
        let lastPosition = lastPiece?.position ?? sushiBasePiece.position
        newPiece.position.x = lastPosition.x
        newPiece.position.y = lastPosition.y + 55
        
        /* Increment Z to ensure it's on top of the last piece, default on first piece */
        let lastZPosition = lastPiece?.zPosition ?? sushiBasePiece.zPosition
        newPiece.zPosition = lastZPosition + 1
        
        /* Set side */
        newPiece.side = side
        
        /* Add sushi to scene */
        addChild(newPiece)
        
        /* Add sushi piece to the sushi tower */
        sushiTower.append(newPiece)
    }
    
    func addRandomPieces(total: Int) {
        /* Add random sushi pieces to the sushi tower */
        
        for _ in 1...total {
            
            /* Need to access last piece properties */
            let lastPiece = sushiTower.last!
            
            /* Need to ensure we don't create impossible sushi structures */
            if lastPiece.side != .none {
                addTowerPiece(side: .none)
            } else {
                
                /* Random Number Generator */
                let rand = arc4random_uniform(100)
                
                if rand < 45 {
                    /* 45% Chance of a left piece */
                    addTowerPiece(side: .left)
                } else if rand < 90 {
                    /* 45% Chance of a right piece */
                    addTowerPiece(side: .right)
                } else {
                    /* 10% Chance of an empty piece */
                    addTowerPiece(side: .none)
                }
            }
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        /* Called when a touch begins */
        
        /* Game not ready to play */
        if state == .gameOver || state == .title { return }
        /* Game begins on first touch */
        if state == .ready {
            state = .playing
        }
        
        /* We only need a single touch here */
        let touch = touches.first!
        
        /* Get touch position in scene */
        let location = touch.location(in: self)
        
        /* Was touch on left/right hand side of screen? */
        if location.x > size.width / 2 {
            character.side = .right
        } else {
            character.side = .left
        }
        
        /* Grab sushi piece on top of the base sushi piece, it will always be 'first' */
        if let firstPiece = sushiTower.first {
            /* Check character side against sushi piece side (this is our death collision check) */
            if character.side == firstPiece.side {
                gameOver()
                
                /* No need to continue as player is dead */
                return
            }
            
            /* Increment Health */
            health += 0.1
            
            /* Increment Score */
            score += 1
            
            /* Remove from sushi tower array */
            sushiTower.removeFirst()
            
            /* Animate the punched sushi piece */
            firstPiece.flip(character.side)
        
            /* Add a new sushi piece to the top of the sushi tower */
            addRandomPieces(total: 1)
        }
    }
    
    func moveTowerDown() {
        var n: CGFloat = 0
        for piece in sushiTower {
            let y = (n * 55) + 215
            piece.position.y -= (piece.position.y - y) * 0.5
            n += 1
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        /* Called before each frame is rendered */
        if state != .playing {
            return
        }
        /* Decrease health */
        health -= 0.01
        /* Has the player run out of health? */
        if health < 0 {
            gameOver()
        }
        
        moveTowerDown()
    }
    
    func gameOver() {
        /* Game over! */
        state = .gameOver
        
        /* Turn all the sushi pieces red */
        for sushiPiece in sushiTower {
            sushiPiece.run(SKAction.colorize(with: UIColor.red, colorBlendFactor: 1.0, duration: 0.5))
        }
        
        /* Make the base turn red */
        sushiBasePiece.run(SKAction.colorize(with: UIColor.red, colorBlendFactor: 1.0, duration: 0.5))
        
        /* Make the player turn red */
        character.run(SKAction.colorize(with: UIColor.red, colorBlendFactor: 1.0, duration: 0.5))
        
        /* Update high score */
        playerScoreUpdate()
        
        /* Change play button selection handler */
        playButton.selectedHandler = {
            
            /* Grab reference to the SpriteKit view */
            let skView = self.view as SKView!
            
            /* Load Game scene */
            guard let scene = GameScene(fileNamed: "GameScene") as GameScene! else {
                return
            }
            
            /* Ensure correct aspect mode */
            scene.scaleMode = .aspectFill
            
            /* Restart GameScene */
            skView?.presentScene(scene)
        }
    }
    
    func playerScoreUpdate() {
        /* Saves the high score of player */
        let highScore = UserDefaults().integer(forKey: "highscore")
        if score > highScore {
            UserDefaults().set(score, forKey: "highscore")
        }
        /* Display high score below player's score */
        highScoreLabel.fontName = "Papyrus"
        highScoreLabel.fontSize = 36
        highScoreLabel.fontColor = SKColor.green
        highScoreLabel.position = CGPoint(x: 160, y: 272)
        highScoreLabel.zPosition = 1001
        highScoreLabel.text = "HighScore: \(highScore)"
    }
}
