//
//  DrawingView.swift
//  Kanji Master
//
//  Created by Stefano on 17/04/23.
//

import Foundation
import UIKit
import SwiftUI
import PencilKit

class UIDrawingView: UIView {
    var shapeLayer: CAShapeLayer?
    var pathLayers: [CAShapeLayer] = []
    var paths: [UIBezierPath] = []
    let colorScheme: ColorScheme
    
    let palette = [
        UIColor(red: 0.98, green: 0.29, blue: 0.23, alpha: 1.0), // Red
        UIColor(red: 0.00, green: 0.68, blue: 0.94, alpha: 1.0), // Blue
        UIColor(red: 0.00, green: 0.80, blue: 0.60, alpha: 1.0), // Green
        UIColor(red: 0.95, green: 0.77, blue: 0.06, alpha: 1.0), // Yellow
        UIColor(red: 0.54, green: 0.27, blue: 0.76, alpha: 1.0), // Purple
        UIColor(red: 0.81, green: 0.27, blue: 0.58, alpha: 1.0), // Pink
        UIColor(red: 0.40, green: 0.73, blue: 0.42, alpha: 1.0), // Light green
        UIColor(red: 0.97, green: 0.50, blue: 0.00, alpha: 1.0), // Orange
        UIColor(red: 0.99, green: 0.70, blue: 0.38, alpha: 1.0), // Light orange
        UIColor(red: 0.31, green: 0.31, blue: 0.31, alpha: 1.0), // Gray
        UIColor(red: 0.50, green: 0.50, blue: 0.50, alpha: 1.0), // Light gray
        UIColor(red: 0.65, green: 0.16, blue: 0.16, alpha: 1.0), // Maroon
        UIColor(red: 0.60, green: 0.73, blue: 0.87, alpha: 1.0), // Light blue
        UIColor(red: 0.41, green: 0.20, blue: 0.60, alpha: 1.0), // Dark purple
        UIColor(red: 0.20, green: 0.20, blue: 0.20, alpha: 1.0), // Very dark gray
        UIColor(red: 0.09, green: 0.57, blue: 0.52, alpha: 1.0), // Teal
        UIColor(red: 0.94, green: 0.35, blue: 0.12, alpha: 1.0), // Burnt orange
        UIColor(red: 0.80, green: 0.39, blue: 0.20, alpha: 1.0) // Rust
    ]
    
    let darkPalette = [
        UIColor(red: 0.87, green: 0.79, blue: 0.66, alpha: 1.0), // Light Peach
        UIColor(red: 0.97, green: 0.78, blue: 0.84, alpha: 1.0), // Light Pink
        UIColor(red: 0.85, green: 0.75, blue: 0.82, alpha: 1.0), // Lavender
        UIColor(red: 0.87, green: 0.63, blue: 0.64, alpha: 1.0), // Dusty Red
        UIColor(red: 1.00, green: 0.95, blue: 0.87, alpha: 1.0), // Cream
        UIColor(red: 0.80, green: 0.94, blue: 0.89, alpha: 1.0), // Mint Green
        UIColor(red: 0.70, green: 0.80, blue: 0.64, alpha: 1.0), // Sage Green
        UIColor(red: 0.55, green: 0.55, blue: 0.55, alpha: 1.0), // Dark Gray
        UIColor(red: 0.84, green: 0.59, blue: 0.67, alpha: 1.0), // Blush
        UIColor(red: 0.80, green: 0.66, blue: 0.50, alpha: 1.0), // Tan
        UIColor(red: 0.50, green: 0.71, blue: 0.96, alpha: 1.0), // Sky Blue
        UIColor(red: 0.60, green: 0.48, blue: 0.97, alpha: 1.0), // Periwinkle
        UIColor(red: 0.99, green: 0.69, blue: 0.48, alpha: 1.0), // Apricot
        UIColor(red: 0.88, green: 0.72, blue: 0.54, alpha: 1.0), // Sand
        UIColor(red: 0.55, green: 0.75, blue: 0.67, alpha: 1.0), // Seafoam Green
        UIColor(red: 0.63, green: 0.30, blue: 0.58, alpha: 1.0), // Plum Purple
        UIColor(red: 1.00, green: 0.80, blue: 0.37, alpha: 1.0), // Goldenrod
        UIColor(red: 0.53, green: 0.77, blue: 0.92, alpha: 1.0), // Baby Blue
        UIColor(red: 0.74, green: 0.47, blue: 0.73, alpha: 1.0), // Mauve
        UIColor(red: 0.50, green: 0.75, blue: 0.82, alpha: 1.0), // Robin's Egg Blue
    ]
    
