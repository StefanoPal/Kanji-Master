//
//  MainMenuMap.swift
//  Test 1
//
//  Created by Stefano on 11/04/23.
//

import Foundation
import SpriteKit
import SwiftUI

class MainMenuMap: SKScene, SKPhysicsContactDelegate {
    
    var previousCameraPoint = CGPoint.zero
    var cameraNode: SKCameraNode = SKCameraNode()
    var oldSpeechBubble: SKSpriteNode?
    var pressedButton: SKSpriteNode?
    var levelType = LevelType.colorsLevel
    let defaults = UserDefaults.standard
    let generator = UIImpactFeedbackGenerator(style: .medium)
    
    override func didMove(to view: SKView) {
        let panGesture = UIPanGestureRecognizer()
        panGesture.addTarget(self, action: #selector(panGestureAction(_:)))
        view.addGestureRecognizer(panGesture)
        
        print("Did Move")
        let _ = defaults.object(forKey: "accuracyValues") as! [[String: [Double]]]
        
        cameraNode = childNode(withName: "camera") as! SKCameraNode
        
        cameraNode.position = CGPoint(x: 0, y: 0)
        
        let scaledSize = CGSize(width: size.width * cameraNode.xScale, height: size.height * cameraNode.yScale)
        
        let boardNode = childNode(withName: "map")!
        let boardContentRect = boardNode.calculateAccumulatedFrame()
        
        let xInset = min((scaledSize.width / 2) - 100.0, boardContentRect.width / 2)
        let yInset = min((scaledSize.height / 2) - 100.0, boardContentRect.height / 2)
        let insetContentRect = boardContentRect.insetBy(dx: xInset, dy: yInset)
        
        let xRange = SKRange(lowerLimit: insetContentRect.minX, upperLimit: insetContentRect.maxX)
        let yRange = SKRange(lowerLimit: insetContentRect.minY, upperLimit: insetContentRect.maxY)
        let levelEdgeConstraint = SKConstraint.positionX(xRange, y: yRange)
        
        cameraNode.constraints = [levelEdgeConstraint]
        
        scene!.camera = cameraNode
    }
    
    @objc func panGestureAction(_ sender: UIPanGestureRecognizer) {
        guard let camera = self.camera else {
            return
        }
        
        if sender.state == .began {
            previousCameraPoint = camera.position
        }
        
        let translation = sender.translation(in: self.view)
        let newX = previousCameraPoint.x + translation.x * -1
        let newY = previousCameraPoint.y + translation.y
        
        let newPosition = CGPoint(
            x: newX,
            y: newY
        )
        camera.position = newPosition
    }
    
    fileprivate func removeSpeechBubble() {
        if((oldSpeechBubble) != nil) {
            oldSpeechBubble?.removeFromParent()
        }
    }
    
    fileprivate func createAndShowSpeechBubble(_ touchedNode: SKNode) {
        //            print(touchedNode.name)
        
        removeSpeechBubble()
        
        var speechBubble = childNode(withName: "speechBubble")?.copy() as! SKSpriteNode
        
        let map = childNode(withName: "map") as! SKSpriteNode
        var moveMultiplier: Float = 1
        let size = map.calculateAccumulatedFrame()
        let yOffset = 100
        var isRotated = false
        //                print(size)
        
        if(touchedNode.position.y + CGFloat(yOffset + 100) > size.maxY) {
            
            speechBubble = childNode(withName: "rotatedSpeechBubble")?.copy() as! SKSpriteNode
            
            moveMultiplier = -1
            isRotated = true
        }
        
        speechBubble.position = CGPoint(x: touchedNode.position.x, y: touchedNode.position.y + (isRotated ? -100 : 100))
        
        let oldScale = speechBubble.xScale
        
        speechBubble.alpha = 1
        speechBubble.isHidden = false
        
        let accuracyText = speechBubble.childNode(withName: "accuracyText") as! SKLabelNode
        
        var avgAccuracy: Double = .zero
        var areThereZeros = false
        

        let accuracyValues = defaults.object(forKey: "accuracyValues") as! [[String: [Double]]]
        print(levelType)
        for elem in accuracyValues[levelType.rawValue] {
            print(elem)
            var tempAvg = 0.0
            
            for singleAccuracy in elem.value {
                print(singleAccuracy)
                if(singleAccuracy == Double.zero) {
                    areThereZeros = true
                    break
                }
                
                tempAvg += singleAccuracy
            }
            
            if(areThereZeros) {
                break
            }
            
            
            tempAvg /= Double(elem.value.count)
            avgAccuracy += tempAvg
        }
        
        avgAccuracy /= Double(accuracyValues[levelType.rawValue].count)
        
        let textToDisplay = !areThereZeros ? "Avg Accuracy \(Int(avgAccuracy))%" : "Not yet completed"
        
        accuracyText.text = textToDisplay
        
        let scaledHeight = speechBubble.frame.height * ((1 / speechBubble.xScale) - 0.1)
        let scaledWidth = speechBubble.frame.width * ((1 / speechBubble.yScale) - 0.1)
        
        let speechBubbleFrame = CGRect(x: speechBubble.frame.minX, y: speechBubble.frame.minY, width: scaledWidth, height: scaledHeight)
        
        adjustLabelFontSizeToFitRect(labelNode: accuracyText, rect: speechBubbleFrame)
        
        speechBubble.setScale(speechBubble.xScale / 2)
        
        let scaleAct = SKAction.scale(to: oldScale, duration: 0.1)
        
        let moveAct = SKAction.moveBy(x: 0, y: CGFloat(Float(yOffset) * moveMultiplier), duration: 0.1)
        
        let parallelAct = SKAction.group([scaleAct, moveAct])
        
        addChild(speechBubble)
        speechBubble.run(parallelAct)
        oldSpeechBubble = speechBubble
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            
            let location = touch.location(in: self)
            let touchedNode = atPoint(location)
            print("Touches Began")

            
            if(touchedNode.name == "play") {
                levelType = LevelType(rawValue: touchedNode.userData!["levelData"] as! Int)!
                pushButton(touchedNode: touchedNode.parent!, textureName: "circularButton2_pressed")
                createAndShowSpeechBubble(touchedNode.parent!)
    
            }
            
            if(touchedNode.name == "levelButton") {
                levelType = LevelType(rawValue: touchedNode.userData!["levelData"] as! Int)!
                pushButton(touchedNode: touchedNode, textureName: "circularButton2_pressed")
                createAndShowSpeechBubble(touchedNode)
                
            }
            
            if(touchedNode.name == "startButton") {
                pushButton(touchedNode: touchedNode, textureName: "wideButton2_pressed")
            }
            
            if(touchedNode.name == "startText") {
                pushButton(touchedNode: touchedNode.parent!, textureName: "wideButton2_pressed")
            }
            
        }
    }
    
