//
//  Dozing.swift
//  Nemulert
//
//  Created by 藤間里緒香 on 2025/10/18.
//

import Foundation

enum Dozing: String {
    case idle
    case dozingFront = "dozing_front"
    case dozingBack = "dozing_back"
    case dozingLeft = "dozing_left"
    case dozingRight = "dozing_right"

    var isDozing: Bool {
        switch self {
        case .idle:
            return false
        case .dozingFront, .dozingBack, .dozingLeft, .dozingRight:
            return true
        }
    }
}