    init(frame: CGRect, colorScheme: ColorScheme) {
        self.colorScheme = colorScheme
        super.init(frame: frame)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func mapPoint(_ point: CGPoint, fromRange: CGRect, toRange: CGRect) -> CGPoint {
        let x = (point.x - fromRange.minX) / fromRange.width
        let y = (point.y - fromRange.minY) / fromRange.height
        return CGPoint(x: x * toRange.width + toRange.minX, y: y * toRange.height + toRange.minY)
    }
    
    func createShapeLayer(_ path: UIBezierPath) -> CAShapeLayer {
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = path.cgPath
        return shapeLayer
    }
    
    func createAnimation(duration: Double, preDelay: Double, postDelay: Double) -> CAKeyframeAnimation {
        let animation = CAKeyframeAnimation(keyPath: "strokeEnd")
        let totalDuration = preDelay + duration + postDelay
        let preDuration = preDelay + duration
        animation.duration = totalDuration
//        animation.beginTime = CACurrentMediaTime() + delay
        animation.values = [0.0, 0.0, 1.0, 1.0]
        animation.keyTimes = [0.0, NSNumber(value: preDelay / totalDuration), NSNumber(value: preDuration / totalDuration), 1.0]
        animation.timingFunctions = [CAMediaTimingFunction(name: .easeInEaseOut)]
        animation.repeatCount = .greatestFiniteMagnitude
        return animation
    }

    
    func animateDrawing(strokes: [[(Double, Double)]]) {
        pathLayers.forEach({ $0.removeFromSuperlayer() })
        pathLayers = []
        paths = []
        shapeLayer?.removeFromSuperlayer()
        shapeLayer = CAShapeLayer()
        
        for stroke in strokes {
            let path = UIBezierPath()
            
            path.move(to: CGPoint(x: stroke[0].0, y: stroke[0].1))
            
            for i in 1..<stroke.count {
                path.addLine(to: CGPoint(x: stroke[i].0, y: stroke[i].1))
            }
            
            paths.append(path)
            
        }
        
        let randomStart = Int.random(in: 0..<palette.count)
        for (i, path) in paths.enumerated() {
            let layer = createShapeLayer(path)
            layer.lineWidth = 8
            layer.strokeColor = colorScheme == .dark ? darkPalette[(randomStart + i) % darkPalette.count].cgColor : palette[(randomStart + i) % palette.count].cgColor
//            print(i)
            
            layer.fillColor = UIColor.clear.cgColor
            layer.strokeEnd = 0
            let animDuration = 0.8
            let preDelay = Double(i) * animDuration
            let fullDuration = (Double(paths.count) * animDuration)
            let postDelay: Double = fullDuration - (preDelay + animDuration)
            let anim = createAnimation(duration: animDuration, preDelay: preDelay, postDelay: postDelay)
            layer.add(anim, forKey: nil)
            
            shapeLayer?.addSublayer(layer)
            pathLayers.append(layer)
        }

        layer.addSublayer(shapeLayer!)
    }
}


struct DrawingView: UIViewRepresentable {
    let kanjiPoints: [[(Double, Double)]]
    let colorScheme: ColorScheme
    func updateUIView(_ uiView: UIDrawingView, context: UIViewRepresentableContext<DrawingView>) {
//        print(uiView.frame.size)
        uiView.animateDrawing(strokes: kanjiPoints)
    }
    
    func makeUIView(context: Context) -> UIDrawingView {
        let view = UIDrawingView(frame: .zero, colorScheme: colorScheme)
        view.animateDrawing(strokes: kanjiPoints)
//        print(view.frame.size)
        return view
    }
}

extension CGFloat {
    static func random() -> CGFloat {
        return CGFloat(arc4random()) / CGFloat(UInt32.max)
    }
}
