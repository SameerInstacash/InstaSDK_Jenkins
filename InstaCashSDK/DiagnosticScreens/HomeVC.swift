//
//  HomeVC.swift
//  InstaCashSDK
//
//  Created by Sameer Khan on 28/07/24.
//

import Foundation
import UIKit
import SwiftyJSON
import CoreBluetooth
import JGProgressHUD

import CoreBluetooth
import Luminous
import INTULocationManager
import CoreLocation
import CoreTelephony
import CoreMotion
import AudioToolbox

import DeviceCheck
import os
import MachO

class HomeVC: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, CBCentralManagerDelegate {
    
    @IBOutlet weak var testCollectionView: UICollectionView!
    @IBOutlet weak var startTestBtn: UIButton!
    @IBOutlet weak var quiteAppBtn: UIButton!
    //@IBOutlet weak var syncResultBtn: UIButton!
    
    var phyMemoryJSON = JSON()
    var oemJailMdmJSON = JSON()
    var resultJSON = JSON()
    var currentTestName : String = ""
    
    var arrTestInSDK_Hold = [String]()
    
    var arrCountrylanguages = [CountryLanguages]()
    let reachability: Reachability? = Reachability()
    let hud = JGProgressHUD()
    var isLanguageMatchAtLaunch = false
    
    //MARK: 1. Bluetooth
    var bluetoothTimer: Timer?
    var bluetoothCount = 0
    var CBmanager : CBCentralManager!
    var isUserTakeAction : Bool = false
    
    //MARK: 2. WiFi
    var wifiTimer: Timer?
    var wifiCount = 0
    
    //MARK: 3. Battery
    var batteryTimer: Timer?
    var batteryCount = 0

    //MARK: 4. Storage
    var storageTimer: Timer?
    var storageCount = 0
    
    //MARK: 5. Gps
    var gpsTimer: Timer?
    var gpsCount = 0
    let locationManager = CLLocationManager()
    var isUserTakeActionForGps : Bool = false
    var currentLocation: CLLocation!
    
    //MARK: 6. GSM
    var gsmTimer: Timer?
    var gsmCount = 0
    var isCapableToCall : Bool = false
    
    //MARK: 7. Vibrator
    var vibratorTimer: Timer?
    var vibratorCount = 0
    let manager = CMMotionManager()
    var isVibrate = false
        

    //MARK: Framework Paths
    //let SBSERVPATH = "/System/Library/PrivateFrameworks/SpringBoardServices.framework/SpringBoardServices"
    //let UIKITPATH = "/System/Library/Framework/UIKit.framework/UIKit"
    
    //let UIKITPATH = "/Applications/Xcode-16.0.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS.sdk/System/Library/Frameworks/UIKit.framework"
    
    let WIPE_MODE_NORMAL = 4

    /*
    func main() {
    
        autoreleasepool {
            // Fetch the SpringBoard server port
            var p = mach_port_t()
            let uikit = dlopen(UIKITPATH, RTLD_LAZY)
            
            let SBSSpringBoardServerPort = dlsym(uikit, "SBSSpringBoardServerPort")
            //let portFunction = unsafeBitCast(SBSSpringBoardServerPort, to: mach_port_t.self)
            let portFunction = unsafeBitCast(SBSSpringBoardServerPort, to: (@convention(c) () -> mach_port_t).self)
            p = portFunction()
            dlclose(uikit)
            
            // Getting DataReset proc
            let sbserv = dlopen(SBSERVPATH, RTLD_LAZY)
            let dataReset = dlsym(sbserv, "SBDataReset")
            let resetFunction = unsafeBitCast(dataReset, to: (@convention(c) (UnsafeMutablePointer<mach_port_t>?, Int32) -> Void).self)
            resetFunction(&p, Int32(WIPE_MODE_NORMAL))
            dlclose(sbserv)
        }
        
    }
    */

    /*
    func main1() {
        
        autoreleasepool {
            // Establish a connection to SpringBoardServices
            var springboardPort: mach_port_t = 0
            let result = SBSSpringBoardServerPort(&springboardPort)
            
            if result != KERN_SUCCESS || springboardPort == MACH_PORT_NULL {
                print("Failed to connect to SpringBoardServices.")
                exit(-1)
            }
            
            // Perform a data wipe using SBDataReset
            let resetResult = SBDataReset(springboardPort, kSBDataResetAll, nil)
            if resetResult != KERN_SUCCESS {
                print("Failed to reset device data.")
                exit(-1)
            }
            
            print("Device data reset successfully!")
        }
    }
    */
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        phyMemoryJSON = JSON()
        oemJailMdmJSON = JSON()
        
        //self.setStatusBarColor(themeColor: GlobalUtility().AppThemeColor)
        
        self.testCollectionView.register(UINib(nibName: "TestCVCell", bundle: nil), forCellWithReuseIdentifier: "TestCVCell")
        
        self.dynamicTestCallingSetup()
        
        self.refreshLocalData()
                        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        appDelegate_Obj.orientationLock = .portrait
        
        self.setCustomNavigationBar()
        
        self.changeLanguageOfUI()
        
