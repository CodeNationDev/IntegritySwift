//
import Foundation


/// Class for discover if app is runing in a simulator.
@objc public class SimulatorDiscoverer: NSObject {
    
    
    /// Boolean variable returns if is a simularor or device.
    /// - Returns: true if is a simulator, false if not.
    @objc public static func isRunningInSimulator() -> Bool {
        return buildTime() || runtime()
    }
    
    private static func runtime() -> Bool {
        if(ProcessInfo().environment["SIMULATOR_DEVICE_NAME"] != nil) {
            print("[SIMULATOR] Simulator found at runtime check")
            return true
        }
        return false
    }
    
    private static func buildTime() -> Bool {
        #if targetEnvironment(simulator)
        print("[SIMULATOR] Simulator found at buildTime")
        return true
        #else
        print("[SIMULATOR] A real device at buildTime was found")
        return false
        #endif
    }
    
}
