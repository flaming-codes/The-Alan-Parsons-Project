//
// Obtained from:
// https://github.com/JungleCandy/LoggingPrint

import Foundation

public func track<T>(_ type: LogType,_ message: String?,_ object: @autoclosure () -> T,_ file: String = #file, _ function: String = #function, _ line: Int = #line) {
    #if DEBUG
        if type == .E || type == .F { print("\n") }
        print("\(type.rawValue) @ \(type(of: object())) : \(function)[\(line)]: \(message ?? "Function called.").")
        if type == .E || type == .F { print("\n") }
    #endif
}
