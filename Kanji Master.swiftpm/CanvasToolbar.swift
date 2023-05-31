//
//  CanvasToolbar.swift
//  Kanji Master
//
//  Created by Stefano on 17/04/23.
//

import Foundation
import SwiftUI
import PencilKit


struct CanvasToolbar: View {
    @Binding var accuracy: Double
    @Binding var canvasView: PKCanvasView
    var body: some View {
        HStack {
            Spacer()
            
            if(accuracy != 0) {
                Text("\(Int(accuracy))% Accurate!")
                    .padding(.all)
                    .font(.system(size: 30))
                    .tint(.orange)
            }
            
            Spacer()
            Button(action: {
                canvasView.drawing.strokes = []
            }, label: {
                Image(systemName: "trash.fill")
            }).buttonStyle(.borderedProminent)
        }.background(Color(uiColor: .systemBackground))

    }
}
