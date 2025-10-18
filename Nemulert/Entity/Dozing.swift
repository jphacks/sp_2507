//
//  Dozing.swift
//  Nemulert
//
//  Created by 藤間里緒香 on 2025/10/18.
//

import Foundation

enum Dozing: String {
    case idle
    case dozingFront
    case dozingBack
    case dozingLeft
    case dozingRight

    var label: String {
        rawValue.capitalized
    }
}