    fileprivate func pushButton(touchedNode: SKNode, textureName: String) {
        let spriteNode = touchedNode as! SKSpriteNode
        spriteNode.texture = SKTexture(imageNamed: textureName)
        
        spriteNode.position.y -= 5
        generator.impactOccurred()
        pressedButton = spriteNode
    }
    
    fileprivate func checkAndResetButton() {
        if(pressedButton != nil) {
            pressedButton!.texture = SKTexture(imageNamed: pressedButton!.userData!["textureName"] as! String)
            
            pressedButton!.position.y += 5
            pressedButton = nil
        }
    }
    
    func adjustLabelFontSizeToFitRect(labelNode:SKLabelNode, rect:CGRect) {
        
        print(rect, labelNode.frame)

        // Change the fontSize.
        labelNode.fontSize *= (rect.width / labelNode.frame.width)

        // Optionally move the SKLabelNode to the center of the rectangle.
//        labelNode.position = CGPoint(x: rect.midX, y: rect.midY - labelNode.frame.height / 2.0)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        checkAndResetButton()
        
        print("Touches Ended")
        for touch in touches {
            let location = touch.location(in: self)
            let touchedNode = atPoint(location)
            print(touchedNode.name)
            
            if(touchedNode.name == "startButton") {
                NotificationCenter.default.post(name: NSNotification.Name("startPractice"), object: nil, userInfo: ["levelType": levelType])
                
                removeSpeechBubble()
            }
            
            if(touchedNode.name == "startText") {
                NotificationCenter.default.post(name: NSNotification.Name("startPractice"), object: nil, userInfo: ["levelType": levelType])
                
                removeSpeechBubble()
            }
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        print("Touches Moved")
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        print("Touches Cancelled")
        checkAndResetButton()
    }
}
