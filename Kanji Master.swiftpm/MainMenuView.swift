//
//  MainMenuView.swift
//  Test 1
//
//  Created by Stefano on 11/04/23.
//

import Foundation
import SwiftUI
import SpriteKit

struct MainMenuView: View {
    var sceneName: String = "MainMenuMap.sks"
    @State var didStartPractice = false
    @State var levelType: LevelType = .numbersLevel
    
    var scene: SKScene {
       // let temp = SKScene(fileNamed: sceneName)!
        let temp = MainMenuMap(fileNamed: sceneName)!
        temp.scaleMode = .aspectFill
        temp.camera?.position.x = 0
        return temp
    }
    
    var body: some View {
        ZStack {
            SpriteView(scene: scene)
                .edgesIgnoringSafeArea(.all)
                .zIndex(1)
            
            if(didStartPractice) {
                PracticeKanjiUIView(data: KanjiLevelData.getLevelData(level: levelType), didStartPractice: $didStartPractice, levelType: levelType)
                    .background(Color(uiColor: .white))
                    .transition(.slide)
                    .zIndex(2)
            }
            
        }.onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("startPractice"))) { levelType in
            self.levelType = levelType.userInfo!["levelType"] as! LevelType
            didStartPractice = true
        }.animation(.easeOut, value: didStartPractice)
    }
}

struct MainMenuView_Previews: PreviewProvider {
    
    static var previews: some View {
        MainMenuView(sceneName: "MainMenuMap")
    }
}
