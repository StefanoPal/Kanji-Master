//
//  AboutView.swift
//  Kanji Master
//
//  Created by Stefano on 17/04/23.
//

import SwiftUI

@available(iOS 16.0, *)
struct AboutView: View {
    var geoup: GeometryProxy
    @State private var accuracy = 0.0
    @State private var showStatus = 0
    var body: some View {
        ScrollView {
            VStack(alignment: .center) {
                VStack(alignment: .center) {
                    
                    Text("About")
                        .font(.system(size: 80))
                    Text("\u{2022} Welcome to Kanji Master! Our iPadOS app is designed to help you become an expert in drawing kanji using Apple Pencil. With step-by-step instructions and intuitive guidance, you'll be on your way to mastering the art of kanji in no time.")
                    
                        .padding(.all)
                    
                    Text("\u{2022} But it's more than just a drawing app. As you learn to draw each kanji character, Kanji Master will provide you with a wealth of historical and cultural details about them. As your knowledge grows, so will the complexity of the characters you'll learn to draw.")
                        .padding(.all)
                    
                    Text("\u{2022} What's more, the app uses the accuracy of your drawing as a way to \"gamify\" the experience. After the correct number of strokes has been drawn, the app will automatically judge your drawing, and the better you draw, higher the score for each level will be!")
                        .padding(.all)
                    
                    Text("\u{2022} Whether you're a beginner or just looking to brush up on your kanji skills, Kanji Master is the perfect learning tool. Start your journey today!")
                        .padding(.all)
                    
                    Text("Try it out!")
                    KanjiDrawingView(accuracy: $accuracy, showStatus: $showStatus, geo: geoup, kanjiData: Kanjis.fireKanji)
                        .frame(height: geoup.size.width / 1.8)
                }.frame(width: geoup.size.width / 2)
            }.frame(width: geoup.size.width)
        }.frame(width: geoup.size.width)
    }
}
