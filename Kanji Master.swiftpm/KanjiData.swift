//
//  KanjiData.swift
//  Test 1
//
//  Created by Stefano on 11/04/23.
//

import Foundation

struct KanjiData {
    var kanjiCharacter: String
    var kanjiFileName: String
    var kanjiDrawingStrokes: [[(Double, Double)]] {
        KanjiPoints.getKanjiPoints(of: kanjiCharacter)
    }
}
