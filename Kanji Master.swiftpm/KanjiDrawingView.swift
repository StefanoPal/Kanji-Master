import SwiftUI
import PencilKit
import AVKit




struct KanjiDrawingView: View {
    @State private var canvasView = PKCanvasView()
    @State private var imageFileName = "fire_kanji"
    @State private var localAccuracy = 0.0
    @State private var showWarning = false
    @State private var warningText = ""
    @State private var hasMadeAMistake = false
    @Binding var accuracy: Double
    @Binding var showStatus: Int
    @Environment(\.colorScheme) var colorScheme
    var geo: GeometryProxy
    var kanjiData: KanjiData
    
    func mapPoint(_ point: CGPoint, fromRange: CGRect, toRange: CGRect) -> (Double, Double) {
        let x = (point.x - fromRange.minX) / fromRange.width
        let y = (point.y - fromRange.minY) / fromRange.height
        return (x * toRange.width + toRange.minX, y * toRange.height + toRange.minY)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            CanvasToolbar(accuracy: $localAccuracy, canvasView: $canvasView)
                .frame(width: geo.size.width / 2)
                .background(Color(uiColor: .systemBackground))
            
            if(showWarning) {
                Text(warningText)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.red)
                    .frame(width: geo.size.width / 2)
                    .padding(.top)
            }
            
            ZStack {
                
                CanvasView(canvasView: $canvasView, kanjiData: kanjiData, showStatus: $showStatus, accuracy: $localAccuracy, warningText: $warningText, showWarning: $showWarning)
                    .background(Color(uiColor: .systemBackground))
                
                
                
                if(showStatus < 2 || hasMadeAMistake) {
                    DrawingView(kanjiPoints: kanjiData.kanjiDrawingStrokes.map({ $0.map({
                        mapPoint(CGPoint(x: $0.0, y: $0.1),
                                 fromRange: CGRect(x: 0, y: 0, width: 109, height: 109),
                                 toRange: CGRect(x: 0, y: 0, width: geo.size.width / 2, height: geo.size.width / 2))
                    })
                    }), colorScheme: colorScheme)
                    .id(kanjiData.kanjiFileName)
                    .allowsHitTesting(false)
                    .opacity(0.5)
                    .frame(width: geo.size.width / 2, height: geo.size.width / 2)
                }
                
            } .frame(width: geo.size.width / 2)
                .frame(maxHeight: geo.size.width / 2)
            
        }.animation(.easeInOut, value: showWarning)
            .onChange(of: localAccuracy) { _ in
                if(localAccuracy > 65) {
                    accuracy = localAccuracy
                    hasMadeAMistake = false
                } else {
                    
                    hasMadeAMistake = true
                    
                    warningText = "Be mindful of each stroke order and direction!"
                    showWarning = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 4.0, execute: {
                        self.showWarning = false
                    })
                }
            }.onAppear {
                print(canvasView.visibleSize)
            }
    }
}



struct KanjiDrawingView_Preview: PreviewProvider {
    static var previews: some View {
        KanjiDrawingView_Preview2()
    }
}

struct KanjiDrawingView_Preview2: View {
    
    @State var showStatus = 0
    @State var accuracy = 0.0
    var body: some View {
        GeometryReader { geo in
            ZStack {
                VStack {
                    Spacer()
                    KanjiDrawingView(accuracy: $accuracy, showStatus: $showStatus, geo: geo, kanjiData: KanjiData(kanjiCharacter: "火", kanjiFileName: "fire_kanji"))
                }
            }
        }
    }
}
