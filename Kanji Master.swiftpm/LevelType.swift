//
//  LevelType.swift
//  Kanji Master
//
//  Created by Stefano on 17/04/23.
//

import Foundation


enum LevelType: Int, CaseIterable {
    case daysLevel
    case numbersLevel
    case colorsLevel
    
    func toString() -> String {
        switch(self) {
            
        case .daysLevel:
            return "daysLevel"
        case .numbersLevel:
            return "numbersLevel"
        case .colorsLevel:
            return "colorsLevel"
        }
    }
}
