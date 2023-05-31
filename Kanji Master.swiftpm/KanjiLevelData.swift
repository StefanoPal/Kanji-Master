//
//  KanjiLevelData.swift
//  Test 1
//
//  Created by Stefano on 12/04/23.
//

import Foundation

class KanjiLevelData {

    static private func getKanjiDataAndDescription(of level: LevelType) -> [(KanjiData, [String])] {
        
        var temp: [(KanjiData, [String])] = []
        
        // Get the URL for the property list file in your app's main bundle
        guard let plistURL = Bundle.main.url(forResource: "KanjiDescriptions", withExtension: "plist") else {
            fatalError("Error: Could not find KanjiDescriptions.plist in main bundle")
        }

        // Load the contents of the property list file into a Data object
        guard let plistData = try? Data(contentsOf: plistURL) else {
            fatalError("Error: Could not load contents of MyPropertyList.plist")
        }

        // Deserialize the property list data into a dictionary
        var plistDict: [String: Any] = [:]
        do {
            plistDict = try PropertyListSerialization.propertyList(from: plistData, options: [], format: nil) as! [String: Any]
        } catch {
            print("Error deserializing property list: \(error)")
        }

        // Access the values in the dictionary
        let daysLevel = plistDict[level.toString()] as! [String: [String]]
        for element in daysLevel {
            temp.append((mapKanjiData(of: element.key), element.value))
        }
//        print(temp)
        return temp
    }
    
    private static func mapKanjiData(of string: String) -> KanjiData {
        
        switch(string) {
            
        case "fireKanjiDescription":
            return Kanjis.fireKanji
            
        case "moonKanjiDescription":
            return Kanjis.moonKanji
            
        case "sunKanjiDescription":
            return Kanjis.sunKanji
            
        case "dirtKanjiDescription":
            return Kanjis.dirtKanji
            
        case "goldKanjiDescription":
            return Kanjis.goldKanji
            
        case "waterKanjiDescription":
            return Kanjis.waterKanji
            
        case "treeKanjiDescription":
            return Kanjis.treeKanji
            
        case "oneKanjiDescription":
            return Kanjis.oneKanji
            
        case "twoKanjiDescription":
            return Kanjis.twoKanji
            
        case "threeKanjiDescription":
            return Kanjis.threeKanji
            
        case "fourKanjiDescription":
            return Kanjis.fourKanji
            
        case "fiveKanjiDescription":
            return Kanjis.fiveKanji
            
        case "sixKanjiDescription":
            return Kanjis.sixKanji
            
        case "sevenKanjiDescription":
            return Kanjis.sevenKanji
            
        case "eightKanjiDescription":
            return Kanjis.eightKanji
            
        case "nineKanjiDescription":
            return Kanjis.nineKanji
            
        case "tenKanjiDescription":
            return Kanjis.tenKanji
            
        case "redKanjiDescription":
            return Kanjis.redKanji
            
        case "blueKanjiDescription":
            return Kanjis.blueKanji
            
        case "whiteKanjiDescription":
            return Kanjis.whiteKanji
            
        case "blackKanjiDescription":
            return Kanjis.blackKanji
            
        case "greenKanjiDescription":
            return Kanjis.greenKanji
            
        case "goldenKanjiDescription":
            return Kanjis.goldenKanji
            
        case "vermilionKanjiDescription":
            return Kanjis.vermilionKanji
            
        case "rainbowKanjiDescription":
            return Kanjis.rainbowKanji
            
        default:
            fatalError("No key exists with such string")
        }
    }
    
    static func getLevelData(level: LevelType) -> [(KanjiData, [String])] {
        return getKanjiDataAndDescription(of: level)
    }
}