        //generateDeviceToken()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        guard let flowLayout = self.testCollectionView.collectionViewLayout as? UICollectionViewFlowLayout else {
            return
        }
        flowLayout.invalidateLayout()
    }
    
    //MARK: Custom Methods
    func generateDeviceToken() {
        let deviceCheck = DCDevice.current
        guard deviceCheck.isSupported else {
            //print("Device Check not supported on this device.")
            return
        }

        deviceCheck.generateToken { data, error in
            guard let data = data, error == nil else {
                //print("Error generating token: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            // Send this data to your server for validation
            //print("Device token generated: \(data.base64EncodedString())")
        }
    }
    
    func changeLanguageOfUI() {
        self.startTestBtn.setTitle(self.getLocalizatioStringValue(key: "START TEST"), for: .normal)
        self.quiteAppBtn.setTitle(self.getLocalizatioStringValue(key: "QUITE APP"), for: .normal)
        //self.syncResultBtn.setTitle(self.getLocalizatioStringValue(key: "SYNC RESULT"), for: .normal)
    }
    
    func setCustomNavigationBar() {
        
        self.navigationController?.navigationBar.barStyle = .default
        //self.navigationController?.navigationBar.barTintColor = UIColor.lightGray
        self.navigationController?.view.tintColor = .black
        self.navigationItem.title = self.getLocalizatioStringValue(key: "InstaDiagnosis")
        
        //self.navigationController?.view.backgroundColor = .black
        //self.navigationController?.hidesBarsOnSwipe = true
        //self.navigationController?.navigationBar.prefersLargeTitles = true
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "backWhite"), style: .plain, target: self, action: #selector(backBtnPressed))
        
        
        /*
        //create a new button as RightBarButton for Language change in SDK
        let button: UIButton = UIButton(type: .custom)
        //set image for button
        button.setImage(UIImage(named: "changeLanguage_icon"), for: .normal)
        //add function for button
        button.addTarget(self, action: #selector(didPressChangeLanguageBtn), for: .touchUpInside)
        //set frame
        button.frame = CGRect(x: 0, y: 0, width: 35, height: 35)
        
        let barButton = UIBarButtonItem(customView: button)
        //assign button to navigationbar
        self.navigationItem.rightBarButtonItem = barButton
        */
        
        
        if #available(iOS 13.0, *) {
            UINavigationBar.appearance().setBackgroundImage(UIImage(), for: .default)
            UINavigationBar.appearance().shadowImage = UIImage()
            UINavigationBar.appearance().isTranslucent = true
        } else {
            // Fallback on earlier versions
        }
                
    }
    
    @objc func backBtnPressed() {
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    @objc func didPressChangeLanguageBtn() {
        
        let message = self.getLocalizatioStringValue(key: "Change language of this app including its content.")
        let sheetCtrl = UIAlertController(title: self.getLocalizatioStringValue(key: "Choose language"), message: message, preferredStyle: .actionSheet)
        
        for language in arrCountrylanguages {
            
            let action = UIAlertAction(title: self.getLocalizatioStringValue(key: language.strLanguageName), style: .default) { _ in
                
                AppUserDefaults.setValue(language.strLanguageSymbol, forKey: "userChangeLanguage")
                
                AppUserDefaults.setValue(language.strLanguageName, forKey: "LanguageName")
                AppUserDefaults.setValue(language.strLanguageUrl, forKey: "LanguageUrl")
                AppUserDefaults.setValue(language.strLanguageSymbol, forKey: "LanguageSymbol")
                AppUserDefaults.setValue(language.strLanguageVersion, forKey: "LanguageVersion")
                
                self.downloadSelectedLanguage(language.strLanguageUrl, language.strLanguageSymbol)
                
            }
            
            sheetCtrl.addAction(action)
        }
        
        let cancelAction = UIAlertAction(title: self.getLocalizatioStringValue(key: "Cancel") , style: .cancel, handler: nil)
        sheetCtrl.addAction(cancelAction)
        
        sheetCtrl.popoverPresentationController?.sourceView = self.view
        sheetCtrl.popoverPresentationController?.sourceRect = self.startTestBtn.frame
        present(sheetCtrl, animated: true, completion: nil)
        
    }
    
    func dynamicTestCallingSetup() {
        
        appDelegate_Obj.orientationLock = .portrait
        
        performDiagnostics = nil
        self.performTestsInSDK()
                
        //MARK: Assign List of Tests to be performed in App
        //arrTestsInSDK = CustomUserDefault.getArrDiagnosisTest()
        arrTestsInSDK = []
        arrTestInSDK_Hold = []
        arrTestsResultJSONInSDK = []
        
        if arrTestsInSDK.count == 0 {
            
            arrTestsInSDK = [
                
                "bluetooth",
                "wifi",                                
                "battery",
                "storage",
                "gps",
                "gsm network",
                "vibrator",
                
                "camera",
                "autofocus",
                
                "auto rotation",
                "proximity",
                "fingerprint scanner",
                "dead pixels",
                "screen",
                "earphone jack",
                "microusb slot",
                "torch",
                "device buttons",
                "top speaker",
                "bottom speaker",
                "top microphone",
                "bottom microphone",
                
                //"speaker",
                //"microphone",
                //"nfc",
                
                //"camera",
                //"autofocus",
                
            ]
            
        }
        
        currentTestIndex = 0
        totalTestsCount = arrTestsInSDK.count
        
        self.arrTestInSDK_Hold = arrTestsInSDK
        
    }
    
    func runTestDynamicInApp() {
        
        self.dynamicTestCallingSetup()
                
        AppResultJSON = JSON()
        self.resultJSON = JSON()
        
        guard let didFinishDiagnosis = performDiagnostics else { return }
        didFinishDiagnosis(self.resultJSON)
        
    }
    
    func refreshLocalData() {
        
        //self.downloadFirebaseRealTimeData()
        
        let defaults = UserDefaults.standard
        let dictionary = defaults.dictionaryRepresentation()
        
        dictionary.keys.forEach { key in
            if (key != "imei_number") {
                if (key != "AppleLanguages") {
                    
                    if (key != "userChangeLanguage") {
                        if (key != "AppCurrentLanguage") {
                            
                            if (key != "LanguageName") {
                                if (key != "LanguageVersion") {
                                    if (key != "LanguageSymbol") {
                                        if (key != "LanguageUrl") {
                                            
                                            //print("key to remove from userDefaults",key)
                                            defaults.removeObject(forKey: key)
                                            
                                        }
                                    }
                                }
                            }
                            
                        }
                    }
                    
                }
            }
            defaults.synchronize()
        }
        
    }
    
    func printRamRom() {
        
        let current_ram = ProcessInfo.processInfo.physicalMemory
        let current_rom = self.getTotalSize()
        
        self.phyMemoryJSON["ram"].uInt64 = current_ram
        self.phyMemoryJSON["rom"].int64 = current_rom
        self.phyMemoryJSON["adminApps"].string = ""
        
        //39220iOS@physicalMemory:{ram,rom,adminApps}
        NSLog("%@%@", "39220iOS@physicalMemory: ", "\(self.phyMemoryJSON)")
        
        /*
        let OSLogStr = ("39220iOS@physicalMemory: " + "\(self.phyMemoryJSON)")
        if #available(iOS 14.0, *) {
            let logger = Logger()
            logger.info("\(OSLogStr)")
        } else {
            // Fallback on earlier versions
            NSLog("%@%@", "39220iOS@physicalMemory: ", "\(self.phyMemoryJSON)")
        }
        */
        
        checkOEMLockJailbreakMdmStatus()
    }
    
    func checkOEMLockJailbreakMdmStatus() {
        
        var oemLockStatus = Bool()
        
        Utility.checkDeviceLockState { deviceLockState in
            print("deviceLockState",deviceLockState)
            
            if deviceLockState == Utility.DeviceLockState.unlocked {
                oemLockStatus = false
            }
            else {
                oemLockStatus = true
            }
            
        }
        
        let jailBrkStatus = Utility().isDeviceJailbroken()
        
        //let mdmStatus = Utility.isDeviceSupervised()
        let mdmStatus = Utility.isMDMManaged()
        
        //print("oemLockStatus",oemLockStatus)
        //print("jailBrkStatus",jailBrkStatus)
        //print("mdmStatus",mdmStatus)
        
        self.oemJailMdmJSON["oem_lock"].boolValue = oemLockStatus
        self.oemJailMdmJSON["isJailbreak"].boolValue = jailBrkStatus
        self.oemJailMdmJSON["isMdmManaged"].boolValue = mdmStatus
        
        NSLog("%@%@", "39220iOS@LOCKS: ", "\(self.oemJailMdmJSON)")
        
        /*
        let OSLogStr = ("39220iOS@LOCKS: " + "\(self.oemJailMdmJSON)")
        if #available(iOS 14.0, *) {
            let logger = Logger()
            logger.info("\(OSLogStr)")
        } else {
            // Fallback on earlier versions
            NSLog("%@%@", "39220iOS@LOCKS: ", "\(self.oemJailMdmJSON)")
        }
        */
        
    }
    
    // MARK: IBActions
    @IBAction func backButtonPressed(_ sender: UIButton) {
        self.dismiss(animated: true, completion: {
            
        })
    }
    
    @IBAction func startTestButtonPressed(_ sender: UIButton) {
                
        AppUserDefaults.removeObject(forKey: "AppResultJSON_Data")
        
        if sender.titleLabel?.text == "START TEST" {
            
            self.runTestDynamicInApp()
            
            self.startTestBtn.setTitle(self.getLocalizatioStringValue(key: "RESTART TEST"), for: .normal)
            //self.quiteAppBtn.isHidden = false
            //self.syncResultBtn.isHidden = false
                        
            self.printRamRom()
            
        }
        else {
            
            NSLog("%@%@", "39220iOS@retry: ", "\(self.resultJSON)")
            
            self.dynamicTestCallingSetup()
            
            //self.startTestBtn.setTitle(self.getLocalizatioStringValue(key: "START TEST"), for: .normal)
            //self.quiteAppBtn.isHidden = true
            
            self.runTestDynamicInApp()
            
            self.printRamRom()
        }
                
    }
    
    @IBAction func quiteAppButtonPressed(_ sender: UIButton) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            exit(0)
        }
    }
    
    @IBAction func syncResultButtonPressed(_ sender: UIButton) {
        
        if (AppUserDefaults.value(forKey: "AppResultJSON_Data") != nil) {
            
            let resultJson = JSON.init(parseJSON: AppUserDefaults.value(forKey: "AppResultJSON_Data") as! String)
            self.resultJSON = JSON()
            self.resultJSON = resultJson
            NSLog("%@%@", "39220iOS@warehouse: ", "\(self.resultJSON)")
                  
        }else {
            AppUserDefaults.setValue(self.resultJSON.rawString(), forKey: "AppResultJSON_Data")
            NSLog("%@%@", "39220iOS@warehouse: ", "\(self.resultJSON)")
        }
        
        //NSLog("%@%@", "39220iOS@warehouse: ", "\(self.resultJSON)")
    }
    
    @IBAction func wipeDataButtonPressed(_ sender: UIButton) {
        
        //main()
        //return
        
        createTestFile()
        
        activityIndicator("Data Wipes In Process")
                
        let fileManager = FileManager.default
        if let documentsPath = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first?.path {
            
            //let filePath = documentsPath + "/file.txt"
            let filePath = documentsPath + "/user_data.txt"
            
            print("filePath is :- ", filePath)
            
            var OSLogStr = ""
            
            //*
            if threePassWipe(filePath: filePath) {
                OSLogStr = "The file was securely wiped and deleted."
            } else {
                OSLogStr = "Failed to wipe the file."
            }
            //*/
            
            
            /*
            SecureDataWipe.threePassWipe(at: filePath) { success in
                if success {
                    OSLogStr = "39220iOS@datawipe: " + "Secure wipe completed successfully"
                }
                else {
                    OSLogStr = "39220iOS@datawipe: " + "Secure wipe failed"
                }
                NSLog("%@", OSLogStr)
            }
            */
            
            NSLog("%@", OSLogStr)
            
        }
        
    }
    
    func getSensitiveFilePath() -> String? {
        // Get the Documents directory
        if let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            // Append the file name
            let filePath = documentsDirectory.appendingPathComponent("user_data.txt").path
            return filePath
        }
        return nil
    }
    
    func createTestFile() {
        if let filePath = getSensitiveFilePath() {
            let content = "Sensitive user data that needs to be wiped."
            do {
                try content.write(toFile: filePath, atomically: true, encoding: .utf8)
                print("Test file created at: \(filePath)")
            } catch {
                print("Error creating file: \(error.localizedDescription)")
            }
        }
    }

    func threePassWipe(filePath: String) -> Bool {
        //guard FileManager.default.fileExists(atPath: filePath) else {
            //print("File does not exist.")
            //return false
        //}

        do {
            // Perform 3 passes
            for _ in 1...3 {
                let fileSize = try FileManager.default.attributesOfItem(atPath: filePath)[.size] as! UInt64
                
                // Generate random data of the same size as the file
                let randomData = Data((0..<fileSize).map { _ in UInt8.random(in: 0...255) })
                
                // Overwrite the file with random data
                let fileHandle = try FileHandle(forWritingTo: URL(fileURLWithPath: filePath))
                if #available(iOS 13.4, *) {
                    try fileHandle.write(contentsOf: randomData)
                    try fileHandle.close()
                } else {
                    // Fallback on earlier versions
                     fileHandle.write(randomData)
                     fileHandle.closeFile()
                }
                
            }

            // Delete the file
            try FileManager.default.removeItem(atPath: filePath)
            print("File securely wiped and deleted.")
            return true

        } catch {
            print("Error during 3-pass wipe: \(error)")
            return false
        }
    }

    
    //MARK: UICollectionView DataSource & Delegates
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return arrTestInSDK_Hold.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let TestCVCell = collectionView.dequeueReusableCell(withReuseIdentifier: "TestCVCell", for: indexPath) as! TestCVCell
        
        //TestCVCell.testImgVW.image = UIImage.init(named: arrTestInSDK_Hold[indexPath.item])
        
        TestCVCell.testImgVW.layer.cornerRadius = 25
        TestCVCell.testImgVW.layer.borderWidth = 1.0
        
        TestCVCell.lblTestName.text = self.getLocalizatioStringValue(key: arrTestInSDK_Hold[indexPath.item].capitalizingFirstLetter())
        
        let templateImage = UIImage.init(named: arrTestInSDK_Hold[indexPath.item])?.withRenderingMode(.alwaysTemplate)
        
        //if (arrTestsResultJSONInSDK.count > 0 && arrTestsResultJSONInSDK.count >= arrTestInSDK_Hold.count) {
        
        if (arrTestsResultJSONInSDK.count > indexPath.item) {
                                    
            if arrTestsResultJSONInSDK[indexPath.item] == 0 {
                TestCVCell.testImgVW.layer.borderColor = UIColor.systemRed.cgColor
                
                TestCVCell.testImgVW.image = templateImage
                TestCVCell.testImgVW.tintColor = .systemRed
            }
            else if arrTestsResultJSONInSDK[indexPath.item] == 1 {
                TestCVCell.testImgVW.layer.borderColor = UIColor.systemGreen.cgColor
                
                TestCVCell.testImgVW.image = templateImage
                TestCVCell.testImgVW.tintColor = .systemGreen
            }
            else if arrTestsResultJSONInSDK[indexPath.item] == -1 {
                TestCVCell.testImgVW.layer.borderColor = UIColor.systemOrange.cgColor
                
                TestCVCell.testImgVW.image = templateImage
                TestCVCell.testImgVW.tintColor = .systemOrange
            }
            else if arrTestsResultJSONInSDK[indexPath.item] == -2 {
                TestCVCell.testImgVW.layer.borderColor = UIColor.systemYellow.cgColor
                
                TestCVCell.testImgVW.image = templateImage
                TestCVCell.testImgVW.tintColor = .systemYellow
            }
            else {
                TestCVCell.testImgVW.layer.borderColor = UIColor.gray.cgColor
                
                TestCVCell.testImgVW.image = templateImage
                TestCVCell.testImgVW.tintColor = .gray
            }
            
        }
        else {
            TestCVCell.testImgVW.layer.borderColor = UIColor.gray.cgColor
            
            TestCVCell.testImgVW.image = templateImage
            TestCVCell.testImgVW.tintColor = .gray
        }
        
        return TestCVCell
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if UIDevice.current.model.hasPrefix("iPad") {
            return CGSize(width: collectionView.frame.size.width/4, height: collectionView.frame.size.width/4)
        }else {
            return CGSize(width: collectionView.frame.size.width/4, height: collectionView.frame.size.width/4)
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        //if (arrTestsResultJSONInSDK.count > 0 && arrTestsResultJSONInSDK.count >= arrTestInSDK_Hold.count) {
        
        if (arrTestsResultJSONInSDK.count > indexPath.item) {
            
            if (arrTestsResultJSONInSDK[indexPath.item] == 0 || arrTestsResultJSONInSDK[indexPath.item] == -1) {
                
                if (self.arrTestInSDK_Hold[indexPath.item] == "battery".lowercased()) {
                    
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "BatteryVC") as! BatteryVC
                    vc.isComingFromTestResult = true
                    vc.retryIndex = indexPath.item
                    
                    vc.batteryRetryDiagnosis = { retryJSON in
                        self.resultJSON = retryJSON
                        
                        AppUserDefaults.setValue(self.resultJSON.rawString(), forKey: "AppResultJSON_Data")
                        DispatchQueue.main.async {
                            if (AppUserDefaults.value(forKey: "AppResultJSON_Data") != nil) {
                                let resultJson = JSON.init(parseJSON: AppUserDefaults.value(forKey: "AppResultJSON_Data") as! String)
                                self.resultJSON = resultJson
                                NSLog("%@%@", "39220iOS@retry: ", "\(self.resultJSON)")
                            }
                            else {
                                NSLog("%@%@", "39220iOS@retry: ", "\(self.resultJSON)")
                            }
                        }
                        
                        
                        self.testCollectionView.reloadData()
                    }
                    
                    vc.resultJSON = self.resultJSON
                    vc.modalPresentationStyle = .fullScreen
                    self.present(vc, animated: true, completion: nil)
                }
                else if (self.arrTestInSDK_Hold[indexPath.item] == "gsm network".lowercased()) {
                    
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "GsmVC") as! GsmVC
                    vc.isComingFromTestResult = true
                    vc.retryIndex = indexPath.item
                    
                    vc.gsmRetryDiagnosis = { retryJSON in
                        self.resultJSON = retryJSON
                        
                        AppUserDefaults.setValue(self.resultJSON.rawString(), forKey: "AppResultJSON_Data")
                        DispatchQueue.main.async {
                            if (AppUserDefaults.value(forKey: "AppResultJSON_Data") != nil) {
                                let resultJson = JSON.init(parseJSON: AppUserDefaults.value(forKey: "AppResultJSON_Data") as! String)
                                self.resultJSON = resultJson
                                NSLog("%@%@", "39220iOS@retry: ", "\(self.resultJSON)")
                            }
                            else {
                                NSLog("%@%@", "39220iOS@retry: ", "\(self.resultJSON)")
                            }
                        }
                        
                        
                        self.testCollectionView.reloadData()
                    }
                    
                    vc.resultJSON = self.resultJSON
                    vc.modalPresentationStyle = .fullScreen
                    self.present(vc, animated: true, completion: nil)
                }
                else if (self.arrTestInSDK_Hold[indexPath.item] == "storage".lowercased()) {
                    
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "StorageVC") as! StorageVC
                    vc.isComingFromTestResult = true
                    vc.retryIndex = indexPath.item
                    
                    vc.storageRetryDiagnosis = { retryJSON in
                        self.resultJSON = retryJSON
                        
                        AppUserDefaults.setValue(self.resultJSON.rawString(), forKey: "AppResultJSON_Data")
                        DispatchQueue.main.async {
                            if (AppUserDefaults.value(forKey: "AppResultJSON_Data") != nil) {
                                let resultJson = JSON.init(parseJSON: AppUserDefaults.value(forKey: "AppResultJSON_Data") as! String)
                                self.resultJSON = resultJson
                                NSLog("%@%@", "39220iOS@retry: ", "\(self.resultJSON)")
                            }
                            else {
                                NSLog("%@%@", "39220iOS@retry: ", "\(self.resultJSON)")
                            }
                        }
                        
                        
                        self.testCollectionView.reloadData()
                    }
                    
                    vc.resultJSON = self.resultJSON
                    vc.modalPresentationStyle = .fullScreen
                    self.present(vc, animated: true, completion: nil)
                }
                else if (self.arrTestInSDK_Hold[indexPath.item] == "wifi".lowercased()) {
                    
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "WiFiVC") as! WiFiVC
                    vc.isComingFromTestResult = true
                    vc.retryIndex = indexPath.item
                    
                    vc.wifiRetryDiagnosis = { retryJSON in
                        self.resultJSON = retryJSON
                        
                        AppUserDefaults.setValue(self.resultJSON.rawString(), forKey: "AppResultJSON_Data")
                        DispatchQueue.main.async {
                            if (AppUserDefaults.value(forKey: "AppResultJSON_Data") != nil) {
                                let resultJson = JSON.init(parseJSON: AppUserDefaults.value(forKey: "AppResultJSON_Data") as! String)
                                self.resultJSON = resultJson
                                NSLog("%@%@", "39220iOS@retry: ", "\(self.resultJSON)")
                            }
                            else {
                                NSLog("%@%@", "39220iOS@retry: ", "\(self.resultJSON)")
                            }
                        }
                        
                        
                        self.testCollectionView.reloadData()
                    }
                    
                    vc.resultJSON = self.resultJSON
                    vc.modalPresentationStyle = .fullScreen
                    self.present(vc, animated: true, completion: nil)
                }
                else if (self.arrTestInSDK_Hold[indexPath.item] == "bluetooth".lowercased()) {
                    
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "BluetoothVC") as! BluetoothVC
                    vc.isComingFromTestResult = true
                    vc.retryIndex = indexPath.item
                    
                    vc.bluetoothRetryDiagnosis = { retryJSON in
                        self.resultJSON = retryJSON
                        
                        AppUserDefaults.setValue(self.resultJSON.rawString(), forKey: "AppResultJSON_Data")
                        DispatchQueue.main.async {
                            if (AppUserDefaults.value(forKey: "AppResultJSON_Data") != nil) {
                                let resultJson = JSON.init(parseJSON: AppUserDefaults.value(forKey: "AppResultJSON_Data") as! String)
                                self.resultJSON = resultJson
                                NSLog("%@%@", "39220iOS@retry: ", "\(self.resultJSON)")
                            }
                            else {
                                NSLog("%@%@", "39220iOS@retry: ", "\(self.resultJSON)")
                            }
                        }
                        
                        
                        self.testCollectionView.reloadData()
                    }
                    
                    vc.resultJSON = self.resultJSON
                    vc.modalPresentationStyle = .fullScreen
                    self.present(vc, animated: true, completion: nil)
                }
                else if (self.arrTestInSDK_Hold[indexPath.item] == "gps".lowercased()) {
                    
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "GpsVC") as! GpsVC
                    vc.isComingFromTestResult = true
                    vc.retryIndex = indexPath.item
                    
                    vc.gpsRetryDiagnosis = { retryJSON in
                        self.resultJSON = retryJSON
                        
                        AppUserDefaults.setValue(self.resultJSON.rawString(), forKey: "AppResultJSON_Data")
                        DispatchQueue.main.async {
                            if (AppUserDefaults.value(forKey: "AppResultJSON_Data") != nil) {
                                let resultJson = JSON.init(parseJSON: AppUserDefaults.value(forKey: "AppResultJSON_Data") as! String)
                                self.resultJSON = resultJson
                                NSLog("%@%@", "39220iOS@retry: ", "\(self.resultJSON)")
                            }
                            else {
                                NSLog("%@%@", "39220iOS@retry: ", "\(self.resultJSON)")
                            }
                        }
                        
                        
                        self.testCollectionView.reloadData()
                    }
                    
                    vc.resultJSON = self.resultJSON
                    vc.modalPresentationStyle = .fullScreen
                    self.present(vc, animated: true, completion: nil)
                }
                else if (self.arrTestInSDK_Hold[indexPath.item] == "vibrator".lowercased()) {
                    
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "VibratorVC") as! VibratorVC
                    vc.isComingFromTestResult = true
                    vc.retryIndex = indexPath.item
                    
                    vc.vibratorRetryDiagnosis = { retryJSON in
                        self.resultJSON = retryJSON
                        
                        AppUserDefaults.setValue(self.resultJSON.rawString(), forKey: "AppResultJSON_Data")
                        DispatchQueue.main.async {
                            if (AppUserDefaults.value(forKey: "AppResultJSON_Data") != nil) {
                                let resultJson = JSON.init(parseJSON: AppUserDefaults.value(forKey: "AppResultJSON_Data") as! String)
                                self.resultJSON = resultJson
                                NSLog("%@%@", "39220iOS@retry: ", "\(self.resultJSON)")
                            }
                            else {
                                NSLog("%@%@", "39220iOS@retry: ", "\(self.resultJSON)")
                            }
                        }
                        
                        
                        self.testCollectionView.reloadData()
                    }
                    
                    vc.resultJSON = self.resultJSON
                    vc.modalPresentationStyle = .fullScreen
                    self.present(vc, animated: true, completion: nil)
                }
                else if (self.arrTestInSDK_Hold[indexPath.item] == "top speaker".lowercased()) {
                    
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "SpeakerVC") as! SpeakerVC
                    vc.isComingFromTestResult = true
                    vc.retryIndex = indexPath.item
                    
                    vc.isComeForTopSpeaker = true
                    vc.isComeForBottomSpeaker = false
                    
                    vc.speakerRetryDiagnosis = { retryJSON in
                        self.resultJSON = retryJSON
                        
                        AppUserDefaults.setValue(self.resultJSON.rawString(), forKey: "AppResultJSON_Data")
                        DispatchQueue.main.async {
                            if (AppUserDefaults.value(forKey: "AppResultJSON_Data") != nil) {
                                let resultJson = JSON.init(parseJSON: AppUserDefaults.value(forKey: "AppResultJSON_Data") as! String)
                                self.resultJSON = resultJson
                                NSLog("%@%@", "39220iOS@retry: ", "\(self.resultJSON)")
                            }
                            else {
                                NSLog("%@%@", "39220iOS@retry: ", "\(self.resultJSON)")
                            }
                        }
                        
                        
                        self.testCollectionView.reloadData()
                    }
                    
                    vc.resultJSON = self.resultJSON
                    vc.modalPresentationStyle = .fullScreen
                    self.present(vc, animated: true, completion: nil)
                }
                else if (self.arrTestInSDK_Hold[indexPath.item] == "bottom speaker".lowercased()) {
                    
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "SpeakerVC") as! SpeakerVC
                    vc.isComingFromTestResult = true
                    vc.retryIndex = indexPath.item
                    
                    vc.isComeForTopSpeaker = false
                    vc.isComeForBottomSpeaker = true
                    
                    vc.speakerRetryDiagnosis = { retryJSON in
                        self.resultJSON = retryJSON
                        
                        AppUserDefaults.setValue(self.resultJSON.rawString(), forKey: "AppResultJSON_Data")
                        DispatchQueue.main.async {
                            if (AppUserDefaults.value(forKey: "AppResultJSON_Data") != nil) {
                                let resultJson = JSON.init(parseJSON: AppUserDefaults.value(forKey: "AppResultJSON_Data") as! String)
                                self.resultJSON = resultJson
                                NSLog("%@%@", "39220iOS@retry: ", "\(self.resultJSON)")
                            }
                            else {
                                NSLog("%@%@", "39220iOS@retry: ", "\(self.resultJSON)")
                            }
                        }
                        
                        
                        self.testCollectionView.reloadData()
                    }
                    
                    vc.resultJSON = self.resultJSON
                    vc.modalPresentationStyle = .fullScreen
                    self.present(vc, animated: true, completion: nil)
                }
                else if (self.arrTestInSDK_Hold[indexPath.item] == "top microphone".lowercased()) {
                    
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "MicroPhoneVC") as! MicroPhoneVC
                    vc.isComingFromTestResult = true
                    vc.retryIndex = indexPath.item
                    
                    vc.isComeForTopMic = true
                    vc.isComeForBottomMic = false
                    
                    vc.micRetryDiagnosis = { retryJSON in
                        self.resultJSON = retryJSON
                        
                        AppUserDefaults.setValue(self.resultJSON.rawString(), forKey: "AppResultJSON_Data")
                        DispatchQueue.main.async {
                            if (AppUserDefaults.value(forKey: "AppResultJSON_Data") != nil) {
                                let resultJson = JSON.init(parseJSON: AppUserDefaults.value(forKey: "AppResultJSON_Data") as! String)
                                self.resultJSON = resultJson
                                NSLog("%@%@", "39220iOS@retry: ", "\(self.resultJSON)")
                            }
                            else {
                                NSLog("%@%@", "39220iOS@retry: ", "\(self.resultJSON)")
                            }
                        }
                        
                        
                        self.testCollectionView.reloadData()
                    }
                    
                    vc.resultJSON = self.resultJSON
                    vc.modalPresentationStyle = .fullScreen
                    self.present(vc, animated: true, completion: nil)
                }
                else if (self.arrTestInSDK_Hold[indexPath.item] == "bottom microphone".lowercased()) {
                    
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "MicroPhoneVC") as! MicroPhoneVC
                    vc.isComingFromTestResult = true
                    vc.retryIndex = indexPath.item
                    
                    vc.isComeForTopMic = false
                    vc.isComeForBottomMic = true
                    
                    vc.micRetryDiagnosis = { retryJSON in
                        self.resultJSON = retryJSON
                        
                        AppUserDefaults.setValue(self.resultJSON.rawString(), forKey: "AppResultJSON_Data")
                        DispatchQueue.main.async {
                            if (AppUserDefaults.value(forKey: "AppResultJSON_Data") != nil) {
                                let resultJson = JSON.init(parseJSON: AppUserDefaults.value(forKey: "AppResultJSON_Data") as! String)
                                self.resultJSON = resultJson
                                NSLog("%@%@", "39220iOS@retry: ", "\(self.resultJSON)")
                            }
                            else {
                                NSLog("%@%@", "39220iOS@retry: ", "\(self.resultJSON)")
                            }
                        }
                        
                        
                        self.testCollectionView.reloadData()
                    }
                    
                    vc.resultJSON = self.resultJSON
                    vc.modalPresentationStyle = .fullScreen
                    self.present(vc, animated: true, completion: nil)
                }
                else if (self.arrTestInSDK_Hold[indexPath.item] == "torch".lowercased()) {
                    
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "FlashLightVC") as! FlashLightVC
                    vc.isComingFromTestResult = true
                    vc.retryIndex = indexPath.item
                    
                    vc.flashlightRetryDiagnosis = { retryJSON in
                        self.resultJSON = retryJSON
                        
                        AppUserDefaults.setValue(self.resultJSON.rawString(), forKey: "AppResultJSON_Data")
                        DispatchQueue.main.async {
                            if (AppUserDefaults.value(forKey: "AppResultJSON_Data") != nil) {
                                let resultJson = JSON.init(parseJSON: AppUserDefaults.value(forKey: "AppResultJSON_Data") as! String)
                                self.resultJSON = resultJson
                                NSLog("%@%@", "39220iOS@retry: ", "\(self.resultJSON)")
                            }
                            else {
                                NSLog("%@%@", "39220iOS@retry: ", "\(self.resultJSON)")
                            }
                        }
                        
                        
                        self.testCollectionView.reloadData()
                    }
                    
                    vc.resultJSON = self.resultJSON
                    vc.modalPresentationStyle = .fullScreen
                    self.present(vc, animated: true, completion: nil)
                }
                else if (self.arrTestInSDK_Hold[indexPath.item] == "earphone jack".lowercased()) {
                    
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "EarphoneVC") as! EarphoneVC
                    vc.isComingFromTestResult = true
                    vc.retryIndex = indexPath.item
                    
                    vc.earphoneRetryDiagnosis = { retryJSON in
                        self.resultJSON = retryJSON
                        
                        AppUserDefaults.setValue(self.resultJSON.rawString(), forKey: "AppResultJSON_Data")
                        DispatchQueue.main.async {
                            if (AppUserDefaults.value(forKey: "AppResultJSON_Data") != nil) {
                                let resultJson = JSON.init(parseJSON: AppUserDefaults.value(forKey: "AppResultJSON_Data") as! String)
                                self.resultJSON = resultJson
                                NSLog("%@%@", "39220iOS@retry: ", "\(self.resultJSON)")
                            }
                            else {
                                NSLog("%@%@", "39220iOS@retry: ", "\(self.resultJSON)")
                            }
                        }
                        
                        
                        self.testCollectionView.reloadData()
                    }
                    
                    vc.resultJSON = self.resultJSON
                    vc.modalPresentationStyle = .fullScreen
                    self.present(vc, animated: true, completion: nil)
                }
                else if (self.arrTestInSDK_Hold[indexPath.item] == "auto rotation".lowercased()) {
                    
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "AutoRotationVC") as! AutoRotationVC
                    vc.isComingFromTestResult = true
                    vc.retryIndex = indexPath.item
                    
                    vc.rotationRetryDiagnosis = { retryJSON in
                        self.resultJSON = retryJSON
                        
                        AppUserDefaults.setValue(self.resultJSON.rawString(), forKey: "AppResultJSON_Data")
                        DispatchQueue.main.async {
                            if (AppUserDefaults.value(forKey: "AppResultJSON_Data") != nil) {
                                let resultJson = JSON.init(parseJSON: AppUserDefaults.value(forKey: "AppResultJSON_Data") as! String)
                                self.resultJSON = resultJson
                                NSLog("%@%@", "39220iOS@retry: ", "\(self.resultJSON)")
                            }
                            else {
                                NSLog("%@%@", "39220iOS@retry: ", "\(self.resultJSON)")
                            }
                        }
                        
                        
                        self.testCollectionView.reloadData()
                    }
                    
                    vc.resultJSON = self.resultJSON
                    vc.modalPresentationStyle = .fullScreen
                    self.present(vc, animated: true, completion: nil)
                }
                else if (self.arrTestInSDK_Hold[indexPath.item] == "proximity".lowercased()) {
                    
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "ProximityVC") as! ProximityVC
                    vc.isComingFromTestResult = true
                    vc.retryIndex = indexPath.item
                    
                    vc.proximityRetryDiagnosis = { retryJSON in
                        self.resultJSON = retryJSON
                        
                        AppUserDefaults.setValue(self.resultJSON.rawString(), forKey: "AppResultJSON_Data")
                        DispatchQueue.main.async {
                            if (AppUserDefaults.value(forKey: "AppResultJSON_Data") != nil) {
                                let resultJson = JSON.init(parseJSON: AppUserDefaults.value(forKey: "AppResultJSON_Data") as! String)
                                self.resultJSON = resultJson
                                NSLog("%@%@", "39220iOS@retry: ", "\(self.resultJSON)")
                            }
                            else {
                                NSLog("%@%@", "39220iOS@retry: ", "\(self.resultJSON)")
                            }
                        }
                        
                        
                        self.testCollectionView.reloadData()
                    }
                    
                    vc.resultJSON = self.resultJSON
                    vc.modalPresentationStyle = .fullScreen
                    self.present(vc, animated: true, completion: nil)
                }
                else if (self.arrTestInSDK_Hold[indexPath.item] == "microusb slot".lowercased()) {
                    
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "ChargerVC") as! ChargerVC
                    vc.isComingFromTestResult = true
                    vc.retryIndex = indexPath.item
                    
                    vc.chargerRetryDiagnosis = { retryJSON in
                        self.resultJSON = retryJSON
                        
                        AppUserDefaults.setValue(self.resultJSON.rawString(), forKey: "AppResultJSON_Data")
                        DispatchQueue.main.async {
                            if (AppUserDefaults.value(forKey: "AppResultJSON_Data") != nil) {
                                let resultJson = JSON.init(parseJSON: AppUserDefaults.value(forKey: "AppResultJSON_Data") as! String)
                                self.resultJSON = resultJson
                                NSLog("%@%@", "39220iOS@retry: ", "\(self.resultJSON)")
                            }
                            else {
                                NSLog("%@%@", "39220iOS@retry: ", "\(self.resultJSON)")
                            }
                        }
                        
                        
                        self.testCollectionView.reloadData()
                    }
                    
                    vc.resultJSON = self.resultJSON
                    vc.modalPresentationStyle = .fullScreen
                    self.present(vc, animated: true, completion: nil)
                }
                else if (self.arrTestInSDK_Hold[indexPath.item] == "dead pixels".lowercased()) {
                    
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "DeadPixelsVC") as! DeadPixelsVC
                    vc.isComingFromTestResult = true
                    vc.retryIndex = indexPath.item
                    
                    vc.deadPixelRetryDiagnosis = { retryJSON in
                        self.resultJSON = retryJSON
                        
                        AppUserDefaults.setValue(self.resultJSON.rawString(), forKey: "AppResultJSON_Data")
                        DispatchQueue.main.async {
                            if (AppUserDefaults.value(forKey: "AppResultJSON_Data") != nil) {
                                let resultJson = JSON.init(parseJSON: AppUserDefaults.value(forKey: "AppResultJSON_Data") as! String)
                                self.resultJSON = resultJson
                                NSLog("%@%@", "39220iOS@retry: ", "\(self.resultJSON)")
                            }
                            else {
                                NSLog("%@%@", "39220iOS@retry: ", "\(self.resultJSON)")
                            }
                        }
                        
                        
                        self.testCollectionView.reloadData()
                    }
                    
                    vc.resultJSON = self.resultJSON
                    vc.modalPresentationStyle = .fullScreen
                    self.present(vc, animated: true, completion: nil)
                }
                else if (self.arrTestInSDK_Hold[indexPath.item] == "camera".lowercased()) {
                    
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "CameraVC") as! CameraVC
                    vc.isComingFromTestResult = true
                    vc.retryIndex = indexPath.item
                    
                    vc.cameraRetryDiagnosis = { retryJSON in
                        self.resultJSON = retryJSON
                        
                        AppUserDefaults.setValue(self.resultJSON.rawString(), forKey: "AppResultJSON_Data")
                        DispatchQueue.main.async {
                            if (AppUserDefaults.value(forKey: "AppResultJSON_Data") != nil) {
                                let resultJson = JSON.init(parseJSON: AppUserDefaults.value(forKey: "AppResultJSON_Data") as! String)
                                self.resultJSON = resultJson
                                NSLog("%@%@", "39220iOS@retry: ", "\(self.resultJSON)")
                            }
                            else {
                                NSLog("%@%@", "39220iOS@retry: ", "\(self.resultJSON)")
                            }
                        }
                        
                        
                        self.testCollectionView.reloadData()
                    }
                    
                    vc.resultJSON = self.resultJSON
                    vc.modalPresentationStyle = .fullScreen
                    self.present(vc, animated: true, completion: nil)
                }
                else if (self.arrTestInSDK_Hold[indexPath.item] == "autofocus".lowercased()) {
                    
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "CameraVC") as! CameraVC
                    vc.isComingFromTestResult = true
                    vc.retryIndex = indexPath.item
                    
                    vc.cameraRetryDiagnosis = { retryJSON in
                        self.resultJSON = retryJSON
                        
                        AppUserDefaults.setValue(self.resultJSON.rawString(), forKey: "AppResultJSON_Data")
                        DispatchQueue.main.async {
                            if (AppUserDefaults.value(forKey: "AppResultJSON_Data") != nil) {
                                let resultJson = JSON.init(parseJSON: AppUserDefaults.value(forKey: "AppResultJSON_Data") as! String)
                                self.resultJSON = resultJson
                                NSLog("%@%@", "39220iOS@retry: ", "\(self.resultJSON)")
                            }
                            else {
                                NSLog("%@%@", "39220iOS@retry: ", "\(self.resultJSON)")
                            }
                        }
                        
                        
                        self.testCollectionView.reloadData()
                    }
                    
                    vc.resultJSON = self.resultJSON
                    vc.modalPresentationStyle = .fullScreen
                    self.present(vc, animated: true, completion: nil)
                }
                else if (self.arrTestInSDK_Hold[indexPath.item] == "screen".lowercased()) {
                    
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "ScreenCalibrationVC") as! ScreenCalibrationVC
                    vc.isComingFromTestResult = true
                    vc.retryIndex = indexPath.item
                    
                    vc.screenRetryDiagnosis = { retryJSON in
                        self.resultJSON = retryJSON
                        
                        AppUserDefaults.setValue(self.resultJSON.rawString(), forKey: "AppResultJSON_Data")
                        DispatchQueue.main.async {
                            if (AppUserDefaults.value(forKey: "AppResultJSON_Data") != nil) {
                                let resultJson = JSON.init(parseJSON: AppUserDefaults.value(forKey: "AppResultJSON_Data") as! String)
                                self.resultJSON = resultJson
                                NSLog("%@%@", "39220iOS@retry: ", "\(self.resultJSON)")
                            }
                            else {
                                NSLog("%@%@", "39220iOS@retry: ", "\(self.resultJSON)")
                            }
                        }
                        
                        
                        self.testCollectionView.reloadData()
                    }
                    
                    vc.resultJSON = self.resultJSON
                    vc.modalPresentationStyle = .fullScreen
                    self.present(vc, animated: true, completion: nil)
                }
                else if (self.arrTestInSDK_Hold[indexPath.item] == "device buttons".lowercased()) {
                    
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "VolumeButtonVC") as! VolumeButtonVC
                    vc.isComingFromTestResult = true
                    vc.retryIndex = indexPath.item
                    
                    vc.volumeRetryDiagnosis = { retryJSON in
                        self.resultJSON = retryJSON
                        
                        AppUserDefaults.setValue(self.resultJSON.rawString(), forKey: "AppResultJSON_Data")
                        DispatchQueue.main.async {
                            if (AppUserDefaults.value(forKey: "AppResultJSON_Data") != nil) {
                                let resultJson = JSON.init(parseJSON: AppUserDefaults.value(forKey: "AppResultJSON_Data") as! String)
                                self.resultJSON = resultJson
                                NSLog("%@%@", "39220iOS@retry: ", "\(self.resultJSON)")
                            }
                            else {
                                NSLog("%@%@", "39220iOS@retry: ", "\(self.resultJSON)")
                            }
                        }
                        
                        
                        self.testCollectionView.reloadData()
                    }
                    
                    vc.resultJSON = self.resultJSON
                    vc.modalPresentationStyle = .fullScreen
                    self.present(vc, animated: true, completion: nil)
                }
                else if (self.arrTestInSDK_Hold[indexPath.item] == "fingerprint scanner".lowercased()) {
                    
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "BiometricVC") as! BiometricVC
                    vc.isComingFromTestResult = true
                    vc.retryIndex = indexPath.item
                    
                    vc.biometricRetryDiagnosis = { retryJSON in
                        self.resultJSON = retryJSON
                        
                        AppUserDefaults.setValue(self.resultJSON.rawString(), forKey: "AppResultJSON_Data")
                        DispatchQueue.main.async {
                            if (AppUserDefaults.value(forKey: "AppResultJSON_Data") != nil) {
                                let resultJson = JSON.init(parseJSON: AppUserDefaults.value(forKey: "AppResultJSON_Data") as! String)
                                self.resultJSON = resultJson
                                NSLog("%@%@", "39220iOS@retry: ", "\(self.resultJSON)")
                            }
                            else {
                                NSLog("%@%@", "39220iOS@retry: ", "\(self.resultJSON)")
                            }
                        }
                        
                        
                        self.testCollectionView.reloadData()
                    }
                    
                    vc.resultJSON = self.resultJSON
                    vc.modalPresentationStyle = .fullScreen
                    self.present(vc, animated: true, completion: nil)
                }
                else {
                    
                }
                
            }
            
        }
        
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    
    func activityIndicator(_ title: String) {
        /*
        strLabel.removeFromSuperview()
        activityIndicator.removeFromSuperview()
        effectView.removeFromSuperview()
        strLabel = UILabel(frame: CGRect(x: 50, y: 0, width: 160, height: 46))
        strLabel.text = title
        strLabel.font = .systemFont(ofSize: 14, weight: .medium)
        strLabel.textColor = UIColor(white: 0.9, alpha: 0.7)
        effectView.frame = CGRect(x: view.frame.midX - strLabel.frame.width/2, y: view.frame.midY - strLabel.frame.height/2 , width: 160, height: 46)
        effectView.layer.cornerRadius = 15
        effectView.layer.masksToBounds = true
        activityIndicator = UIActivityIndicatorView(style: .white)
        activityIndicator.frame = CGRect(x: 0, y: 0, width: 46, height: 46)
        activityIndicator.startAnimating()
        effectView.contentView.addSubview(activityIndicator)
        effectView.contentView.addSubview(strLabel)
        view.addSubview(effectView)
        */
    }
    
}

