//
import Foundation
import Darwin
import MachO
import UIKit

/// Class that provide a catalog of checks for discover jailbreak.
@objc public class JailbreakDiscoverer: NSObject {
    @objc public static var isDeviceJailbroken: Bool {
        for result in JailbreakDiscoverer.jailbreakControlsResults {
            if result.passed {
                return true
            }
        }
        return false
    }
    
    @objc internal static var jailbreakControlsResults: [SecurityResult] {
        let jailresults: [SecurityResult] = {
            var results: [SecurityResult] = []
            results.append(JailbreakDiscoverer.jailbreakSandboxViolation())
            results.append(JailbreakDiscoverer.jailbreakSuspiciousFilesCheck())
            results.append(JailbreakDiscoverer.jailbreakDYLD())
            results.append(JailbreakDiscoverer.jailbreakFork())
            results.append(JailbreakDiscoverer.jailbreakSymbolicLinks())
            return results
        }()
        return jailresults
    }
    
    /// Reading and writing in system directories (sandbox violation)
    /// - Returns: Bool: true if we can write, the device is jailbroken.
    @objc public static func jailbreakSandboxViolation() -> SecurityResult {
        let stringToWrite = "Jailbreak Test"
        do {
            try stringToWrite.write(toFile:"/private/JailbreakTest.txt", atomically:true, encoding:String.Encoding.utf8)
            // Device is jailbroken
            return SecurityResult(true, "[JAILBREAK] File write check KO, the device is jailbroken and Sandbox violated.", .jailbreak)
        } catch {
            return SecurityResult(false, "[JAILBREAK] File written check OK", .jailbreak)
        }
    }
    
    /// Check existence of files that are common for jailbroken devices
    /// - Returns: Bool: true if any path exists. The device is jailbroken.
    @objc public static func jailbreakSuspiciousFilesCheck() -> SecurityResult {
        guard TARGET_IPHONE_SIMULATOR != 1 else { return SecurityResult(false,"[JAILBREAK] It's a Simulator, not a device", .jailbreak) }
        
        let paths = [
            "/usr/sbin/frida-server", // frida
            "/etc/apt/sources.list.d/electra.list", // electra
            "/etc/apt/sources.list.d/sileo.sources", // electra
            "/.bootstrapped_electra", // electra
            "/usr/lib/libjailbreak.dylib", // electra
            "/jb/lzma", // electra
            "/.cydia_no_stash", // unc0ver
            "/.installed_unc0ver", // unc0ver
            "/jb/offsets.plist", // unc0ver
            "/usr/share/jailbreak/injectme.plist", // unc0ver
            "/etc/apt/undecimus/undecimus.list", // unc0ver
            "/var/lib/dpkg/info/mobilesubstrate.md5sums", // unc0ver
            "/Library/MobileSubstrate/MobileSubstrate.dylib",
            "/jb/jailbreakd.plist", // unc0ver
            "/jb/amfid_payload.dylib", // unc0ver
            "/jb/libjailbreak.dylib", // unc0ver
            "/usr/libexec/cydia/firmware.sh",
            "/Applications/Cydia.app",
            "/Applications/FakeCarrier.app",
            "/Applications/Icy.app",
            "/Applications/IntelliScreen.app",
            "/Applications/MxTube.app",
            "/Applications/RockApp.app",
            "/Applications/SBSettings.app",
            "/Applications/WinterBoard.app",
            "/Applications/blackra1n.app",
            "/Library/MobileSubstrate/DynamicLibraries/LiveClock.plist",
            "/Library/MobileSubstrate/DynamicLibraries/Veency.plist",
            "/Library/MobileSubstrate/MobileSubstrate.dylib",
            "/Library/MobileSubstrate/CydiaSubstrate.dylib",
            "/System/Library/LaunchDaemons/com.ikey.bbot.plist",
            "/System/Library/LaunchDaemons/com.saurik.Cydia.Startup.plist",
            "/bin/bash",
            "/bin/sh",
            "/etc/apt",
            "/etc/ssh/sshd_config",
            "/var/log/apt",
            "/private/var/lib/apt/",
            "/private/var/lib/cydia",
            "/private/var/Users/",
            "/private/var/lib/apt",
            "/private/var/mobile/Library/SBSettings/Themes",
            "/private/var/stash",
            "/private/var/tmp/cydia.log",
            "/private/var/cache/apt/",
            "/private/var/log/syslog",
            "/var/tmp/cydia.log",
            "/usr/bin/sshd",
            "/usr/libexec/sftp-server",
            "/usr/libexec/ssh-keysign",
            "/usr/sbin/sshd",
            "/var/cache/apt",
            "/var/lib/apt",
            "/var/lib/cydia",
            "/usr/sbin/frida-server",
            "/usr/bin/cycript",
            "/usr/local/bin/cycript",
            "/usr/lib/libcycript.dylib",
            "/var/log/syslog",
        ]
        
        for path in paths {
            if FileManager.default.fileExists(atPath: path) {
                
                return SecurityResult(true,"[JAILBREAK] jailbreak suspicius files was found", .jailbreak)
            }
        }
        return SecurityResult(false,"[JAILBREAK] jailbreak suspicius files check OK", .jailbreak)
    }
    
