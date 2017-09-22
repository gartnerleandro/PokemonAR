//
//  Scene.swift
//  PokemonAR
//
//  Created by Leandro Gartner on 12/8/17.
//  Copyright © 2017 Leandro Gartner. All rights reserved.
//

import SpriteKit
import ARKit
import GameplayKit

class Scene: SKScene {
    
    let remainingLabel = SKLabelNode()
    var timer : Timer?
    var targetsCreated = 0
    var targetCount = 0 {
        didSet{
            self.remainingLabel.text = "Faltan: \(targetCount)"
        }
    }
    let deathSound = SKAction.playSoundFileNamed("QuickDeath", waitForCompletion: false)
    let startTime = Date()
    
    override func didMove(to view: SKView) {
        
        remainingLabel.fontSize = 30
        remainingLabel.fontName = "Avenir Next"
        remainingLabel.color = .white
        remainingLabel.position = CGPoint(x: 0, y: view.frame.midY-50)
        
        addChild(remainingLabel)
        
        targetCount = 0
        
        timer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: true, block: { (timer) in
            self.createTarget()
        })
        
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        guard let touch = touches.first else {return}
        
        let location = touch.location(in: self)
        let hit = nodes(at: location)
        
        if let sprite = hit.first {
            
            let scaleOut = SKAction.scale(to: 2, duration: 0.4)
            let fadeOut = SKAction.fadeOut(withDuration: 0.4)
            let remove = SKAction.removeFromParent()
            let groupAction = SKAction.group([scaleOut, fadeOut, deathSound])
            let sequenceAction = SKAction.sequence([groupAction, remove])
            
            sprite.run(sequenceAction)
            
            targetCount -= 1
            
            if targetsCreated == 25 && targetCount == 0 {
                gameOver()
            }
        }
    }
    
    func createTarget() {
        
        if targetsCreated == 25 {
            timer?.invalidate()
            timer = nil
            return
        }
        
        targetsCreated += 1
        targetCount += 1
        
        guard let sceneView = self.view as? ARSKView else {return}
        
        let random = GKRandomSource.sharedRandom()
        
        let rotateX = simd_float4x4(SCNMatrix4MakeRotation(2.0 * Float.pi * random.nextUniform(), 1, 0, 0))
        
        let rotateY = simd_float4x4(SCNMatrix4MakeRotation(2.0 * Float.pi * random.nextUniform(), 0, 1, 0))
        
        let rotation = simd_mul(rotateX, rotateY)
        
        var translation = matrix_identity_float4x4
        translation.columns.3.z = -1.5
        
        let finalTransform = simd_mul(rotation, translation)
        
        let anchor = ARAnchor(transform: finalTransform)
        
        sceneView.session.add(anchor: anchor)
        
    }
    
    func gameOver() {
        remainingLabel.removeFromParent()
        
        let gameOver = SKSpriteNode(imageNamed: "gameover")
        
        addChild(gameOver)
        
        let timeTaken = Date().timeIntervalSince(startTime)
        let timeTakenLabel = SKLabelNode(text: "It took you \(Int(timeTaken)) seconds")
        timeTakenLabel.fontSize = 40
        timeTakenLabel.color = .white
        timeTakenLabel.position = CGPoint(x: 0, y: view!.frame.midY-50)
        
        addChild(timeTakenLabel)
    }
}