//MARK: All Tests Calling Dynamically in App
extension HomeVC {
    
    func performTestsInSDK() {
        
        performDiagnostics = { testResultJSON in
                        
            self.resultJSON = JSON()
            self.resultJSON = testResultJSON
            self.testCollectionView.reloadData()
            
            print("arrTestsResultJSONInSDK before perform",arrTestsResultJSONInSDK)
            
            DispatchQueue.main.async() {
                
                if arrTestsInSDK.count > 0 {
                    
                    self.currentTestName = arrTestsInSDK[0]
                    
                    //print(self.currentTestName)
                    //print("test's Result JSON at BEGUN : ", testResultJSON)
                    
                    currentTestIndex += 1
                                    
                    switch self.currentTestName {
                        
                    case "bluetooth".lowercased():
                        
                        if let ind = arrTestsInSDK.firstIndex(of: ("bluetooth".lowercased())) {
                            arrTestsInSDK.remove(at: ind)
                                          
                            self.bluetoothLoad()
                            
                        }
                        
                        break
                        
                    case "wifi".lowercased():
                        
                        if let ind = arrTestsInSDK.firstIndex(of: ("wifi".lowercased())) {
                            arrTestsInSDK.remove(at: ind)
                                         
                            self.wifiLoad()
                            
                        }
                        
                        break
                        
                    case "battery".lowercased():
                        
                        if let ind = arrTestsInSDK.firstIndex(of: ("battery".lowercased())) {
                            arrTestsInSDK.remove(at: ind)
                                          
                            self.batteryLoad()
                            
                        }
                        
                        break
                        
                    case "storage".lowercased():
                        
                        if let ind = arrTestsInSDK.firstIndex(of: ("storage".lowercased())) {
                            arrTestsInSDK.remove(at: ind)
                                                   
                            self.storageLoad()
                            
                        }
                        
                        break
                        
                    case "gps".lowercased():
                        
                        if let ind = arrTestsInSDK.firstIndex(of: ("gps".lowercased())) {
                            arrTestsInSDK.remove(at: ind)
                                          
                            self.gpsLoad()
                            
                        }
                        
                        break
                        
                    case "gsm network".lowercased():
                        
                        if let ind = arrTestsInSDK.firstIndex(of: ("gsm network".lowercased())) {
                            arrTestsInSDK.remove(at: ind)
                                                        
                            self.gsmLoad()
                        }
                        
                        break
                        
                    case "vibrator".lowercased():
                        
                        if let ind = arrTestsInSDK.firstIndex(of: ("vibrator".lowercased())) {
                            arrTestsInSDK.remove(at: ind)
                                                        
                            self.vibratorLoad()
                            
                        }
                        
                        break
                        
                    /*
                    case "bluetooth".lowercased():
                        
                        if let ind = arrTestsInSDK.firstIndex(of: ("bluetooth".lowercased())) {
                            arrTestsInSDK.remove(at: ind)
                            
                            let vc = self.storyboard?.instantiateViewController(withIdentifier: "BluetoothVC") as! BluetoothVC
                            let navigationController = UINavigationController(rootViewController: vc)
                            navigationController.modalPresentationStyle = .overFullScreen
                            vc.resultJSON = testResultJSON
                            vc.modalPresentationStyle = .overFullScreen
                            self.present(navigationController, animated: true, completion: nil)
                            
                        }
                        
                        break
                        
                    case "wifi".lowercased():
                        
                        if let ind = arrTestsInSDK.firstIndex(of: ("wifi".lowercased())) {
                            arrTestsInSDK.remove(at: ind)
                            
                            let vc = self.storyboard?.instantiateViewController(withIdentifier: "WiFiVC") as! WiFiVC
                            let navigationController = UINavigationController(rootViewController: vc)
                            navigationController.modalPresentationStyle = .overFullScreen
                            vc.resultJSON = testResultJSON
                            vc.modalPresentationStyle = .overFullScreen
                            self.present(navigationController, animated: true, completion: nil)
                            
                        }
                        
                        break
                        
                    case "battery".lowercased():
                        
                        if let ind = arrTestsInSDK.firstIndex(of: ("battery".lowercased())) {
                            arrTestsInSDK.remove(at: ind)
                            
                            let vc = self.storyboard?.instantiateViewController(withIdentifier: "BatteryVC") as! BatteryVC
                            let navigationController = UINavigationController(rootViewController: vc)
                            navigationController.modalPresentationStyle = .overFullScreen
                            vc.resultJSON = testResultJSON
                            vc.modalPresentationStyle = .overFullScreen
                            self.present(navigationController, animated: true, completion: nil)
                            
                        }
                        
                        break
                        
                    case "storage".lowercased():
                        
                        if let ind = arrTestsInSDK.firstIndex(of: ("storage".lowercased())) {
                            arrTestsInSDK.remove(at: ind)
                            
                            let vc = self.storyboard?.instantiateViewController(withIdentifier: "StorageVC") as! StorageVC
                            let navigationController = UINavigationController(rootViewController: vc)
                            navigationController.modalPresentationStyle = .overFullScreen
                            vc.resultJSON = testResultJSON
                            vc.modalPresentationStyle = .overFullScreen
                            self.present(navigationController, animated: true, completion: nil)
                            
                        }
                        
                        break
                        
                    case "gps".lowercased():
                        
                        if let ind = arrTestsInSDK.firstIndex(of: ("gps".lowercased())) {
                            arrTestsInSDK.remove(at: ind)
                            
                            let vc = self.storyboard?.instantiateViewController(withIdentifier: "GpsVC") as! GpsVC
                            let navigationController = UINavigationController(rootViewController: vc)
                            navigationController.modalPresentationStyle = .overFullScreen
                            vc.resultJSON = testResultJSON
                            vc.modalPresentationStyle = .overFullScreen
                            self.present(navigationController, animated: true, completion: nil)
                            
                        }
                        
                        break
                        
                    case "gsm network".lowercased():
                        
                        if let ind = arrTestsInSDK.firstIndex(of: ("gsm network".lowercased())) {
                            arrTestsInSDK.remove(at: ind)
                            
                            let vc = self.storyboard?.instantiateViewController(withIdentifier: "GsmVC") as! GsmVC
                            let navigationController = UINavigationController(rootViewController: vc)
                            navigationController.modalPresentationStyle = .overFullScreen
                            vc.resultJSON = testResultJSON
                            vc.modalPresentationStyle = .overFullScreen
                            self.present(navigationController, animated: true, completion: nil)
                            
                        }
                        
                        break
                        
                    case "vibrator".lowercased():
                        
                        if let ind = arrTestsInSDK.firstIndex(of: ("vibrator".lowercased())) {
                            arrTestsInSDK.remove(at: ind)
                            
                            let vc = self.storyboard?.instantiateViewController(withIdentifier: "VibratorVC") as! VibratorVC
                            let navigationController = UINavigationController(rootViewController: vc)
                            navigationController.modalPresentationStyle = .overFullScreen
                            vc.resultJSON = testResultJSON
                            vc.modalPresentationStyle = .overFullScreen
                            self.present(navigationController, animated: true, completion: nil)
                            
                        }
                        
                        break
                    */
                        
                    case "top speaker".lowercased():
                        
                        if let ind = arrTestsInSDK.firstIndex(of: ("top speaker".lowercased())) {
                            arrTestsInSDK.remove(at: ind)
                            
                            let vc = self.storyboard?.instantiateViewController(withIdentifier: "SpeakerVC") as! SpeakerVC
                            let navigationController = UINavigationController(rootViewController: vc)
                            navigationController.modalPresentationStyle = .overFullScreen
                            vc.resultJSON = testResultJSON
                            vc.isComeForTopSpeaker = true
                            vc.isComeForBottomSpeaker = false
                            vc.modalPresentationStyle = .overFullScreen
                            self.present(navigationController, animated: true, completion: nil)
                            
                        }
                        
                        break
                        
                    case "bottom speaker".lowercased():
                        
                        if let ind = arrTestsInSDK.firstIndex(of: ("bottom speaker".lowercased())) {
                            arrTestsInSDK.remove(at: ind)
                            
                            let vc = self.storyboard?.instantiateViewController(withIdentifier: "SpeakerVC") as! SpeakerVC
                            let navigationController = UINavigationController(rootViewController: vc)
                            navigationController.modalPresentationStyle = .overFullScreen
                            vc.resultJSON = testResultJSON
                            vc.isComeForTopSpeaker = false
                            vc.isComeForBottomSpeaker = true
                            vc.modalPresentationStyle = .overFullScreen
                            self.present(navigationController, animated: true, completion: nil)
                            
                        }
                        
                        break
                        
                    case "top microphone".lowercased():
                        
                        if let ind = arrTestsInSDK.firstIndex(of: ("top microphone".lowercased())) {
                            arrTestsInSDK.remove(at: ind)
                            
                            let vc = self.storyboard?.instantiateViewController(withIdentifier: "MicroPhoneVC") as! MicroPhoneVC
                            let navigationController = UINavigationController(rootViewController: vc)
                            navigationController.modalPresentationStyle = .overFullScreen
                            vc.resultJSON = testResultJSON
                            vc.isComeForTopMic = true
                            vc.isComeForBottomMic = false
                            vc.modalPresentationStyle = .overFullScreen
                            self.present(navigationController, animated: true, completion: nil)
                            
                        }
                        
                        break
                        
                    case "bottom microphone".lowercased():
                        
                        if let ind = arrTestsInSDK.firstIndex(of: ("bottom microphone".lowercased())) {
                            arrTestsInSDK.remove(at: ind)
                            
                            let vc = self.storyboard?.instantiateViewController(withIdentifier: "MicroPhoneVC") as! MicroPhoneVC
                            let navigationController = UINavigationController(rootViewController: vc)
                            navigationController.modalPresentationStyle = .overFullScreen
                            vc.resultJSON = testResultJSON
                            vc.isComeForTopMic = false
                            vc.isComeForBottomMic = true
                            vc.modalPresentationStyle = .overFullScreen
                            self.present(navigationController, animated: true, completion: nil)
                            
                        }
                        
                        break
                        
                    case "torch".lowercased():
                        
                        if let ind = arrTestsInSDK.firstIndex(of: ("torch".lowercased())) {
                            arrTestsInSDK.remove(at: ind)
                            
                            let vc = self.storyboard?.instantiateViewController(withIdentifier: "FlashLightVC") as! FlashLightVC
                            let navigationController = UINavigationController(rootViewController: vc)
                            navigationController.modalPresentationStyle = .overFullScreen
                            vc.resultJSON = testResultJSON
                            vc.modalPresentationStyle = .overFullScreen
                            self.present(navigationController, animated: true, completion: nil)
                            
                        }
                        
                        break
                        
                    case "earphone jack".lowercased():
                        
                        if let ind = arrTestsInSDK.firstIndex(of: ("earphone jack".lowercased())) {
                            arrTestsInSDK.remove(at: ind)
                            
                            let vc = self.storyboard?.instantiateViewController(withIdentifier: "EarphoneVC") as! EarphoneVC
                            let navigationController = UINavigationController(rootViewController: vc)
                            navigationController.modalPresentationStyle = .overFullScreen
                            vc.resultJSON = testResultJSON
                            vc.modalPresentationStyle = .overFullScreen
                            self.present(navigationController, animated: true, completion: nil)
                            
                        }
                        
                        break
                        
                    case "auto rotation".lowercased():
                        
                        if let ind = arrTestsInSDK.firstIndex(of: ("auto rotation".lowercased())) {
                            arrTestsInSDK.remove(at: ind)
                            
                            let vc = self.storyboard?.instantiateViewController(withIdentifier: "AutoRotationVC") as! AutoRotationVC
                            let navigationController = UINavigationController(rootViewController: vc)
                            navigationController.modalPresentationStyle = .overFullScreen
                            vc.resultJSON = testResultJSON
                            vc.modalPresentationStyle = .overFullScreen
                            self.present(navigationController, animated: true, completion: nil)
                            
                        }
                        
                        break
                        
                    case "proximity".lowercased():
                        
                        if let ind = arrTestsInSDK.firstIndex(of: ("proximity".lowercased())) {
                            arrTestsInSDK.remove(at: ind)
                            
                            let vc = self.storyboard?.instantiateViewController(withIdentifier: "ProximityVC") as! ProximityVC
                            let navigationController = UINavigationController(rootViewController: vc)
                            navigationController.modalPresentationStyle = .overFullScreen
                            vc.resultJSON = testResultJSON
                            vc.modalPresentationStyle = .overFullScreen
                            self.present(navigationController, animated: true, completion: nil)
                            
                        }
                        
                        break
                        
                    case "microusb slot".lowercased():
                        
                        if let ind = arrTestsInSDK.firstIndex(of: ("microusb slot".lowercased())) {
                            arrTestsInSDK.remove(at: ind)
                            
                            let vc = self.storyboard?.instantiateViewController(withIdentifier: "ChargerVC") as! ChargerVC
                            let navigationController = UINavigationController(rootViewController: vc)
                            navigationController.modalPresentationStyle = .overFullScreen
                            vc.resultJSON = testResultJSON
                            vc.modalPresentationStyle = .overFullScreen
                            self.present(navigationController, animated: true, completion: nil)
                            
                        }
                        
                        break
                        
                    case "dead pixels".lowercased():
                        
                        if let ind = arrTestsInSDK.firstIndex(of: ("dead pixels".lowercased())) {
                            arrTestsInSDK.remove(at: ind)
                            
                            let vc = self.storyboard?.instantiateViewController(withIdentifier: "DeadPixelsVC") as! DeadPixelsVC
                            let navigationController = UINavigationController(rootViewController: vc)
                            navigationController.modalPresentationStyle = .overFullScreen
                            vc.resultJSON = testResultJSON
                            vc.modalPresentationStyle = .overFullScreen
                            self.present(navigationController, animated: true, completion: nil)
                            
                        }
                        
                        break
                        
                    case "camera".lowercased():
                        
                        if let ind = arrTestsInSDK.firstIndex(of: ("camera".lowercased())) {
                            arrTestsInSDK.remove(at: ind)
                            
                            //if let ind1 = arrTestsInSDK.firstIndex(of: ("autofocus".lowercased())) {
                                //arrTestsInSDK.remove(at: ind1)
                            //}
                            
                            let vc = self.storyboard?.instantiateViewController(withIdentifier: "CameraVC") as! CameraVC
                            let navigationController = UINavigationController(rootViewController: vc)
                            navigationController.modalPresentationStyle = .fullScreen
                            vc.resultJSON = testResultJSON
                            vc.modalPresentationStyle = .fullScreen
                            self.present(navigationController, animated: true, completion: nil)
                            
                        }
                        
                        break
                        
                    case "autofocus".lowercased():
                        
                        if let ind = arrTestsInSDK.firstIndex(of: ("autofocus".lowercased())) {
                            arrTestsInSDK.remove(at: ind)
                            
                            //if let ind1 = arrTestsInSDK.firstIndex(of: ("camera".lowercased())) {
                                //arrTestsInSDK.remove(at: ind1)
                            //}
                            
                            let vc = self.storyboard?.instantiateViewController(withIdentifier: "CameraVC") as! CameraVC
                            let navigationController = UINavigationController(rootViewController: vc)
                            navigationController.modalPresentationStyle = .overFullScreen                         
                            vc.resultJSON = testResultJSON
                            //vc.modalPresentationStyle = .overFullScreen
                            self.present(navigationController, animated: true, completion: nil)
                            
                        }
                        
                        break
                        
                    case "screen".lowercased():
                        
                        if let ind = arrTestsInSDK.firstIndex(of: ("screen".lowercased())) {
                            arrTestsInSDK.remove(at: ind)
                            
                            let vc = self.storyboard?.instantiateViewController(withIdentifier: "ScreenCalibrationVC") as! ScreenCalibrationVC
                            let navigationController = UINavigationController(rootViewController: vc)
                            navigationController.modalPresentationStyle = .overFullScreen
                            vc.resultJSON = testResultJSON
                            vc.modalPresentationStyle = .overFullScreen
                            self.present(navigationController, animated: true, completion: nil)
                            
                        }
                        
                        break
                        
                    case "device buttons".lowercased():
                        
                        if let ind = arrTestsInSDK.firstIndex(of: ("device buttons".lowercased())) {
                            arrTestsInSDK.remove(at: ind)
                            
                            let vc = self.storyboard?.instantiateViewController(withIdentifier: "VolumeButtonVC") as! VolumeButtonVC
                            let navigationController = UINavigationController(rootViewController: vc)
                            navigationController.modalPresentationStyle = .overFullScreen
                            vc.resultJSON = testResultJSON
                            vc.modalPresentationStyle = .overFullScreen
                            self.present(navigationController, animated: true, completion: nil)
                            
                        }
                        
                        break
                        
                    case "fingerprint scanner".lowercased():
                        
                        if let ind = arrTestsInSDK.firstIndex(of: ("fingerprint scanner".lowercased())) {
                            arrTestsInSDK.remove(at: ind)
                            
                            let vc = self.storyboard?.instantiateViewController(withIdentifier: "BiometricVC") as! BiometricVC
                            let navigationController = UINavigationController(rootViewController: vc)
                            navigationController.modalPresentationStyle = .overFullScreen
                            vc.resultJSON = testResultJSON
                            vc.modalPresentationStyle = .overFullScreen
                            self.present(navigationController, animated: true, completion: nil)
                            
                        }
                        
                        break
                        
                    default:
                        break
                    }
                    
                    print("Total tests : ", arrTestsInSDK.count)
                    print("test's Result JSON :", testResultJSON)
                    
                }
                else {
                    
                    print("All test's Final Result JSON :", testResultJSON)
                    
                    print("arrTestsResultJSONInSDK.count",arrTestsResultJSONInSDK.count)
                    print("arrTestsResultJSONInSDK",arrTestsResultJSONInSDK)
                    
                    
                    self.resultJSON = JSON()
                    self.resultJSON = testResultJSON
                    self.testCollectionView.reloadData()
                    
                    
                    /*
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "DiagnosticTestResultVC") as! DiagnosticTestResultVC
                    let navigationController = UINavigationController(rootViewController: vc)
                    navigationController.modalPresentationStyle = .overFullScreen
                    vc.resultJSON = testResultJSON
                    vc.modalPresentationStyle = .overFullScreen
                    vc.submitDiagnoseData = { finalResultJson in
                        print("finalResultJson", finalResultJson)
                    }
                    self.present(navigationController, animated: true, completion: nil)
                    */
                    
                }
                
            }
            
        }
        
    }
    