    /// If we can execute a Cyda urlScheme, the device is jailbroken
    /// - Returns: Bool: true if we are allowed for open Cyda URL
    @objc public static func jailbreakUrlSchemes() -> SecurityResult {
        let urlSchemes = [
            "undecimus://",
            "cydia://",
            "sileo://",
            "zbra://"
        ]
        
        for scheme in urlSchemes {
            if (UIApplication.shared.canOpenURL(URL(string: scheme)!)) {
                return SecurityResult(true,"[JAILBREAK] URL Schemes check enconuntered a jailbreak evidences: \(scheme)", .jailbreak)
            }
        }
        return SecurityResult(false,"[JAILBREAK] URL Schemes check OK", .jailbreak)
    }
    
    private static func jailbreakFork() -> SecurityResult {
        
        let pointerToFork = UnsafeMutableRawPointer(bitPattern: -2)
        let forkPtr = dlsym(pointerToFork, "fork")
        typealias ForkType = @convention(c) () -> pid_t
        let fork = unsafeBitCast(forkPtr, to: ForkType.self)
        let forkResult = fork()
        
        if forkResult >= 0 {
            if forkResult > 0 {
                kill(forkResult, SIGTERM)
            }
            if(!SimulatorDiscoverer.isRunningInSimulator()) {
                return SecurityResult(true,"[JAILBREAK] Fork was able to create a new process (sandbox violation)", .jailbreak)
            }
        }
        
        return SecurityResult(false,"[JAILBREAK] Fork check OK", .jailbreak)
    }
    
    @objc public static func jailbreakDYLD() -> SecurityResult {
        
        let suspiciousLibraries = [
            "SubstrateLoader.dylib",
            "SSLKillSwitch2.dylib",
            "SSLKillSwitch.dylib",
            "MobileSubstrate.dylib",
            "TweakInject.dylib",
            "CydiaSubstrate",
            "cynject",
            "CustomWidgetIcons",
            "PreferenceLoader",
            "RocketBootstrap",
            "WeeLoader",
            "/.file" // HideJB (2.1.1) changes full paths of the suspicious libraries to "/.file"
        ]
        
        for libraryIndex in 0..<_dyld_image_count() {
            
            // _dyld_get_image_name returns const char * that needs to be casted to Swift String
            guard let loadedLibrary = String(validatingUTF8: _dyld_get_image_name(libraryIndex)) else { continue }
            
            for suspiciousLibrary in suspiciousLibraries {
                if loadedLibrary.lowercased().contains(suspiciousLibrary.lowercased()) {
                    return SecurityResult(true,"[JAILBREAK] Suspicious library loaded: \(loadedLibrary)", .jailbreak)
                }
            }
        }
        return SecurityResult(false,"[JAILBREAK] Suspcious library check OK", .jailbreak)
    }
    
    private static func jailbreakSymbolicLinks() -> SecurityResult {
        
        let paths = [
            "/var/lib/undecimus/apt", // unc0ver
            "/Applications",
            "/Library/Ringtones",
            "/Library/Wallpaper",
            "/usr/arm-apple-darwin9",
            "/usr/include",
            "/usr/libexec",
            "/usr/share"
        ]
        
        for path in paths {
            do {
                let result = try FileManager.default.destinationOfSymbolicLink(atPath: path)
                if !result.isEmpty {
                    return SecurityResult(true,"[JAILBREAK] Some symbolic link detected: \(path) points to \(result). The device is jailbroken", .jailbreak)
                }
            } catch let error {
                print("[JAILBREAK] \(error.localizedDescription)")
            }
        }
        
        return SecurityResult(false, "[JAILBREAK] Symbolic links check OK", .jailbreak)
    }
}


