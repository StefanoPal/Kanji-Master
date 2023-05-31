//
//  KanjiPoints.swift
//  Test 1
//
//  Created by Stefano on 06/04/23.
//

import Foundation

typealias Point = [String: Double]
typealias Stroke = [Point]
typealias Drawing = [Stroke]
typealias PointDatabase = [String: Drawing]

public struct KanjiPoints {
    static func getKanjiPoints(of kanjiCharacter: String) -> [[(Double, Double)]] {
        
        var temp: [[(Double, Double)]] = []
        
        // Get the URL for the property list file in your app's main bundle
        guard let plistURL = Bundle.main.url(forResource: "kanjiPoints", withExtension: "plist") else {
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
        let fullListOfPoints = plistDict as! PointDatabase
        for stroke in fullListOfPoints[kanjiCharacter]! {
            temp.append([])
            for point in stroke {
                temp[temp.count - 1].append((point["x"]!, point["y"]!))
            }
        }
        return temp
    }
}


