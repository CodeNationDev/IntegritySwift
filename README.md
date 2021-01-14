# IntegrityManagerSwift
> An unified product for check many topics about integrity & security.

## Installation

[Add the Swift Package to your project from url: https://github.com/CodeNationDev/IntegritySwift.git

## Definition & Interface
This product has been developd as class type with @objc flags for allow the usage from swift and ObjC.

```swift
@objc public static var isSecure: Bool
```
When you request the value of this variable, the result (true/false) is generated besed on all security checks passed in that moment.

```swift
@objc public static var globalControlsResults: [SecurityResult]
```
This object return an array with the object (defined at models file) that contains the results of all checks evaluated, and it have following structure:

```swift
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
```

Also, you can request the state of any individual check of all available. 

#### Jailbreak

Global Jailbreak passchecks
```swift
@objc public static var isDeviceJailbroken: Bool
```

The object array with check results.
```swift
@objc public static var jailbreakControlsResults: [SecurityResult]
```

Sandbox violation passcheck. Check existence of files that are common for jailbroken devices
```swift
@objc public static func jailbreakSuspiciousFilesCheck() -> SecurityResult
```

If we can execute a Cyda urlScheme, the device is jailbroken
```swift
@objc public static func jailbreakUrlSchemes() -> SecurityResult
```

This check looks for the exist of suspicious dylibs.
```swift
@objc public static func jailbreakDYLD() -> SecurityResult
```

This check detects a forked proccess.
```swift
public static func jailbreakFork() -> SecurityResult
```

#### Debugger state

Global Debugger state passchecks
```swift
@objc public static func amIDebugged() -> SecurityResult
```

Function for deny debug mode
```swift
@objc public static func denyDebugger()
```

#### Reverse Engineering

Global checks for Reverse Engineering
```swift
@objc public static func amIReverseEngineered() -> Bool
```

The object array with check results. 
```swift
public static var antiReverseControlsResults: [SecurityResult]
```

Checks for suspicious libraries.
```swift
public static func checkDYLD() -> SecurityResult
```

Check suspicious files
```swift
public static func checkExistenceOfSuspiciousFiles() -> SecurityResult 
```

Check opened ports
```swift
public static func checkOpenedPorts() -> SecurityResult 
```

Check if we can open a local connection in a specific port.
```swift
public static func canOpenLocalConnection(port: Int) -> SecurityResult
```

#### Simulator

Global check for simulatoir discoverer.

```swift
@objc public static func isRunningInSimulator() -> Bool
```




## Usage example

Simply get the isSecure value:

#### Swift
```swift
//
import UIKit
import IntegirtySwift

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        if !IntegrityManager.isSecure {
            //do something if device device is not secure.
        }
        
        if !JailbreakDiscoverer.isDeviceJailbroken {
            //do something if device jailbroken
        }
        
        if DebuggerDiscoverer.amIDebugged().passed {
            //do something if the device is a simulator
        }
        
        return true
    }

```

#### Objetive-C
```objective-c
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
if (!SecurityManager.isSecure) {
      //do something if device is not secure.
    }
}
```

## Meta

David Martin Saiz – [@deividmarshall](https://twitter.com/deividmarshall) – davms81@gmail.com

Distributed under the MIT license. See ``LICENSE`` for more information.

[https://github.com/CodeNationDev/](https://github.com/CodeNationDev)

## Version History
* 0.0.1
    * First implementation with main features.