    //MARK: Fetch JSON Data from Remote URL
    func downloadFirebaseRealTimeData() {
        
        if reachability?.connection.description != "No Connection" {
            
            DispatchQueue.main.async {
                
                self.hud.textLabel.text = ""
                self.hud.backgroundColor = #colorLiteral(red: 0.06274510175, green: 0, blue: 0.1921568662, alpha: 0.4)
                self.hud.show(in: self.view)
                
                let url:URL = URL(string: "https://instacash.blob.core.windows.net/static/live/language/smartexchnage-revamp-export.json")!
                
                let session = URLSession.shared
                
                let request = NSMutableURLRequest(url: url)
                request.httpMethod = "GET"
                request.cachePolicy = URLRequest.CachePolicy.reloadIgnoringLocalCacheData
                
                
                let task = session.dataTask(with: request as URLRequest, completionHandler: {
                    (data, response, error) in
                    
                    DispatchQueue.main.async {
                        self.hud.dismiss()
                    }
                    
                    guard let _:Data = data, let _:URLResponse = response  , error == nil else {
                        
                        DispatchQueue.main.async {
                            self.view.makeToast( self.getLocalizatioStringValue(key: "Something went wrong!!"), duration: 2.0, position: .bottom)
                        }
                        
                        return
                    }
                    
                    
                    do {
                        if let jsonDict = try JSONSerialization.jsonObject(with: data ?? Data(), options: []) as? NSDictionary {
                            
                            print("json download :", jsonDict)
                            
                            //MARK: Language JSON Data
                            
                            CountryLanguages.getStoreLanguagesFromJSON(arrInputJSON: jsonDict["language_strings"] as? [[String : Any]?] ?? []) { languages in
                                
                                if languages.count > 0 {
                                    
                                    self.arrCountrylanguages = []
                                    self.arrCountrylanguages = languages
                                    
                                    if let langCodeAvail = AppUserDefaults.value(forKey: "userChangeLanguage") as? String {
                                        
                                        print("langCodeAvail is :-", langCodeAvail)
                                        
                                        for lang in self.arrCountrylanguages {
                                            if lang.strLanguageSymbol == langCodeAvail {
                                                
                                                if let langNameAvail = AppUserDefaults.value(forKey: "LanguageName") as? String {
                                                    
                                                    if lang.strLanguageName == langNameAvail {
                                                        
                                                        print("current language is selected : \(lang.strLanguageName)")
                                                        
                                                        //MARK: Save Here Language Details
                                                        AppUserDefaults.setValue(lang.strLanguageName, forKey: "LanguageName")
                                                        AppUserDefaults.setValue(lang.strLanguageUrl, forKey: "LanguageUrl")
                                                        AppUserDefaults.setValue(lang.strLanguageSymbol, forKey: "LanguageSymbol")
                                                        AppUserDefaults.setValue(lang.strLanguageVersion, forKey: "LanguageVersion")
                                                        
                                                        self.downloadSelectedLanguage(lang.strLanguageUrl, lang.strLanguageSymbol)
                                                        
                                                        break
                                                    }
                                                }
                                            }
                                        }
                                        
                                    }else {
                                        
                                        let preferredLanguage = NSLocale.preferredLanguages[0]
                                        let preferredLanguageCode = preferredLanguage.components(separatedBy: "-").first ?? ""
                                        let firstCode = preferredLanguage.components(separatedBy: "-")
                                        print("preferredLanguage",preferredLanguage)
                                        print("preferredLanguageCode", preferredLanguageCode)
                                        print("firstCode", firstCode)
                                                                                
                                        //MARK: 1. Save Here Language
                                        for lang in languages {
                                            
                                            print("current lang.strLanguageSymbol in first case  \(lang.strLanguageSymbol.lowercased())")
                                            
                                            if lang.strLanguageSymbol.lowercased() == preferredLanguageCode.lowercased() {
                                                
                                                print("current language is \(lang.strLanguageName)")
                                                
                                                AppUserDefaults.setValue(lang.strLanguageName, forKey: "LanguageName")
                                                AppUserDefaults.setValue(lang.strLanguageUrl, forKey: "LanguageUrl")
                                                AppUserDefaults.setValue(lang.strLanguageSymbol, forKey: "LanguageSymbol")
                                                AppUserDefaults.setValue(lang.strLanguageVersion, forKey: "LanguageVersion")
                                                
                                                self.downloadSelectedLanguage(lang.strLanguageUrl, lang.strLanguageSymbol)
                                                
                                                self.isLanguageMatchAtLaunch = true
                                                
                                                break
                                            }
                                        }
                                        
                                        
                                        //MARK: 2. Chinese-Simplified
                                        if !self.isLanguageMatchAtLaunch {
                                            
                                            if (preferredLanguage.contains("zh-Hans")) {
                                                
                                                for ch_si_lang in languages {
                                                    
                                                    print("current strLanguageSymbol in Chinese-Simplified  \(ch_si_lang.strLanguageSymbol.lowercased()) preferredLanguage is \(preferredLanguage)")
                                                    
                                                    if ch_si_lang.strLanguageName.lowercased() == "Chinese-Simplified".lowercased() {
                                                        
                                                        print("current language in ch_si_lang is \(ch_si_lang.strLanguageName)")
                                                        
                                                        AppUserDefaults.setValue(ch_si_lang.strLanguageName, forKey: "LanguageName")
                                                        AppUserDefaults.setValue(ch_si_lang.strLanguageUrl, forKey: "LanguageUrl")
                                                        AppUserDefaults.setValue(ch_si_lang.strLanguageSymbol, forKey: "LanguageSymbol")
                                                        AppUserDefaults.setValue(ch_si_lang.strLanguageVersion, forKey: "LanguageVersion")
                                                        
                                                        self.downloadSelectedLanguage(ch_si_lang.strLanguageUrl, ch_si_lang.strLanguageSymbol)
                                                        
                                                        self.isLanguageMatchAtLaunch = true
                                                        
                                                        break
                                                    }
                                                }
                                            }
                                        }
                                        
                                        
                                        //MARK: 3. Chinese-Traditional
                                        if !self.isLanguageMatchAtLaunch {
                                            
                                            if (preferredLanguage.contains("zh-Hant")) {
                                                
                                                for ch_tr_lang in languages {
                                                    
                                                    print("current strLanguageSymbol in Chinese-Traditional  \(ch_tr_lang.strLanguageSymbol.lowercased()) preferredLanguage is \(preferredLanguage)")
                                                    
                                                    if ch_tr_lang.strLanguageName.lowercased() == "Chinese-Traditional".lowercased() {
                                                        
                                                        print("current language in ch_tr_lang is \(ch_tr_lang.strLanguageName)")
                                                        
                                                        AppUserDefaults.setValue(ch_tr_lang.strLanguageName, forKey: "LanguageName")
                                                        AppUserDefaults.setValue(ch_tr_lang.strLanguageUrl, forKey: "LanguageUrl")
                                                        AppUserDefaults.setValue(ch_tr_lang.strLanguageSymbol, forKey: "LanguageSymbol")
                                                        AppUserDefaults.setValue(ch_tr_lang.strLanguageVersion, forKey: "LanguageVersion")
                                                        
                                                        self.downloadSelectedLanguage(ch_tr_lang.strLanguageUrl, ch_tr_lang.strLanguageSymbol)
                                                        
                                                        self.isLanguageMatchAtLaunch = true
                                                        
                                                        break
                                                    }
                                                }
                                            }
                                        }
                                        
                                        //MARK: 4. Default English
                                        if !self.isLanguageMatchAtLaunch {
                                            
                                            print("current lang.strLanguageSymbol.lowercased() \(languages[0].strLanguageSymbol.lowercased())")
                                            
                                            AppUserDefaults.setValue(languages[0].strLanguageName, forKey: "LanguageName")
                                            AppUserDefaults.setValue(languages[0].strLanguageUrl, forKey: "LanguageUrl")
                                            AppUserDefaults.setValue(languages[0].strLanguageSymbol, forKey: "LanguageSymbol")
                                            AppUserDefaults.setValue(languages[0].strLanguageVersion, forKey: "LanguageVersion")
                                            
                                            self.downloadSelectedLanguage(languages[0].strLanguageUrl, languages[0].strLanguageSymbol)
                                            
                                            self.isLanguageMatchAtLaunch = true
                                        }
                                    }
                                }
                                else{
                                    DispatchQueue.main.async() {
                                        self.view.makeToast(self.getLocalizatioStringValue(key: "Sorry! No Language Available"), duration: 2.0, position: .bottom)
                                    }
                                }
                            }
                        }
                    } catch {
                        print("JSON serialization failed: ", error)
                        DispatchQueue.main.async() {
                            self.view.makeToast(self.getLocalizatioStringValue(key: "JSON serialization failed"), duration: 2.0, position: .bottom)
                        }
                    }
                })
                task.resume()
            }
        }else {
            DispatchQueue.main.async() {
                self.view.makeToast(self.getLocalizatioStringValue(key: "Please Check Internet connection."), duration: 2.0, position: .bottom)
            }
        }
    }
    
