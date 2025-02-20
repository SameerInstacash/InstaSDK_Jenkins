//
//  AppDelegate.swift
//  InstaCashSDK
//
//  Created by Sameer Khan on 28/07/24.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    var orientationLock = UIInterfaceOrientationMask.portrait
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        //registerforDeviceLockNotification()                
        
        return true
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        
        /*
        let sbs = dlopen("/System/Library/PrivateFrameworks/SpringBoardServices.framework/SpringBoardServices", RTLD_LAZY)
        defer {
            dlclose(sbs)
        }

        let symbol1 = dlsym(sbs, "SBSSpringBoardServerPort")
        let SBSSpringBoardServerPort = unsafeBitCast(symbol1, to: (@convention(c) () -> mach_port_t).self)

        let symbol2 = dlsym(sbs, "SBGetScreenLockStatus")
        var lockStatus: ObjCBool = false
        var passcodeEnabled: ObjCBool = false
        let SBGetScreenLockStatus = unsafeBitCast(symbol2, to: (@convention(c) (mach_port_t, UnsafeMutablePointer<ObjCBool>, UnsafeMutablePointer<ObjCBool>) -> Void).self)

        SBGetScreenLockStatus(SBSSpringBoardServerPort(), &lockStatus, &passcodeEnabled)
        print("lockStatus",lockStatus)
        print("passcodeEnabled",passcodeEnabled)
        */
        
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        
        //guard let bleState = checkBluetoothState else { return }
        //bleState()
        
        if let bleState = checkBluetoothState {
            bleState()
        }
        
        if let lctnState = checkLocationState {
            lctnState()
        }
        
        if let powerBtn = checkPowerBtnState {
            powerBtn()
        }
        
    }
    
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        return self.orientationLock
    }
    
    // MARK: UISceneSession Lifecycle
    /*
     func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
     // Called when a new scene session is being created.
     // Use this method to select a configuration to create the new scene with.
     return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
     }
     
     func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
     // Called when the user discards a scene session.
     // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
     // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
     }
     */
    
    
    /* //MARK: Comment due to Apple's rejection
    func registerforDeviceLockNotification() {
        //Screen lock notifications
        CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(),     //center
                                        Unmanaged.passUnretained(self).toOpaque(),     // observer
                                        displayStatusChangedCallback,     // callback
                                        "com.apple.springboard.lockcomplete" as CFString,     // event name
                                        nil,     // object
                                        .deliverImmediately)
        
    }
    
    private let displayStatusChangedCallback: CFNotificationCallback = { _, cfObserver, cfName, _, _ in
        guard let lockState = cfName?.rawValue as String? else {return}
        
        if (lockState == "com.apple.springboard.lockcomplete") {
            print("DEVICE LOCKED")
        } else {
            print("LOCK STATUS CHANGED")
        }
        
    }
    */
    
}


