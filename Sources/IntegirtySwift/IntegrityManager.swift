//
import Foundation
import SimplyLogger


/// Class manager of security procedures.
@objc public class IntegrityManager: NSObject {
    @objc public static var isSecure: Bool {
        let header = "******** SECURITY REPORT ******** \n"
        let footerKO = "\\\\\\\\\\WARNING, THE DEVICE IS UNSECURE//////////\n"
        let footerOK = "\\\\\\\\\\THE DEVICE IS SECURE//////////\n"
        if #available(iOS 10.0, *) {
            SimplyLogger.log(str: header, logToSystem: true, category: .info, type: .info, log: .default)
        }
        print(header)
        for result in globalControlsResults {
            if #available(iOS 10.0, *) {
                SimplyLogger.log(str: result.reason, logToSystem: true, category: .info, type: .info, log: .default)
            }
            print((result.reason))
            if result.passed {
                if #available(iOS 10.0, *) {
                    SimplyLogger.log(str: result.reason, logToSystem: true, category: .error, type: .error, log: .default)
                    SimplyLogger.log(str: footerKO, logToSystem: true, category: .warning, type: .info, log: .default)
                }
                print(footerKO)
                return false
            }
        }
        if #available(iOS 10.0, *) {
            SimplyLogger.log(str: footerOK, logToSystem: true, category: .info, type: .info, log: .default)
        }
        print(footerOK)
        return true
    }

    
    /// Static var with all security report results.
    @objc public static var globalControlsResults: [SecurityResult] {
        let globalResults: [SecurityResult] = {
            var results: [SecurityResult] = []
            results.append(contentsOf: JailbreakDiscoverer.jailbreakControlsResults)
            results.append(DebuggerDiscoverer.amIDebugged())
            results.append(contentsOf: ReverseEngineeringDiscoverer.antiReverseControlsResults)
            return results
        }()
        return globalResults
    }
}
