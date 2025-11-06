//
//  Dozing.swift
//  Nemulert
//
//  Created by 藤間里緒香 on 2025/10/18.
//

import Foundation

enum Dozing: String {
    case idle
    case dozing

    var isDozing: Bool {
        switch self {
        case .idle:
            return false
        case .dozing:
            return true
        }
    }
}
