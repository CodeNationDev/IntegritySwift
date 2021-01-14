//
import Foundation
import MachO
@objc public class ReverseEngineeringDiscoverer: NSObject {

    
    /// Boolean variable returns if any reverse engineering is using in the device
    /// - Returns: true if any reverse action is detected, false if not.
   @objc public static func amIReverseEngineered() -> Bool {
        return (checkDYLD().passed || checkExistenceOfSuspiciousFiles().passed || checkOpenedPorts().passed)
    }
    
    
    /// Static variable with results of reverse report.
    public static var antiReverseControlsResults: [SecurityResult] {
         let antireverseresults: [SecurityResult] = {
                   var results: [SecurityResult] = []
                   results.append(checkDYLD())
                   results.append(checkOpenedPorts())
                   results.append(checkExistenceOfSuspiciousFiles())
                   return results
               }()
               return antireverseresults
    }
    
    
    /// Checks for suspicious library of usual jailbreaks methods.
    /// - Returns: Reuslt object of check.
    public static func checkDYLD() -> SecurityResult {

        let suspiciousLibraries = [
            "FridaGadget",
            "frida", // Needle frida-somerandom.dylib injection
            "cynject",
            "libcycript"
        ]

        for libraryIndex in 0..<_dyld_image_count() {

            // _dyld_get_image_name returns const char * that needs to be casted to Swift String
            guard let loadedLibrary = String(validatingUTF8: _dyld_get_image_name(libraryIndex)) else { continue }

            for suspiciousLibrary in suspiciousLibraries {
                if loadedLibrary.lowercased().contains(suspiciousLibrary.lowercased()) {
                    return SecurityResult(true, "Suspicious libraries was found.", .reverse)
                }
            }
        }

        return  SecurityResult(false, "Reverse Engineering check OK", .reverse)
    }

    
    /// Check suspicious files related with any jailbreak method.
    /// - Returns: Reuslt object of check.
    public static func checkExistenceOfSuspiciousFiles() -> SecurityResult {

        let paths = [
            "/usr/sbin/frida-server"
        ]

        for path in paths {
            if FileManager.default.fileExists(atPath: path) {
                return SecurityResult(true,"Suspicious files was found", .reverse)
            }
        }

        return SecurityResult(false, "Suspicious Files check OK", .reverse)
    }

    
    /// Checks if can open injection ports.
    /// - Returns: Reuslt object of check.
    public static func checkOpenedPorts() -> SecurityResult {

        let ports = [
            27042, // Frida port
            4444, // Needle port
            22 // OpenSSH
        ]

        for port in ports {

            if canOpenLocalConnection(port: port).passed &&
                !SimulatorDiscoverer.isRunningInSimulator() &&
                !DebuggerDiscoverer.amIDebugged().passed {
                return SecurityResult(true,"Port \(port) can be opnend", .reverse)
            }
        }

        return SecurityResult(false, "Port check OK", .reverse)
    }
    
    
    /// Bussines code for open port check.
    /// - Parameter port: Port number as Integer.
    /// - Returns: Reuslt object of check.
    public static func canOpenLocalConnection(port: Int) -> SecurityResult {

        func swapBytesIfNeeded(port: in_port_t) -> in_port_t {
            let littleEndian = Int(OSHostByteOrder()) == OSLittleEndian
            return littleEndian ? _OSSwapInt16(port) : port
        }

        var serverAddress = sockaddr_in()
        serverAddress.sin_family = sa_family_t(AF_INET)
        serverAddress.sin_addr.s_addr = inet_addr("127.0.0.1")
        serverAddress.sin_port = swapBytesIfNeeded(port: in_port_t(port))
        let sock = socket(AF_INET, SOCK_STREAM, 0)

        let result = withUnsafePointer(to: &serverAddress) {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {
                connect(sock, $0, socklen_t(MemoryLayout<sockaddr_in>.stride))
            }
        }

        if result != -1 {
            return SecurityResult(true, "Port is opened in local connection check.", .reverse)
        }

        return SecurityResult(false,"Local Connection check OK", .reverse)
    }
}