    func downloadSelectedLanguage(_ strUrl: String, _ strLangSymbol: String) {
        
        if reachability?.connection.description != "No Connection" {
            
            DispatchQueue.main.async {
                
                self.hud.textLabel.text = ""
                self.hud.backgroundColor = #colorLiteral(red: 0.06274510175, green: 0, blue: 0.1921568662, alpha: 0.4)
                self.hud.show(in: self.view)
                
                let url:URL = URL(string: strUrl)!
                let session = URLSession.shared
                
                let request = NSMutableURLRequest(url: url)
                request.httpMethod = "GET"
                request.cachePolicy = URLRequest.CachePolicy.reloadIgnoringLocalCacheData
                
                let task = session.dataTask(with: request as URLRequest, completionHandler: {
                    (data, response, error) in
                    
                    DispatchQueue.main.async {
                        self.hud.dismiss()
                    }
                    
                    guard let _:Data = data, let _:URLResponse = response  , error == nil else {
                        return
                    }
                    
                    do {
                        if let json = try JSONSerialization.jsonObject(with: data ?? Data(), options: []) as? NSDictionary {
                            
                            //print(json)
                            DispatchQueue.main.async {
                                self.saveLocalizationString(json)
                                //AppUserDefaults.setCountryLanguage(data: json)
                                
                                self.changeLanguageOfUI()
                                
                                self.testCollectionView.reloadData()
                            }
                        }
                    } catch {
                        print("JSON serialization failed: ", error)
                        
                        DispatchQueue.main.async() {
                            self.view.makeToast(self.getLocalizatioStringValue(key: "JSON serialization failed"), duration: 2.0, position: .bottom)
                        }
                    }
                })
                task.resume()
            }
        }else {
            DispatchQueue.main.async() {
                self.view.makeToast(self.getLocalizatioStringValue(key: "Please Check Internet connection."), duration: 2.0, position: .bottom)
            }
        }
    }
    
