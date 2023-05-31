//
//  CanvasView.swift
//  Kanji Master
//
//  Created by Stefano on 17/04/23.
//

import Foundation
import PencilKit
import SwiftUI

struct CanvasView: UIViewRepresentable {
    
    @Binding var canvasView: PKCanvasView
    var kanjiData: KanjiData
    @Binding var showStatus: Int
    @Binding var accuracy: Double
    @Binding var warningText: String
    @Binding var showWarning: Bool
    
    func makeUIView(context: Context) -> PKCanvasView {

        canvasView.tool = PKInkingTool(.pen, color: .black, width: 15)
        #if targetEnvironment(simulator)
        canvasView.drawingPolicy = .anyInput
        #endif
        canvasView.backgroundColor = .systemBackground
        canvasView.delegate = context.coordinator
        return canvasView
    }
    
    func updateUIView(_ uiView: PKCanvasView, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self, kanjiData: kanjiData, showStatus: _showStatus, accuracy: _accuracy, warningText: _warningText, showWarning: _showWarning)
    }
    
    final class Coordinator: NSObject, PKCanvasViewDelegate {
        var canvasView: CanvasView
        var kanjiData: KanjiData
        var timer: Timer?
        var timerIncorrectNumberOfStrokes: Timer?
        @Binding var showStatus: Int
        @Binding var accuracy: Double
        @Binding var warningText: String
        @Binding var showWarning: Bool
        
        init(_ control: CanvasView, kanjiData: KanjiData, showStatus: Binding<Int>, accuracy: Binding<Double>, warningText: Binding<String>, showWarning: Binding<Bool>) {
            self.canvasView = control
            self.kanjiData = kanjiData
            self._showStatus = showStatus
            self._accuracy = accuracy
            self._warningText = warningText
            self._showWarning = showWarning
        }
        
        func interpolate(_ strokes: [CGPoint], toLength length: Int) -> [CGPoint] {
            let n = strokes.count
            var result = strokes
            
            if n < length {
                // Interpolate additional points
                let interval = Double(n-1) / Double(length-1)
                var t = 0.0
                var i = 0
                var j = 1
                while j < n && i < length {
                    let x1 = strokes[j-1].x
                    let y1 = strokes[j-1].y
                    let x2 = strokes[j].x
                    let y2 = strokes[j].y
                    let x = x1 + (x2 - x1) * (t - Double(j-1)) / (Double(j) - Double(j-1))
                    let y = y1 + (y2 - y1) * (t - Double(j-1)) / (Double(j) - Double(j-1))
                    result.insert(CGPoint(x: x, y: y), at: i+1)
                    i += 1
                    t += interval
                    if t > Double(j) && j < n-1 {
                        j += 1
                    }
                }
            } else if n > length {
                // Remove excess points
                let interval = Double(n-1) / Double(length-1)
                var t = 0.0
                var i = 0
                var j = 1
                while i < length {
                    let x1 = strokes[j-1].x
                    let y1 = strokes[j-1].y
                    let x2 = strokes[j].x
                    let y2 = strokes[j].y
                    if t > Double(j) && j < n-1 {
                        j += 1
                    }
                    let x = x1 + (x2 - x1) * (t - Double(j-1)) / (Double(j) - Double(j-1))
                    let y = y1 + (y2 - y1) * (t - Double(j-1)) / (Double(j) - Double(j-1))
                    result[i] = CGPoint(x: x, y: y)
                    i += 1
                    t += interval
                }
                // Remove any remaining points
                result.removeSubrange(length..<n)
            }
            
            return result
        }
        
        func CGPointDistanceSquared(from: CGPoint, to: CGPoint) -> Float {
            let dx = from.x - to.x
            let dy = from.y - to.y
            return Float(sqrt((dx * dx) + (dy * dy)))
        }
        
        func computeDistance(firstPointsArray: [CGPoint], secondPointsArray: [CGPoint]) -> [[Float]] {
            var distances: [[Float]] = Array(repeating: Array(repeating: 0.0, count: secondPointsArray.count), count: firstPointsArray.count)
            
            for i in 0..<firstPointsArray.count {
                for j in 0..<secondPointsArray.count {
                    distances[i][j] = CGPointDistanceSquared(from: firstPointsArray[i], to: secondPointsArray[j])
                }
            }
            return distances
        }
        
        
        func dtw(verifiedStrokes: [CGPoint], userStrokes: [CGPoint]) -> Double {
            var accDistance = Array(repeating: Array(repeating: Double.infinity, count: verifiedStrokes.count + 1), count: userStrokes.count + 1)
            accDistance[0][0] = 0.0
            let distance = computeDistance(firstPointsArray: verifiedStrokes, secondPointsArray: userStrokes)
            for i in 0..<verifiedStrokes.count {
                for j in 0..<userStrokes.count {
                    let cost = distance[i][j]
                    accDistance[i+1][j+1] = Double(cost) + min(accDistance[i][j+1], accDistance[i+1][j], accDistance[i][j])
                }
            }
            
            // Calculate the optimal warping path
            var i = verifiedStrokes.count
            var j = userStrokes.count
            var path = [(i, j)]
            while i > 1 || j > 1 {
                if i == 1 {
                    j -= 1
                } else if j == 1 {
                    i -= 1
                } else {
                    let prev = min(accDistance[i-1][j], accDistance[i][j-1], accDistance[i-1][j-1])
                    if accDistance[i-1][j-1] == prev {
                        i -= 1
                        j -= 1
                    } else if accDistance[i-1][j] == prev {
                        i -= 1
                    } else {
                        j -= 1
                    }
                }
                path.append((i, j))
            }
            
            // Calculate the similarity score
            var score = 0.0
            for (i, j) in path {
                score += Double(distance[i-1][j-1])
            }
            return score / Double(path.count)
        }

        
        func mapPoint(_ point: (Double, Double), fromRange: CGRect, toRange: CGRect) -> CGPoint {
            let x = (point.0 - fromRange.minX) / fromRange.width
            let y = (point.1 - fromRange.minY) / fromRange.height
            return CGPoint(x: x * toRange.width + toRange.minX, y: y * toRange.height + toRange.minY)
        }
        
        fileprivate func calculateSimilarityScore(_ canvasView: PKCanvasView) {
            var userStrokes: [[CGPoint]] = []
            canvasView.drawing.strokes.forEach({ stroke in
                userStrokes.append([])
                
                stroke.path.forEach({ point in
                    userStrokes[userStrokes.count - 1].append(point.location)
                })
            })
            
//            print(userStrokes)
            if(kanjiData.kanjiDrawingStrokes.count != userStrokes.count){
                print("Stroke number is not the same")
                return
            }
            
            var predeterminedStrokes = [[CGPoint]]()
            
            kanjiData.kanjiDrawingStrokes.forEach({ stroke in
                predeterminedStrokes.append([])
                stroke.forEach({ point in
                    predeterminedStrokes[predeterminedStrokes.count - 1].append( mapPoint(point, fromRange: CGRect(x: 0, y: 0, width: 109, height: 109), toRange: CGRect(x: 0, y: 0, width: canvasView.visibleSize.width, height: canvasView.visibleSize.height)))
                })
            })

//            print(predeterminedStrokes)
            var average: Double = 0
            for i in 0..<kanjiData.kanjiDrawingStrokes.count {
                
                let minLength = min(predeterminedStrokes[i].count, userStrokes[i].count)
                
                let similarityScore = dtw(verifiedStrokes: interpolate(predeterminedStrokes[i], toLength: minLength), userStrokes: interpolate(userStrokes[i], toLength: minLength))
                
                print("Single stroke score: \(similarityScore)")
                average += similarityScore
            }
            
            average /= Double(kanjiData.kanjiDrawingStrokes.count)
            let lowerBound = 20.0
            let upperBound = 300.0
            print("Similarity Score: \(average)")
            let similarity = min(max(average, lowerBound), upperBound)
            let similarityAvg = 100 - ( (similarity - lowerBound) / ((upperBound - lowerBound) / 100) )

            print("Comparing against \(kanjiData.kanjiCharacter)")
            print("You are \(Int(similarityAvg))% Accurate")
            
            accuracy = similarityAvg
            
            if(similarityAvg > 65) {
                if(showStatus < 3) {
                    timerIncorrectNumberOfStrokes?.invalidate()
                    showStatus += 1
                    
                    NotificationCenter.default.post(name: NSNotification.Name("newAccuracy"), object: nil, userInfo: ["accuracy": accuracy, "kanjiCharacter": kanjiData.kanjiCharacter, "attempt": showStatus - 1])
                }
            } else {
                timerIncorrectNumberOfStrokes?.invalidate()
            }
            canvasView.drawing.strokes = []
        }
        
        func canvasViewDidEndUsingTool(_ canvasView: PKCanvasView) {
            print("Ended using tool")
            
            timer?.invalidate()
            timerIncorrectNumberOfStrokes?.invalidate()
            
            
            timer = Timer.scheduledTimer(timeInterval: 2.0, target: self, selector: #selector(OBJCCalculateSimilarityScore), userInfo: canvasView, repeats: false)
            
            timerIncorrectNumberOfStrokes = Timer.scheduledTimer(timeInterval: 4.0, target: self, selector: #selector(setWarningForIncorrectNumberOfStrokes), userInfo: nil, repeats: false)
        }
        
        @objc func OBJCCalculateSimilarityScore(_ sender: Timer) {
            calculateSimilarityScore(sender.userInfo as! PKCanvasView)
        }
        
        @objc func setWarningForIncorrectNumberOfStrokes() {
            showWarning = true
            warningText = "Be sure to always draw exactly the same number of strokes!"
            DispatchQueue.main.asyncAfter(deadline: .now() + 4.0, execute: {
                self.showWarning = false
            })
        }
    }
}
