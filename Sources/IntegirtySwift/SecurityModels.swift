//
import Foundation

@objc public enum SecurityControlType: Int {
    case jailbreak = 0
    case simulator = 1
    case debugger = 2
    case reverse = 3
}

@objc public class SecurityResult: NSObject {
    @objc public var passed: Bool = true
    @objc public var reason: String = ""
    @objc public var type: SecurityControlType
    
    @objc public init(_ passed: Bool, _ reason: String, _ type: SecurityControlType) {
        self.passed = passed
        self.reason = reason
        self.type = type
    }
}