    func getTotalSize() -> Int64 {
        var space: Int64 = 0
        do {
            let systemAttributes = try FileManager.default.attributesOfFileSystem(forPath: NSHomeDirectory() as String)
            space = ((systemAttributes[FileAttributeKey.systemSize] as? NSNumber)?.int64Value)!
            space = space/1000000000
            if space<8{
                space = 8
            } else if space<16{
                space = 16
            } else if space<32{
                space = 32
            } else if space<64{
                space = 64
            } else if space<128{
                space = 128
            } else if space<256{
                space = 256
            } else if space<512{
                space = 512
            }
        } catch {
            space = 0
        }
        return space
    }
    
}

//MARK: Extenstion for Bluetooth
extension HomeVC {
    
    func bluetoothLoad() {
        self.bluetoothTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.runBluetoothTimer), userInfo: nil, repeats: true)
        
        self.CBmanager = CBCentralManager()
        self.CBmanager.delegate = self
        
        checkBluetoothState = {
            self.isUserTakeAction = true
            
            // Initialize central manager without immediately prompting for Bluetooth access
            self.CBmanager = CBCentralManager(delegate: self, queue: nil, options: [CBCentralManagerOptionShowPowerAlertKey: false])
        }
    }
    
    @objc func runBluetoothTimer() {
        self.bluetoothTest()
        self.bluetoothCount += 1
    }
    
    func bluetoothTest() {
        
        switch self.CBmanager?.state {
        case .poweredOn:
            
            if #available(iOS 13.0, *) {
                
                if (AppUserDefaults.value(forKey: "AppResultJSON_Data") != nil) {
                    let resultJson = JSON.init(parseJSON: AppUserDefaults.value(forKey: "AppResultJSON_Data") as! String)
                    self.resultJSON = resultJson
                }
                
                if CBmanager.authorization == .allowedAlways {
                    
                    arrTestsResultJSONInSDK.append(1)
                    
                    self.resultJSON["Bluetooth"].int = 1
                    UserDefaults.standard.set(true, forKey: "Bluetooth")
                    
                }
                else if CBmanager.authorization == .denied {
                    
                    arrTestsResultJSONInSDK.append(0)
                    
                    self.resultJSON["Bluetooth"].int = 0
                    UserDefaults.standard.set(false, forKey: "Bluetooth")
                    
                }
                else {
                    
                }
                
                AppUserDefaults.setValue(self.resultJSON.rawString(), forKey: "AppResultJSON_Data")
                
                DispatchQueue.main.async {
            if (AppUserDefaults.value(forKey: "AppResultJSON_Data") != nil) {
                let resultJson = JSON.init(parseJSON: AppUserDefaults.value(forKey: "AppResultJSON_Data") as! String)
                self.resultJSON = resultJson
                NSLog("%@%@", "39220iOS@warehouse: ", "\(self.resultJSON)")
            }
            else {
                NSLog("%@%@", "39220iOS@warehouse: ", "\(self.resultJSON)")
            }
        }
                
            } else {
                // Fallback on earlier versions
                
                if (AppUserDefaults.value(forKey: "AppResultJSON_Data") != nil) {
                    let resultJson = JSON.init(parseJSON: AppUserDefaults.value(forKey: "AppResultJSON_Data") as! String)
                    self.resultJSON = resultJson
                }
                
                arrTestsResultJSONInSDK.append(1)
                
                self.resultJSON["Bluetooth"].int = 1
                UserDefaults.standard.set(true, forKey: "Bluetooth")
                
                AppUserDefaults.setValue(self.resultJSON.rawString(), forKey: "AppResultJSON_Data")
                DispatchQueue.main.async {
            if (AppUserDefaults.value(forKey: "AppResultJSON_Data") != nil) {
                let resultJson = JSON.init(parseJSON: AppUserDefaults.value(forKey: "AppResultJSON_Data") as! String)
                self.resultJSON = resultJson
                NSLog("%@%@", "39220iOS@warehouse: ", "\(self.resultJSON)")
            }
            else {
                NSLog("%@%@", "39220iOS@warehouse: ", "\(self.resultJSON)")
            }
        }
            }
                        
            self.bluetoothTestClose()
            
            break
            
        case .poweredOff:
            
            if self.bluetoothCount == 2 {
                
                if (AppUserDefaults.value(forKey: "AppResultJSON_Data") != nil) {
                    let resultJson = JSON.init(parseJSON: AppUserDefaults.value(forKey: "AppResultJSON_Data") as! String)
                    self.resultJSON = resultJson
                }
                
                arrTestsResultJSONInSDK.append(0)
                
                self.resultJSON["Bluetooth"].int = 0
                UserDefaults.standard.set(false, forKey: "Bluetooth")
                
                AppUserDefaults.setValue(self.resultJSON.rawString(), forKey: "AppResultJSON_Data")
                DispatchQueue.main.async {
            if (AppUserDefaults.value(forKey: "AppResultJSON_Data") != nil) {
                let resultJson = JSON.init(parseJSON: AppUserDefaults.value(forKey: "AppResultJSON_Data") as! String)
                self.resultJSON = resultJson
                NSLog("%@%@", "39220iOS@warehouse: ", "\(self.resultJSON)")
            }
            else {
                NSLog("%@%@", "39220iOS@warehouse: ", "\(self.resultJSON)")
            }
        }
                
                self.bluetoothTestClose()
                
            }
            
            break
            
        case .resetting:
            break
        case .unauthorized:
            break
        case .unsupported:
            break
        case .unknown:
            break
        default:
            break
        }
        
    }
    
    func bluetoothTestClose() {
        self.isUserTakeAction = false
        checkBluetoothState = nil
        self.bluetoothTimer?.invalidate()
        self.bluetoothCount = 0
        
        guard let didFinishTestDiagnosis = performDiagnostics else { return }
        didFinishTestDiagnosis(self.resultJSON)
    }
    
    //MARK: Core Bluetooth Delegates
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .poweredOn:
            
            if self.isUserTakeAction {
                
                if (AppUserDefaults.value(forKey: "AppResultJSON_Data") != nil) {
                    let resultJson = JSON.init(parseJSON: AppUserDefaults.value(forKey: "AppResultJSON_Data") as! String)
                    self.resultJSON = resultJson
                }
                
                arrTestsResultJSONInSDK.append(1)
                
                self.resultJSON["Bluetooth"].int = 1
                UserDefaults.standard.set(true, forKey: "Bluetooth")
                
                AppUserDefaults.setValue(self.resultJSON.rawString(), forKey: "AppResultJSON_Data")
                DispatchQueue.main.async {
            if (AppUserDefaults.value(forKey: "AppResultJSON_Data") != nil) {
                let resultJson = JSON.init(parseJSON: AppUserDefaults.value(forKey: "AppResultJSON_Data") as! String)
                self.resultJSON = resultJson
                NSLog("%@%@", "39220iOS@warehouse: ", "\(self.resultJSON)")
            }
            else {
                NSLog("%@%@", "39220iOS@warehouse: ", "\(self.resultJSON)")
            }
        }
                
                self.bluetoothTestClose()
            }
            
            print("Bluetooth is On")
            break
            
        case .poweredOff:
            
            self.bluetoothTimer?.invalidate()
            
            if self.isUserTakeAction {
                
                if (AppUserDefaults.value(forKey: "AppResultJSON_Data") != nil) {
                    let resultJson = JSON.init(parseJSON: AppUserDefaults.value(forKey: "AppResultJSON_Data") as! String)
                    self.resultJSON = resultJson
                }
                
                arrTestsResultJSONInSDK.append(0)
                
                self.resultJSON["Bluetooth"].int = 0
                UserDefaults.standard.set(false, forKey: "Bluetooth")
                
                AppUserDefaults.setValue(self.resultJSON.rawString(), forKey: "AppResultJSON_Data")
                DispatchQueue.main.async {
            if (AppUserDefaults.value(forKey: "AppResultJSON_Data") != nil) {
                let resultJson = JSON.init(parseJSON: AppUserDefaults.value(forKey: "AppResultJSON_Data") as! String)
                self.resultJSON = resultJson
                NSLog("%@%@", "39220iOS@warehouse: ", "\(self.resultJSON)")
            }
            else {
                NSLog("%@%@", "39220iOS@warehouse: ", "\(self.resultJSON)")
            }
        }
                
                self.bluetoothTestClose()
            }
            
            print("Bluetooth is Off")
            break
            
        case .resetting:
            
            self.bluetoothTimer?.invalidate()
            
            if self.isUserTakeAction {
                
                if (AppUserDefaults.value(forKey: "AppResultJSON_Data") != nil) {
                    let resultJson = JSON.init(parseJSON: AppUserDefaults.value(forKey: "AppResultJSON_Data") as! String)
                    self.resultJSON = resultJson
                }
                
                arrTestsResultJSONInSDK.append(0)
                
                self.resultJSON["Bluetooth"].int = 0
                UserDefaults.standard.set(false, forKey: "Bluetooth")
                
                AppUserDefaults.setValue(self.resultJSON.rawString(), forKey: "AppResultJSON_Data")
                DispatchQueue.main.async {
            if (AppUserDefaults.value(forKey: "AppResultJSON_Data") != nil) {
                let resultJson = JSON.init(parseJSON: AppUserDefaults.value(forKey: "AppResultJSON_Data") as! String)
                self.resultJSON = resultJson
                NSLog("%@%@", "39220iOS@warehouse: ", "\(self.resultJSON)")
            }
            else {
                NSLog("%@%@", "39220iOS@warehouse: ", "\(self.resultJSON)")
            }
        }
                
                self.bluetoothTestClose()
            }
            
            print("resetting")
            break
            
        case .unauthorized:
            
            self.bluetoothTimer?.invalidate()
            
            if self.isUserTakeAction {
                
                if (AppUserDefaults.value(forKey: "AppResultJSON_Data") != nil) {
                    let resultJson = JSON.init(parseJSON: AppUserDefaults.value(forKey: "AppResultJSON_Data") as! String)
                    self.resultJSON = resultJson
                }
                
                arrTestsResultJSONInSDK.append(0)
                
                self.resultJSON["Bluetooth"].int = 0
                UserDefaults.standard.set(false, forKey: "Bluetooth")
                
                AppUserDefaults.setValue(self.resultJSON.rawString(), forKey: "AppResultJSON_Data")
                DispatchQueue.main.async {
            if (AppUserDefaults.value(forKey: "AppResultJSON_Data") != nil) {
                let resultJson = JSON.init(parseJSON: AppUserDefaults.value(forKey: "AppResultJSON_Data") as! String)
                self.resultJSON = resultJson
                NSLog("%@%@", "39220iOS@warehouse: ", "\(self.resultJSON)")
            }
            else {
                NSLog("%@%@", "39220iOS@warehouse: ", "\(self.resultJSON)")
            }
        }
                
                self.bluetoothTestClose()
            }
            
            print("unauthorized")
            break
            
        case .unsupported:
            
            self.bluetoothTimer?.invalidate()
            
            if self.isUserTakeAction {
                
                if (AppUserDefaults.value(forKey: "AppResultJSON_Data") != nil) {
                    let resultJson = JSON.init(parseJSON: AppUserDefaults.value(forKey: "AppResultJSON_Data") as! String)
                    self.resultJSON = resultJson
                }
                
                arrTestsResultJSONInSDK.append(0)
                
                self.resultJSON["Bluetooth"].int = 0
                UserDefaults.standard.set(false, forKey: "Bluetooth")
                
                AppUserDefaults.setValue(self.resultJSON.rawString(), forKey: "AppResultJSON_Data")
                DispatchQueue.main.async {
            if (AppUserDefaults.value(forKey: "AppResultJSON_Data") != nil) {
                let resultJson = JSON.init(parseJSON: AppUserDefaults.value(forKey: "AppResultJSON_Data") as! String)
                self.resultJSON = resultJson
                NSLog("%@%@", "39220iOS@warehouse: ", "\(self.resultJSON)")
            }
            else {
                NSLog("%@%@", "39220iOS@warehouse: ", "\(self.resultJSON)")
            }
        }
                
                self.bluetoothTestClose()
            }
            
            print("unsupported")
            break
            
        case .unknown:
            
            self.bluetoothTimer?.invalidate()
            
            if self.isUserTakeAction {
                
                if (AppUserDefaults.value(forKey: "AppResultJSON_Data") != nil) {
                    let resultJson = JSON.init(parseJSON: AppUserDefaults.value(forKey: "AppResultJSON_Data") as! String)
                    self.resultJSON = resultJson
                }
                
                arrTestsResultJSONInSDK.append(0)
                
                self.resultJSON["Bluetooth"].int = 0
                UserDefaults.standard.set(false, forKey: "Bluetooth")
                
                AppUserDefaults.setValue(self.resultJSON.rawString(), forKey: "AppResultJSON_Data")
                DispatchQueue.main.async {
            if (AppUserDefaults.value(forKey: "AppResultJSON_Data") != nil) {
                let resultJson = JSON.init(parseJSON: AppUserDefaults.value(forKey: "AppResultJSON_Data") as! String)
                self.resultJSON = resultJson
                NSLog("%@%@", "39220iOS@warehouse: ", "\(self.resultJSON)")
            }
            else {
                NSLog("%@%@", "39220iOS@warehouse: ", "\(self.resultJSON)")
            }
        }
                
                self.bluetoothTestClose()
            }
            
            print("unknown")
            break
            
        default:
            
            self.bluetoothTimer?.invalidate()
            
            if self.isUserTakeAction {
                
                if (AppUserDefaults.value(forKey: "AppResultJSON_Data") != nil) {
                    let resultJson = JSON.init(parseJSON: AppUserDefaults.value(forKey: "AppResultJSON_Data") as! String)
                    self.resultJSON = resultJson
                }
                
                arrTestsResultJSONInSDK.append(0)
                
                self.resultJSON["Bluetooth"].int = 0
                UserDefaults.standard.set(false, forKey: "Bluetooth")
                
                AppUserDefaults.setValue(self.resultJSON.rawString(), forKey: "AppResultJSON_Data")
                DispatchQueue.main.async {
            if (AppUserDefaults.value(forKey: "AppResultJSON_Data") != nil) {
                let resultJson = JSON.init(parseJSON: AppUserDefaults.value(forKey: "AppResultJSON_Data") as! String)
                self.resultJSON = resultJson
                NSLog("%@%@", "39220iOS@warehouse: ", "\(self.resultJSON)")
            }
            else {
                NSLog("%@%@", "39220iOS@warehouse: ", "\(self.resultJSON)")
            }
        }
                
                self.bluetoothTestClose()
            }
            
            break
        }
        
    }
    
}

//MARK: Extenstion for WiFi
extension HomeVC {
    
    func wifiLoad() {
        self.wifiTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.runWifiTimer), userInfo: nil, repeats: true)
    }
    
    @objc func runWifiTimer() {
        self.wifiTest()
        //self.wifiCount += 1
    }
    
    func wifiTestClose() {
        self.wifiTimer?.invalidate()
        self.wifiCount = 0
        
        guard let didFinishTestDiagnosis = performDiagnostics else { return }
        didFinishTestDiagnosis(self.resultJSON)
    }
    
    func wifiTest() {
        
        if Luminous.Network.isConnectedViaWiFi {
            
            if (AppUserDefaults.value(forKey: "AppResultJSON_Data") != nil) {
                let resultJson = JSON.init(parseJSON: AppUserDefaults.value(forKey: "AppResultJSON_Data") as! String)
                self.resultJSON = resultJson
            }
            
            arrTestsResultJSONInSDK.append(1)
            
            self.resultJSON["WIFI"].int = 1
            UserDefaults.standard.setValue(true, forKey: "WIFI")
            
            AppUserDefaults.setValue(self.resultJSON.rawString(), forKey: "AppResultJSON_Data")
            DispatchQueue.main.async {
        if (AppUserDefaults.value(forKey: "AppResultJSON_Data") != nil) {
            let resultJson = JSON.init(parseJSON: AppUserDefaults.value(forKey: "AppResultJSON_Data") as! String)
            self.resultJSON = resultJson
            NSLog("%@%@", "39220iOS@warehouse: ", "\(self.resultJSON)")
        }
        else {
            NSLog("%@%@", "39220iOS@warehouse: ", "\(self.resultJSON)")
        }
    }
            
            self.wifiTestClose()
            
        }
        else{
            
            if (AppUserDefaults.value(forKey: "AppResultJSON_Data") != nil) {
                let resultJson = JSON.init(parseJSON: AppUserDefaults.value(forKey: "AppResultJSON_Data") as! String)
                self.resultJSON = resultJson
            }
            
            arrTestsResultJSONInSDK.append(0)
            
            self.resultJSON["WIFI"].int = 0
            UserDefaults.standard.setValue(false, forKey: "WIFI")
            
            AppUserDefaults.setValue(self.resultJSON.rawString(), forKey: "AppResultJSON_Data")
            DispatchQueue.main.async {
        if (AppUserDefaults.value(forKey: "AppResultJSON_Data") != nil) {
            let resultJson = JSON.init(parseJSON: AppUserDefaults.value(forKey: "AppResultJSON_Data") as! String)
            self.resultJSON = resultJson
            NSLog("%@%@", "39220iOS@warehouse: ", "\(self.resultJSON)")
        }
        else {
            NSLog("%@%@", "39220iOS@warehouse: ", "\(self.resultJSON)")
        }
    }
            
            //if self.wifiCount == 2 {
            self.wifiTestClose()
            //}
            
        }
        
    }
    
}

