import SwiftUI

@available(iOS 16.0, *)
@main
struct MyApp: App {

    @State var hasGameStarted = false
    var body: some Scene {
        WindowGroup {
            GeometryReader { geo in
                if(hasGameStarted) {
                    MainMenuView(sceneName: "MainMenuMap.sks")
                        .transition(.slide)
                } else {
                    InitialView(hasGameStarted: $hasGameStarted)
                }
            }.animation(.easeOut, value: hasGameStarted)
            .onAppear {
                #if !targetEnvironment(simulator)
                let fontURL = Bundle.main.url(forResource: "SFProDisplay-Light", withExtension: "otf")! as CFURL

                CTFontManagerRegisterFontsForURL(fontURL, CTFontManagerScope.process, nil)
 
                if(UserDefaults.standard.array(forKey: "accuracyValues") == nil) {
                    var temp: [[String: [Double]]] = []
                    for elem in LevelType.allCases {
                        temp.append([:])
                        let levelData = KanjiLevelData.getLevelData(level: elem)
                        for i in 0..<levelData.count {
                            temp[temp.count - 1][levelData[i].0.kanjiCharacter] = Array(repeating: Double.zero, count: 3)
                        }

                    }
                    UserDefaults.standard.setValue(temp, forKey: "accuracyValues")
                    print(temp)
                }

                #endif
            }
        }
    }
}
