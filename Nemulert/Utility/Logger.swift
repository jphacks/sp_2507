//
//  Logger.swift
//  Nemulert
//
//  Created by Kanta Oikawa on 2025/11/02.
//

import Foundation
import os

enum Logger {
    private static let standard = os.Logger(
        subsystem: Bundle.main.bundleIdentifier!,
        category: Category.standard.rawValue.capitalized
    )

    enum Category: String {
        case standard
    }

    enum Level: Int {
        case debug
        case info
        case warning
        case error

        var label: String {
            switch self {
            case .debug:
                return "􀀀 [DEBUG]"
            case .info:
                return "􀁞 [INFO]"
            case .warning:
                return "􀇾 [WARNING]"
            case .error:
                return "􀒉 [ERROR]"
            }
        }
    }

    static func debug(_ items: Any..., file: String = #file, line: UInt = #line, function: String = #function) {
        printItems(items, file: file, line: line, function: function, level: .debug)
    }

    static func info(_ items: Any..., file: String = #file, line: UInt = #line, function: String = #function) {
        printItems(items, file: file, line: line, function: function, level: .info)
    }

    static func warn(_ items: Any..., file: String = #file, line: UInt = #line, function: String = #function) {
        printItems(items, file: file, line: line, function: function, level: .warning)
    }

    static func error(_ error: any Error, file: String = #file, line: UInt = #line, function: String = #function) {
        printItems(error, file: file, line: line, function: function, level: .error)
    }

    static func error(_ texts: String..., file: String = #file, line: UInt = #line, function: String = #function) {
        printItems(texts, file: file, line: line, function: function, level: .error)
    }

    private static func printItems(_ items: Any..., file: String, line: UInt, function: String, level: Level) {
        let thread = Thread.isMainThread ? "􀋽" : "􀋾"
        let location = "\(URL(filePath: file).lastPathComponent):\(line) \(function)"
        let date = Date().formatted(.iso8601)
        let itemsText = items.map { "\($0)" }.joined(separator: " ")
        let text = "\(level.label) \(thread) [\(date)] \(location) \(itemsText)"
        switch level {
        case .debug:
            standard.debug("\(text)")
        case .info:
            standard.info("\(text)")
        case .warning:
            standard.warning("\(text)")
        case .error:
            standard.error("\(text)")
        }
    }
}
