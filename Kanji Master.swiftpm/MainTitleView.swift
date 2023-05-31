import Foundation
import UIKit
import SwiftUI
import PencilKit

class UIMainTitleView: UIView {
    var shapeLayer: CAShapeLayer?
    var pathLayers: [CAShapeLayer] = []
    var paths: [UIBezierPath] = []
    let colorScheme: ColorScheme
    
    let path = MainTitlePath.fullPath
    
    
    
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
    
    func createAnimation(duration: Double, for keyPath: String) -> CAKeyframeAnimation {
        let animation = CAKeyframeAnimation(keyPath: keyPath)
        animation.duration = duration
        animation.values = [0.0, 1.0]
        animation.timingFunctions = [CAMediaTimingFunction(name: .easeInEaseOut)]
//        animation.repeatCount = .greatestFiniteMagnitude
        animation.fillMode = .forwards
        animation.isRemovedOnCompletion = false
        return animation
    }
    
    
    func animateDrawing() {
        shapeLayer?.removeFromSuperlayer()
        shapeLayer = CAShapeLayer()
        

        shapeLayer = createShapeLayer(path)
        shapeLayer!.lineWidth = 2
        shapeLayer!.strokeColor = (colorScheme == .dark ? UIColor.white.cgColor : UIColor.black.cgColor)
        shapeLayer!.fillColor = UIColor.clear.cgColor
        shapeLayer!.strokeEnd = 0
            
        let anim = createAnimation(duration: 8.0, for: "strokeEnd")
        shapeLayer!.add(anim, forKey: nil)
                            
        layer.addSublayer(shapeLayer!)
    }
}


struct MainTitleView: UIViewRepresentable {
    let colorScheme: ColorScheme
    func updateUIView(_ uiView: UIMainTitleView, context: UIViewRepresentableContext<MainTitleView>) {
        //        print(uiView.frame.size)
        uiView.animateDrawing()
    }
    
    func makeUIView(context: Context) -> UIMainTitleView {
        let view = UIMainTitleView(frame: CGRect(x: 0, y: 0, width: 495, height: 88), colorScheme: colorScheme)
        view.animateDrawing()
        //        print(view.frame.size)
        return view
    }
}

struct MainTitleView_Preview: PreviewProvider {
    static var previews: some View {
        MainTitleView(colorScheme: .dark)
    }
}
