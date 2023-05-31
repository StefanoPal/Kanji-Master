//
//  KanjiDetailsView.swift
//  Test 1
//
//  Created by Stefano on 12/04/23.
//

import SwiftUI

struct KanjiDetailsView: View {
    let geo: GeometryProxy
    let title: String
    let firstPoint: String
    let secondPoint: String
    let thirdPoint: String
    let pageLimit: Int
    @Binding var showStatus: Int
    @Binding var currentPage: Int
    @Binding var didStartPractice: Bool
    var body: some View {
        VStack {
            Text(title)
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.all)
                .font(.system(size: 60, weight: .bold))
            HStack {
                VStack {
                    Spacer()
                    if(showStatus > 0) {
                        Text("\u{2022} " + firstPoint)
                            .transition(.asymmetric(insertion: .slide, removal: .opacity))
                        Spacer()
                    }
                    if(showStatus > 1) {
                        Text("\u{2022} " + secondPoint)
                            .transition(.asymmetric(insertion: .slide, removal: .opacity))
                        Spacer()
                    }
                    if(showStatus > 2) {
                        Text("\u{2022} " + thirdPoint)
                            .transition(.asymmetric(insertion: .slide, removal: .opacity))
                        Spacer()
                        Button(action: {
                            if(currentPage < pageLimit) {
                                currentPage += 1
                                showStatus = 0
                            } else {
                                currentPage = 0
                                showStatus = 0
                                didStartPractice = false
                            }
                        }, label: {
                            Label("Next Page", systemImage: "arrow.right")
                                .font(.system(size: 30))
                        }).padding(.bottom)
                            .buttonStyle(.borderedProminent)
                            .tint(.orange)
                        Spacer()
                    }
                }
                .frame(maxWidth: geo.size.width / 2.5)
                .padding(.leading)
                .animation(.easeOut(duration: 0.2), value: showStatus)
                Spacer()
            }.frame(maxWidth: .infinity)
        }.frame(alignment: .leading)
            .background(Color(uiColor: .systemBackground))
        
    }
}

struct KanjiDetailsView_Previews: PreviewProvider {
    static var previews: some View {
        KanjiDetailsView_2_Previews()
    }
}

struct KanjiDetailsView_2_Previews : View {
    @State var showStatus = 0
    @State var currentPage = 0
    @State var didStartPractice = false
    var body: some View {
        GeometryReader { geo in
            KanjiDetailsView(geo: geo, title: "Fire Kanji (火)", firstPoint: "火 (hi or ka in Japanese) is the kanji character for \"fire\" and is composed of three horizontal strokes, with the top and bottom strokes being longer than the middle one.", secondPoint: "The origin of the 火 character can be traced back to ancient Chinese pictograms, where it originally represented a drawing of flames or burning wood. Over time, the character evolved into its current form and became a symbol for the element of fire.", thirdPoint: "In Japanese culture, the character 火 is used in various idiomatic expressions, such as \"burning with enthusiasm\" or \"set the world on fire\" to convey a sense of energy and excitement.",  pageLimit: 5, showStatus: $showStatus, currentPage: $currentPage, didStartPractice: $didStartPractice)
            Button("Increase") {
                showStatus += 1
                print(showStatus)
            }
        }
    }
}