//MARK: Extenstion for Battery
extension HomeVC {
    
    func batteryLoad() {
        self.batteryTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.runBatteryTimer), userInfo: nil, repeats: true)
    }
    
    @objc func runBatteryTimer() {
        self.batteryTest()
        //self.batteryCount += 1
    }
    
    func batteryTestClose() {
        self.batteryTimer?.invalidate()
        self.batteryCount = 0
        
        guard let didFinishTestDiagnosis = performDiagnostics else { return }
        didFinishTestDiagnosis(self.resultJSON)
    }
    
    func batteryTest() {
        
        if Luminous.Battery.state == .unknown {
            
            if (AppUserDefaults.value(forKey: "AppResultJSON_Data") != nil) {
                let resultJson = JSON.init(parseJSON: AppUserDefaults.value(forKey: "AppResultJSON_Data") as! String)
                self.resultJSON = resultJson
            }
            
            arrTestsResultJSONInSDK.append(0)
            
            self.resultJSON["Battery"].int = 0
            UserDefaults.standard.set(false, forKey: "Battery")
            
            AppUserDefaults.setValue(self.resultJSON.rawString(), forKey: "AppResultJSON_Data")
            DispatchQueue.main.async {
        if (AppUserDefaults.value(forKey: "AppResultJSON_Data") != nil) {
            let resultJson = JSON.init(parseJSON: AppUserDefaults.value(forKey: "AppResultJSON_Data") as! String)
            self.resultJSON = resultJson
            NSLog("%@%@", "39220iOS@warehouse: ", "\(self.resultJSON)")
        }
        else {
            NSLog("%@%@", "39220iOS@warehouse: ", "\(self.resultJSON)")
        }
    }
            
            //if self.batteryCount == 2 {
            self.batteryTestClose()
            //}
            
        } else {
            
            if (AppUserDefaults.value(forKey: "AppResultJSON_Data") != nil) {
                let resultJson = JSON.init(parseJSON: AppUserDefaults.value(forKey: "AppResultJSON_Data") as! String)
                self.resultJSON = resultJson
            }
            
            arrTestsResultJSONInSDK.append(1)
            
            self.resultJSON["Battery"].int = 1
            UserDefaults.standard.set(true, forKey: "Battery")
            
            AppUserDefaults.setValue(self.resultJSON.rawString(), forKey: "AppResultJSON_Data")
            DispatchQueue.main.async {
        if (AppUserDefaults.value(forKey: "AppResultJSON_Data") != nil) {
            let resultJson = JSON.init(parseJSON: AppUserDefaults.value(forKey: "AppResultJSON_Data") as! String)
            self.resultJSON = resultJson
            NSLog("%@%@", "39220iOS@warehouse: ", "\(self.resultJSON)")
        }
        else {
            NSLog("%@%@", "39220iOS@warehouse: ", "\(self.resultJSON)")
        }
    }
            
            self.batteryTestClose()
        }
        
    }
    
}

//MARK: Extenstion for Storage
extension HomeVC {
    
    func storageLoad() {
        self.storageTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.runStorageTimer), userInfo: nil, repeats: true)
    }
    
    @objc func runStorageTimer() {
        self.storageTest()
        //self.storageCount += 1
    }
    
    func storageTestClose() {
        self.storageTimer?.invalidate()
        self.storageCount = 0
        
        guard let didFinishTestDiagnosis = performDiagnostics else { return }
        didFinishTestDiagnosis(self.resultJSON)
    }
    
    func storageTest() {
        
        if Luminous.Hardware.physicalMemory(with: .kilobytes) > 1024.0 {
            
            if (AppUserDefaults.value(forKey: "AppResultJSON_Data") != nil) {
                let resultJson = JSON.init(parseJSON: AppUserDefaults.value(forKey: "AppResultJSON_Data") as! String)
                self.resultJSON = resultJson
            }
            
            arrTestsResultJSONInSDK.append(1)
            
            self.resultJSON["Storage"].int = 1
            UserDefaults.standard.set(true, forKey: "Storage")
            
            AppUserDefaults.setValue(self.resultJSON.rawString(), forKey: "AppResultJSON_Data")
            DispatchQueue.main.async {
        if (AppUserDefaults.value(forKey: "AppResultJSON_Data") != nil) {
            let resultJson = JSON.init(parseJSON: AppUserDefaults.value(forKey: "AppResultJSON_Data") as! String)
            self.resultJSON = resultJson
            NSLog("%@%@", "39220iOS@warehouse: ", "\(self.resultJSON)")
        }
        else {
            NSLog("%@%@", "39220iOS@warehouse: ", "\(self.resultJSON)")
        }
    }
            
            self.storageTestClose()
            
        }else {
            
            if (AppUserDefaults.value(forKey: "AppResultJSON_Data") != nil) {
                let resultJson = JSON.init(parseJSON: AppUserDefaults.value(forKey: "AppResultJSON_Data") as! String)
                self.resultJSON = resultJson
            }
            
            arrTestsResultJSONInSDK.append(0)
            
            self.resultJSON["Storage"].int = 0
            UserDefaults.standard.set(false, forKey: "Storage")
            
            AppUserDefaults.setValue(self.resultJSON.rawString(), forKey: "AppResultJSON_Data")
            DispatchQueue.main.async {
        if (AppUserDefaults.value(forKey: "AppResultJSON_Data") != nil) {
            let resultJson = JSON.init(parseJSON: AppUserDefaults.value(forKey: "AppResultJSON_Data") as! String)
            self.resultJSON = resultJson
            NSLog("%@%@", "39220iOS@warehouse: ", "\(self.resultJSON)")
        }
        else {
            NSLog("%@%@", "39220iOS@warehouse: ", "\(self.resultJSON)")
        }
    }
            
            //if self.storageCount == 2 {
            self.storageTestClose()
            //}
        }
        
    }
    
}

//MARK: Extenstion for GPS
extension HomeVC {
    
    func gpsLoad() {
        
        self.isLocationAccessEnabled()
        
        checkLocationState = {
            self.isUserTakeActionForGps = true
            self.isLocationAccessEnabled()
        }
        
    }
    
    @objc func runGpsTimer() {
        self.gpsCount += 1
    }
    
    func gpsTestClose() {
        
        DispatchQueue.main.async {
            
            self.locationManager.stopUpdatingLocation()
            
            self.isUserTakeActionForGps = false
            checkLocationState = nil
            
            self.gpsTimer?.invalidate()
            self.gpsCount = 0
            
            guard let didFinishTestDiagnosis = performDiagnostics else { return }
            didFinishTestDiagnosis(self.resultJSON)
        }
    }
    
    func isLocationAccessEnabled() {
        
        DispatchQueue.global().async {
            
            if CLLocationManager.locationServicesEnabled() {
                
                switch CLLocationManager.authorizationStatus() {
                    
                case .authorizedAlways, .authorizedWhenInUse:
                    
                    print("Access of location")
                    
                    self.currentLocation = self.locationManager.location
                    
                    var lat = 0.0
                    var long = 0.0
                    
                    lat = self.currentLocation.coordinate.latitude
                    long = self.currentLocation.coordinate.longitude
                    
                    print(lat, long)
                    
                    if (lat > 0.0 && long > 0.0) {
                        
                        if (AppUserDefaults.value(forKey: "AppResultJSON_Data") != nil) {
                            let resultJson = JSON.init(parseJSON: AppUserDefaults.value(forKey: "AppResultJSON_Data") as! String)
                            self.resultJSON = resultJson
                        }
                        
                        arrTestsResultJSONInSDK.append(1)
                        
                        self.resultJSON["GPS"].int = 1
                        UserDefaults.standard.set(true, forKey: "GPS")
                        
                        AppUserDefaults.setValue(self.resultJSON.rawString(), forKey: "AppResultJSON_Data")
                        DispatchQueue.main.async {
                    if (AppUserDefaults.value(forKey: "AppResultJSON_Data") != nil) {
                        let resultJson = JSON.init(parseJSON: AppUserDefaults.value(forKey: "AppResultJSON_Data") as! String)
                        self.resultJSON = resultJson
                        NSLog("%@%@", "39220iOS@warehouse: ", "\(self.resultJSON)")
                    }
                    else {
                        NSLog("%@%@", "39220iOS@warehouse: ", "\(self.resultJSON)")
                    }
                }
                        
                        self.gpsTestClose()
                        
                    }
                    else {
                        
                        if (AppUserDefaults.value(forKey: "AppResultJSON_Data") != nil) {
                            let resultJson = JSON.init(parseJSON: AppUserDefaults.value(forKey: "AppResultJSON_Data") as! String)
                            self.resultJSON = resultJson
                        }
                        
                        arrTestsResultJSONInSDK.append(0)
                        
                        self.resultJSON["GPS"].int = 0
                        UserDefaults.standard.set(false, forKey: "GPS")
                        
                        AppUserDefaults.setValue(self.resultJSON.rawString(), forKey: "AppResultJSON_Data")
                        DispatchQueue.main.async {
                    if (AppUserDefaults.value(forKey: "AppResultJSON_Data") != nil) {
                        let resultJson = JSON.init(parseJSON: AppUserDefaults.value(forKey: "AppResultJSON_Data") as! String)
                        self.resultJSON = resultJson
                        NSLog("%@%@", "39220iOS@warehouse: ", "\(self.resultJSON)")
                    }
                    else {
                        NSLog("%@%@", "39220iOS@warehouse: ", "\(self.resultJSON)")
                    }
                }
                        
                        self.gpsTestClose()
                        
                    }
                    
                case .denied:
                    print("No access of location")
                    
                    if (AppUserDefaults.value(forKey: "AppResultJSON_Data") != nil) {
                        let resultJson = JSON.init(parseJSON: AppUserDefaults.value(forKey: "AppResultJSON_Data") as! String)
                        self.resultJSON = resultJson
                    }
                    
                    arrTestsResultJSONInSDK.append(0)
                    
                    self.resultJSON["GPS"].int = 0
                    UserDefaults.standard.set(false, forKey: "GPS")
                    
                    AppUserDefaults.setValue(self.resultJSON.rawString(), forKey: "AppResultJSON_Data")
                    DispatchQueue.main.async {
                    if (AppUserDefaults.value(forKey: "AppResultJSON_Data") != nil) {
                        let resultJson = JSON.init(parseJSON: AppUserDefaults.value(forKey: "AppResultJSON_Data") as! String)
                        self.resultJSON = resultJson
                        NSLog("%@%@", "39220iOS@warehouse: ", "\(self.resultJSON)")
                    }
                    else {
                        NSLog("%@%@", "39220iOS@warehouse: ", "\(self.resultJSON)")
                    }
                }
                    
                    self.gpsTestClose()
                    
                case .notDetermined, .restricted:
                    print("notDetermined of location")
                    
                    self.gpsTimer?.invalidate()
                    self.locationManager.requestAlwaysAuthorization()
                    
                @unknown default:
                    
                    self.gpsTimer?.invalidate()
                    self.locationManager.requestAlwaysAuthorization()
                    
                }
                
            } else {
                
                print("Location services not enabled")
                
                if self.isUserTakeActionForGps {
                    
                    if (AppUserDefaults.value(forKey: "AppResultJSON_Data") != nil) {
                        let resultJson = JSON.init(parseJSON: AppUserDefaults.value(forKey: "AppResultJSON_Data") as! String)
                        self.resultJSON = resultJson
                    }
                    
                    arrTestsResultJSONInSDK.append(0)
                    
                    self.resultJSON["GPS"].int = 0
                    UserDefaults.standard.set(false, forKey: "GPS")
                    
                    AppUserDefaults.setValue(self.resultJSON.rawString(), forKey: "AppResultJSON_Data")
                    DispatchQueue.main.async {
                    if (AppUserDefaults.value(forKey: "AppResultJSON_Data") != nil) {
                        let resultJson = JSON.init(parseJSON: AppUserDefaults.value(forKey: "AppResultJSON_Data") as! String)
                        self.resultJSON = resultJson
                        NSLog("%@%@", "39220iOS@warehouse: ", "\(self.resultJSON)")
                    }
                    else {
                        NSLog("%@%@", "39220iOS@warehouse: ", "\(self.resultJSON)")
                    }
                }
                    
                    self.gpsTestClose()
                    
                }
                else {
                    //self.gpsTimer?.invalidate()
                    //self.locationManager.requestAlwaysAuthorization()
                    
                    if (AppUserDefaults.value(forKey: "AppResultJSON_Data") != nil) {
                        let resultJson = JSON.init(parseJSON: AppUserDefaults.value(forKey: "AppResultJSON_Data") as! String)
                        self.resultJSON = resultJson
                    }
                    
                    arrTestsResultJSONInSDK.append(0)
                    
                    self.resultJSON["GPS"].int = 0
                    UserDefaults.standard.set(false, forKey: "GPS")
                    
                    AppUserDefaults.setValue(self.resultJSON.rawString(), forKey: "AppResultJSON_Data")
                    DispatchQueue.main.async {
                    if (AppUserDefaults.value(forKey: "AppResultJSON_Data") != nil) {
                        let resultJson = JSON.init(parseJSON: AppUserDefaults.value(forKey: "AppResultJSON_Data") as! String)
                        self.resultJSON = resultJson
                        NSLog("%@%@", "39220iOS@warehouse: ", "\(self.resultJSON)")
                    }
                    else {
                        NSLog("%@%@", "39220iOS@warehouse: ", "\(self.resultJSON)")
                    }
                }
                    
                    self.gpsTestClose()
                    
                }
                
            }
            
        }
        
    }
    
}

//MARK: Extenstion for GSM
extension HomeVC {
    
