//
import Foundation

@objc public class DebuggerDiscoverer: NSObject {

    
    /// Checks if device is set in debug mode.
    /// - Returns: Reuslt object of check.
    @objc public static func amIDebugged() -> SecurityResult {

        var kinfo = kinfo_proc()
        var mib: [Int32] = [CTL_KERN, KERN_PROC, KERN_PROC_PID, getpid()]
        var size = MemoryLayout<kinfo_proc>.stride
        let sysctlRet = sysctl(&mib, UInt32(mib.count), &kinfo, &size, nil, 0)

        if sysctlRet != 0 {
            print("[DEBUGGER] Error occured when calling sysctl(). The debugger check may not be reliable")
        }
        #if RELEASE
        if ((kinfo.kp_proc.p_flag & P_TRACED) != 0) {
            denyDebugger()
            return SecurityResult(true,"[DEBUGGER] Executed in debugged mode", .debugger)
        }
        #endif
        return SecurityResult(false,"[DEBUGGER] Debugger check OK", .debugger)
    }

    
    /// Function for deny debug mode.
    @objc public static func denyDebugger() {

        // bind ptrace()
        let pointerToPtrace = UnsafeMutableRawPointer(bitPattern: -2)
        let ptracePtr = dlsym(pointerToPtrace, "ptrace")
        typealias PtraceType = @convention(c) (CInt, pid_t, CInt, CInt) -> CInt
        let ptrace = unsafeBitCast(ptracePtr, to: PtraceType.self)

        // PT_DENY_ATTACH == 31
        let ptraceRet = ptrace(31, 0, 0, 0)

        if ptraceRet != 0 {
            print("[DEBUGGER] Error occured when calling ptrace(). Denying debugger may not be reliable")
        }
    }

}
