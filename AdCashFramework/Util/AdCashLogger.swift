//
//  AdCashLogger.swift
//  AvatyeAdCash
//
//  Created by 임재혁 on 2023/06/06.
//

import Foundation

@objc
public enum LogLevel: Int, CustomStringConvertible {
    case debug = 1
    case info = 2
    case error = 3
    
    public var description: String{
        switch self {
        case .debug: return "- DEBUG"
        case .info: return "- INFO"
        case .error: return "- ERROR"
        }
    }
}

@objcMembers
public class AdCashLogger {
    static var logLevel: LogLevel = .debug
    
    public static func debug(_ message:String, file: String = #file, line: Int = #line, function: String = #function){
        log(message, level: .debug, file: file, line: line, function: function)
    }
    
    public static func info(_ message:String, file: String = #file, line: Int = #line, function: String = #function){
        log(message, level: .info, file: file, line: line, function: function)
    }
    
    public static func error(_ message:String, file: String = #file, line: Int = #line, function: String = #function){
        log(message, level: .error, file: file, line: line, function: function)
    }
    
    private static func log(_ message: String, level: LogLevel, file: String, line: Int, function: String){
        if level.rawValue >= logLevel.rawValue{
            let fileName = URL(fileURLWithPath: file).lastPathComponent
            print("[AdCash] \(level.description) \(fileName):\(line) \(function) - \(message)")
        }
    }
}