    func gsmLoad() {
        self.gsmTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.runGsmTimer), userInfo: nil, repeats: true)
    }
    
    @objc func runGsmTimer() {        
        self.gsmTest()
        self.gsmCount += 1
    }
    
    func gsmTestClose() {
        self.gsmTimer?.invalidate()
        self.gsmCount = 0
        
        guard let didFinishTestDiagnosis = performDiagnostics else { return }
        didFinishTestDiagnosis(self.resultJSON)        
    }
    
    func gsmTest() {
        
        if self.checkGSM() {
            
            if Luminous.Carrier.mobileCountryCode != nil {
                
                if (AppUserDefaults.value(forKey: "AppResultJSON_Data") != nil) {
                    let resultJson = JSON.init(parseJSON: AppUserDefaults.value(forKey: "AppResultJSON_Data") as! String)
                    self.resultJSON = resultJson
                }
                
                arrTestsResultJSONInSDK.append(1)
                
                self.resultJSON["GSM"].int = 1
                UserDefaults.standard.set(true, forKey: "GSM")
                
                AppUserDefaults.setValue(self.resultJSON.rawString(), forKey: "AppResultJSON_Data")
                DispatchQueue.main.async {
                    if (AppUserDefaults.value(forKey: "AppResultJSON_Data") != nil) {
                        let resultJson = JSON.init(parseJSON: AppUserDefaults.value(forKey: "AppResultJSON_Data") as! String)
                        self.resultJSON = resultJson
                        NSLog("%@%@", "39220iOS@warehouse: ", "\(self.resultJSON)")
                    }
                    else {
                        NSLog("%@%@", "39220iOS@warehouse: ", "\(self.resultJSON)")
                    }
                }
                
                self.gsmTestClose()
                
                return
            }
            
            if Luminous.Carrier.mobileNetworkCode != nil {
                
                if (AppUserDefaults.value(forKey: "AppResultJSON_Data") != nil) {
                    let resultJson = JSON.init(parseJSON: AppUserDefaults.value(forKey: "AppResultJSON_Data") as! String)
                    self.resultJSON = resultJson
                }
                
                arrTestsResultJSONInSDK.append(1)
                
                self.resultJSON["GSM"].int = 1
                UserDefaults.standard.set(true, forKey: "GSM")
                
                AppUserDefaults.setValue(self.resultJSON.rawString(), forKey: "AppResultJSON_Data")
                DispatchQueue.main.async {
                    if (AppUserDefaults.value(forKey: "AppResultJSON_Data") != nil) {
                        let resultJson = JSON.init(parseJSON: AppUserDefaults.value(forKey: "AppResultJSON_Data") as! String)
                        self.resultJSON = resultJson
                        NSLog("%@%@", "39220iOS@warehouse: ", "\(self.resultJSON)")
                    }
                    else {
                        NSLog("%@%@", "39220iOS@warehouse: ", "\(self.resultJSON)")
                    }
                }
                
                self.gsmTestClose()
                
                return
            }
            
            if Luminous.Carrier.ISOCountryCode != nil {
                
                if (AppUserDefaults.value(forKey: "AppResultJSON_Data") != nil) {
                    let resultJson = JSON.init(parseJSON: AppUserDefaults.value(forKey: "AppResultJSON_Data") as! String)
                    self.resultJSON = resultJson
                }
                
                arrTestsResultJSONInSDK.append(1)
                
                self.resultJSON["GSM"].int = 1
                UserDefaults.standard.set(true, forKey: "GSM")
                
                AppUserDefaults.setValue(self.resultJSON.rawString(), forKey: "AppResultJSON_Data")
                DispatchQueue.main.async {
                    if (AppUserDefaults.value(forKey: "AppResultJSON_Data") != nil) {
                        let resultJson = JSON.init(parseJSON: AppUserDefaults.value(forKey: "AppResultJSON_Data") as! String)
                        self.resultJSON = resultJson
                        NSLog("%@%@", "39220iOS@warehouse: ", "\(self.resultJSON)")
                    }
                    else {
                        NSLog("%@%@", "39220iOS@warehouse: ", "\(self.resultJSON)")
                    }
                }
                
                self.gsmTestClose()
                
                return
            }
            
            
            //MARK: ***** TO CHECK GSM TEST WHEN E-SIM AVAILABLE ***** //
            
            // First, check if the currentRadioAccessTechnology is nil
            // It means that no physical Sim card is inserted
            let telephonyInfo = CTTelephonyNetworkInfo()
            
            if #available(iOS 12.0, *) {
                if telephonyInfo.serviceCurrentRadioAccessTechnology == nil {
                    //if telephonyInfo.currentRadioAccessTechnology == nil {
                    
                    // Next, on iOS 12 only, you can check the number of services connected
                    // With the new serviceCurrentRadioAccessTechnology property
                    
                    if let radioTechnologies =
                        telephonyInfo.serviceCurrentRadioAccessTechnology, !radioTechnologies.isEmpty {
                        // One or more radio services has been detected,
                        // the user has one (ore more) eSim package connected to a network
                        
                        if (AppUserDefaults.value(forKey: "AppResultJSON_Data") != nil) {
                            let resultJson = JSON.init(parseJSON: AppUserDefaults.value(forKey: "AppResultJSON_Data") as! String)
                            self.resultJSON = resultJson
                        }
                        
                        arrTestsResultJSONInSDK.append(1)
                        
                        self.resultJSON["GSM"].int = 1
                        UserDefaults.standard.set(true, forKey: "GSM")
                        
                        AppUserDefaults.setValue(self.resultJSON.rawString(), forKey: "AppResultJSON_Data")
                        DispatchQueue.main.async {
                    if (AppUserDefaults.value(forKey: "AppResultJSON_Data") != nil) {
                        let resultJson = JSON.init(parseJSON: AppUserDefaults.value(forKey: "AppResultJSON_Data") as! String)
                        self.resultJSON = resultJson
                        NSLog("%@%@", "39220iOS@warehouse: ", "\(self.resultJSON)")
                    }
                    else {
                        NSLog("%@%@", "39220iOS@warehouse: ", "\(self.resultJSON)")
                    }
                }
                        
                        self.gsmTestClose()
                        
                        return
                    }
                    
                }
                
            } else {
                // Fallback on earlier versions
                
            }
            
            if #available(iOS 12.0, *) {
                if let countryCode = CTTelephonyNetworkInfo().serviceSubscriberCellularProviders?.values.first(where: { $0.isoCountryCode != nil }) {
                    print("Country Code : \(countryCode)")
                    
                    if (AppUserDefaults.value(forKey: "AppResultJSON_Data") != nil) {
                        let resultJson = JSON.init(parseJSON: AppUserDefaults.value(forKey: "AppResultJSON_Data") as! String)
                        self.resultJSON = resultJson
                    }
                    
                    arrTestsResultJSONInSDK.append(1)
                    
                    self.resultJSON["GSM"].int = 1
                    UserDefaults.standard.set(true, forKey: "GSM")
                    
                    AppUserDefaults.setValue(self.resultJSON.rawString(), forKey: "AppResultJSON_Data")
                    DispatchQueue.main.async {
                    if (AppUserDefaults.value(forKey: "AppResultJSON_Data") != nil) {
                        let resultJson = JSON.init(parseJSON: AppUserDefaults.value(forKey: "AppResultJSON_Data") as! String)
                        self.resultJSON = resultJson
                        NSLog("%@%@", "39220iOS@warehouse: ", "\(self.resultJSON)")
                    }
                    else {
                        NSLog("%@%@", "39220iOS@warehouse: ", "\(self.resultJSON)")
                    }
                }
                    
                    self.gsmTestClose()
                    
                    return
                }
                else {
                    
                    if (AppUserDefaults.value(forKey: "AppResultJSON_Data") != nil) {
                        let resultJson = JSON.init(parseJSON: AppUserDefaults.value(forKey: "AppResultJSON_Data") as! String)
                        self.resultJSON = resultJson
                    }
                    
                    arrTestsResultJSONInSDK.append(0)
                    
                    self.resultJSON["GSM"].int = 0
                    UserDefaults.standard.set(false, forKey: "GSM")
                    
                    AppUserDefaults.setValue(self.resultJSON.rawString(), forKey: "AppResultJSON_Data")
                    DispatchQueue.main.async {
                    if (AppUserDefaults.value(forKey: "AppResultJSON_Data") != nil) {
                        let resultJson = JSON.init(parseJSON: AppUserDefaults.value(forKey: "AppResultJSON_Data") as! String)
                        self.resultJSON = resultJson
                        NSLog("%@%@", "39220iOS@warehouse: ", "\(self.resultJSON)")
                    }
                    else {
                        NSLog("%@%@", "39220iOS@warehouse: ", "\(self.resultJSON)")
                    }
                }
                    
                    self.gsmTestClose()
                    
                }
            }
            
            // ***** TO CHECK GSM TEST WHEN E-SIM AVAILABLE ***** //
            
        }else {
            
            if (AppUserDefaults.value(forKey: "AppResultJSON_Data") != nil) {
                let resultJson = JSON.init(parseJSON: AppUserDefaults.value(forKey: "AppResultJSON_Data") as! String)
                self.resultJSON = resultJson
            }
            
            arrTestsResultJSONInSDK.append(-2)
            
            self.resultJSON["GSM"].int = -2
            UserDefaults.standard.set(true, forKey: "GSM")
            
            AppUserDefaults.setValue(self.resultJSON.rawString(), forKey: "AppResultJSON_Data")
            DispatchQueue.main.async {
                    if (AppUserDefaults.value(forKey: "AppResultJSON_Data") != nil) {
                        let resultJson = JSON.init(parseJSON: AppUserDefaults.value(forKey: "AppResultJSON_Data") as! String)
                        self.resultJSON = resultJson
                        NSLog("%@%@", "39220iOS@warehouse: ", "\(self.resultJSON)")
                    }
                    else {
                        NSLog("%@%@", "39220iOS@warehouse: ", "\(self.resultJSON)")
                    }
                }
            
            //if self.gsmCount == 2 {
                self.gsmTestClose()
            //}
            
        }
        
    }
    
    func checkGSM() -> Bool {
        
        if UIApplication.shared.canOpenURL(NSURL(string: "tel://")! as URL) {
            
            // Check if iOS Device supports phone calls
            // User will get an alert error when they will try to make a phone call in airplane mode
            
            if let mnc = CTTelephonyNetworkInfo().subscriberCellularProvider?.mobileNetworkCode, !mnc.isEmpty {
                
                // iOS Device is capable for making calls
                self.isCapableToCall = true
                
            } else {
                
                // Device cannot place a call at this time. SIM might be removed
                self.isCapableToCall = true
                
            }
            
        } else {
            // iOS Device is not capable for making calls
            self.isCapableToCall = false
        }
        
        print("isCapableToCall" , isCapableToCall)
        return self.isCapableToCall
        
    }
    
}

//MARK: Extenstion for Vibrator
extension HomeVC {
    
    func vibratorLoad() {
        self.vibratorTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.runVibratorTimer), userInfo: nil, repeats: true)
    }
    
    @objc func runVibratorTimer() {
        self.vibratorTest()
        self.vibratorCount += 1
    }
    
    func vibratorTestClose() {
        self.manager.stopDeviceMotionUpdates()
        
        self.vibratorTimer?.invalidate()
        self.vibratorCount = 0
        
        guard let didFinishTestDiagnosis = performDiagnostics else { return }
        didFinishTestDiagnosis(self.resultJSON)
    }
    
    func vibratorTest() {
        
        if self.isVibrate {
            
            if (AppUserDefaults.value(forKey: "AppResultJSON_Data") != nil) {
                let resultJson = JSON.init(parseJSON: AppUserDefaults.value(forKey: "AppResultJSON_Data") as! String)
                self.resultJSON = resultJson
            }
            
            arrTestsResultJSONInSDK.append(1)
            
            self.resultJSON["Vibrator"].int = 1
            UserDefaults.standard.set(true, forKey: "Vibrator")
            
            AppUserDefaults.setValue(self.resultJSON.rawString(), forKey: "AppResultJSON_Data")
            DispatchQueue.main.async {
                    if (AppUserDefaults.value(forKey: "AppResultJSON_Data") != nil) {
                        let resultJson = JSON.init(parseJSON: AppUserDefaults.value(forKey: "AppResultJSON_Data") as! String)
                        self.resultJSON = resultJson
                        NSLog("%@%@", "39220iOS@warehouse: ", "\(self.resultJSON)")
                    }
                    else {
                        NSLog("%@%@", "39220iOS@warehouse: ", "\(self.resultJSON)")
                    }
                }
            
            self.vibratorTestClose()
            
        }
        else {
            if self.vibratorCount == 2 {
                
                if (AppUserDefaults.value(forKey: "AppResultJSON_Data") != nil) {
                    let resultJson = JSON.init(parseJSON: AppUserDefaults.value(forKey: "AppResultJSON_Data") as! String)
                    self.resultJSON = resultJson
                }
                
                arrTestsResultJSONInSDK.append(0)
                
                self.resultJSON["Vibrator"].int = 0
                UserDefaults.standard.set(false, forKey: "Vibrator")
                
                AppUserDefaults.setValue(self.resultJSON.rawString(), forKey: "AppResultJSON_Data")
                DispatchQueue.main.async {
                    if (AppUserDefaults.value(forKey: "AppResultJSON_Data") != nil) {
                        let resultJson = JSON.init(parseJSON: AppUserDefaults.value(forKey: "AppResultJSON_Data") as! String)
                        self.resultJSON = resultJson
                        NSLog("%@%@", "39220iOS@warehouse: ", "\(self.resultJSON)")
                    }
                    else {
                        NSLog("%@%@", "39220iOS@warehouse: ", "\(self.resultJSON)")
                    }
                }
                
                self.vibratorTestClose()
            }
        }
        
        
        
        //let manager = CMMotionManager()
        if (manager.isDeviceMotionAvailable) {
            
            manager.deviceMotionUpdateInterval = 0.02
            manager.startDeviceMotionUpdates(to: .main) {
                [weak self] (data: CMDeviceMotion?, error: Error?) in
                
                AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
                
                self?.manager.stopDeviceMotionUpdates()
                
                self?.isVibrate = true
            }
        }else {
            
            if self.vibratorCount == 4 {
                
                if (AppUserDefaults.value(forKey: "AppResultJSON_Data") != nil) {
                    let resultJson = JSON.init(parseJSON: AppUserDefaults.value(forKey: "AppResultJSON_Data") as! String)
                    self.resultJSON = resultJson
                }
                
                arrTestsResultJSONInSDK.append(-2)
                
                self.resultJSON["Vibrator"].int = -2
                UserDefaults.standard.set(true, forKey: "Vibrator")
                
                AppUserDefaults.setValue(self.resultJSON.rawString(), forKey: "AppResultJSON_Data")
                DispatchQueue.main.async {
                    if (AppUserDefaults.value(forKey: "AppResultJSON_Data") != nil) {
                        let resultJson = JSON.init(parseJSON: AppUserDefaults.value(forKey: "AppResultJSON_Data") as! String)
                        self.resultJSON = resultJson
                        NSLog("%@%@", "39220iOS@warehouse: ", "\(self.resultJSON)")
                    }
                    else {
                        NSLog("%@%@", "39220iOS@warehouse: ", "\(self.resultJSON)")
                    }
                }
                
                self.vibratorTestClose()
            }
            
        }
        
        //AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
    }
    
}

class Utility {
    
    enum DeviceLockState {
        case locked
        case unlocked
    }
    
    class func checkDeviceLockState(completion: @escaping (DeviceLockState) -> Void) {
        
       DispatchQueue.main.async {
            if UIApplication.shared.isProtectedDataAvailable {
                completion(.unlocked)
            } else {
                completion(.locked)
            }
        }
    }
    
    class func isJailbroken() -> Bool {
        // Common paths of jailbreak files
        let jailbreakPaths = [
            "/Applications/Cydia.app",
            "/Library/MobileSubstrate/MobileSubstrate.dylib",
            "/bin/bash",
            "/usr/sbin/sshd",
            "/etc/apt",
            "/private/var/lib/apt/"
        ]
        
        for path in jailbreakPaths {
            if FileManager.default.fileExists(atPath: path) {
                return true
            }
        }
        return false
    }
    
    class func canWriteToSystem() -> Bool {
        let testPath = "/private/jailbreakTest.txt"
        do {
            try "test".write(toFile: testPath, atomically: true, encoding: .utf8)
            try FileManager.default.removeItem(atPath: testPath)
            return true
        } catch {
            return false
        }
    }

    
    class func canAccessRestrictedURLs() -> Bool {
        let url = URL(string: "cydia://")! // Cydia URL scheme
        return UIApplication.shared.canOpenURL(url)
    }
    
    func isDeviceJailbroken() -> Bool {
        if Utility.isJailbroken() || Utility.canWriteToSystem() || Utility.canAccessRestrictedURLs() {
            return true
        }
        return false
    }
    
    class func isDeviceSupervised() -> Bool {
        return ProcessInfo.processInfo.isLowPowerModeEnabled
    }
    
    class func isMDMManaged() -> Bool {
        let profilePath = "/var/mobile/Library/ConfigurationProfiles"
        return FileManager.default.fileExists(atPath: profilePath)
    }
    
}
