//
//  PracticeKanjiUIView.swift
//  Test 1
//
//  Created by Stefano on 11/04/23.
//

import SwiftUI

struct PracticeKanjiUIView: View {
    @State var currentIndex = 0
    @State var showStatus = 0
    
    let data: [(KanjiData, [String])]
    @Binding var didStartPractice: Bool
    let levelType: LevelType
    
    @State var accuracy: Double = 0.0

    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                KanjiDetailsView(geo: geo, title: data[currentIndex].1[0], firstPoint: data[currentIndex].1[1], secondPoint: data[currentIndex].1[2], thirdPoint: data[currentIndex].1[3], pageLimit: data.count - 1, showStatus: $showStatus, currentPage: $currentIndex, didStartPractice: _didStartPractice)
                    .transition(.slide)
                    .id(currentIndex)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                
                VStack {
                    Spacer()
                    HStack {
                        
                        Spacer()
                        KanjiDrawingView(accuracy: $accuracy, showStatus: $showStatus, geo: geo, kanjiData: data[currentIndex].0)
                            .padding(.all)
                            .id(data[currentIndex].0.kanjiFileName)
                    }
                }
            }.animation(.easeInOut(duration: 0.5), value: currentIndex)
        }.onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("newAccuracy"))) { userInfo in
            
            let newAccuracy = userInfo.userInfo!["accuracy"] as! Double
            let kanjiCharacter = userInfo.userInfo!["kanjiCharacter"] as! String
            let attempt = userInfo.userInfo!["attempt"] as! Int
            var temp = UserDefaults.standard.array(forKey: "accuracyValues") as! [[String: [Double]]]
            
            temp[levelType.rawValue][kanjiCharacter]![attempt] = newAccuracy
            print(temp)
            UserDefaults.standard.set(temp, forKey: "accuracyValues")
        }
    }
}

struct PracticeKanjiUIView_Previews: PreviewProvider {
    static var previews: some View {
        PracticeKanjiUIView_Previews2()
    }
}

struct PracticeKanjiUIView_Previews2: View {
    @State var didStartPractice = false
    var body: some View {
        PracticeKanjiUIView(data: KanjiLevelData.getLevelData(level: .daysLevel), didStartPractice: $didStartPractice, levelType: .daysLevel)
    }
}
