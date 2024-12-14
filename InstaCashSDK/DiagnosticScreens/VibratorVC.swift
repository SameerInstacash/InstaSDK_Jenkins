//
//  VibratorVC.swift
//  InstaCash_Diagnostics
//
//  Created by Sameer Khan on 23/07/24.
//

import UIKit
import SwiftyJSON
import CoreMotion
import AudioToolbox

import os

class VibratorVC: UIViewController {
    
    @IBOutlet weak var lblTestTitle: UILabel!
    @IBOutlet weak var lblTestDesc: UILabel!
    @IBOutlet weak var loaderImgVW: UIImageView!
    
    @IBOutlet weak var btn1: UIButton!
    @IBOutlet weak var btn2: UIButton!
    @IBOutlet weak var btn3: UIButton!
    @IBOutlet weak var btn4: UIButton!
    
    var resultJSON = JSON()
    
    var vibratorTimer: Timer?
    var vibratorCount = 0
    
    let manager = CMMotionManager()
    var isVibrate = false
    
    var retryIndex = -1
    var isComingFromTestResult = false
    var vibratorRetryDiagnosis: ((_ testJSON: JSON) -> Void)?
    
    var num1 = 0
    var runCount = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setStatusBarColor(themeColor: GlobalUtility().AppThemeColor)
        
        self.loaderImgVW.loadGif(name: "ring_loader")
        
        //self.vibratorTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.runVibratorTimer), userInfo: nil, repeats: true)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: {
            self.startTest()
        })
                
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        appDelegate_Obj.orientationLock = .portrait
        
        self.setCustomNavigationBar()
        
        self.changeLanguageOfUI()
    }
    
    func startTest() {
        
        let randomNumber = Int.random(in: 1...4)
        print("Number: \(randomNumber)")
        self.num1 = randomNumber
        
        self.vibratorTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(runTimedCode), userInfo: nil, repeats: true)
     
    }
    
    @objc func runTimedCode() {
        
        runCount += 1
        self.checkVibrator()
        
        if runCount == self.num1 {
            self.vibratorTimer?.invalidate()
            
            self.loaderImgVW.isHidden = true
            
            self.btn1.isHidden = false
            self.btn2.isHidden = false
            self.btn3.isHidden = false
            self.btn4.isHidden = false
        }
        
    }
    
    func checkVibrator() {
        
        let manager = CMMotionManager()
        if manager.isDeviceMotionAvailable {
            manager.deviceMotionUpdateInterval = 0.02
            manager.startDeviceMotionUpdates(to: .main) {
                [weak self] (data: CMDeviceMotion?, error: Error?) in
               
                if let x = data?.userAcceleration.x, x > 0.03 {
                    print("Device Vibrated at: \(x)")
                    manager.stopDeviceMotionUpdates()
                }
            }
        }
        AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
    }
    
    func changeLanguageOfUI() {
        self.lblTestTitle.text = self.getLocalizatioStringValue(key: "Vibrator")
        //self.lblTestDesc.text = self.getLocalizatioStringValue(key: "Please wait we are checking...")
        self.lblTestDesc.text = self.getLocalizatioStringValue(key: "Please count how many times device vibrated")
    }
    
    @objc func runVibratorTimer() {
        self.vibratorTest()
        self.vibratorCount += 1
    }
    
    func dismissThisPage() {
        
        //if self.vibratorCount == 2 {
        
        self.manager.stopDeviceMotionUpdates()
        
        self.vibratorTimer?.invalidate()
        self.vibratorCount = 0
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.0, execute: {
            
            self.dismiss(animated: false, completion: {
                guard let didFinishTestDiagnosis = performDiagnostics else { return }
                didFinishTestDiagnosis(self.resultJSON)
            })
            
        })
        
        //}
        
    }
    
    func navToSummaryPage() {
        
        self.manager.stopDeviceMotionUpdates()
        
        self.vibratorTimer?.invalidate()
        self.vibratorCount = 0
        
        self.dismiss(animated: false, completion: {
            guard let didFinishRetryDiagnosis = self.vibratorRetryDiagnosis else { return }
            didFinishRetryDiagnosis(self.resultJSON)
        })
        
    }
    
    func vibratorTest() {
        
        if self.isVibrate {
            
            if (AppUserDefaults.value(forKey: "AppResultJSON_Data") != nil) {
                let resultJson = JSON.init(parseJSON: AppUserDefaults.value(forKey: "AppResultJSON_Data") as! String)
                self.resultJSON = resultJson
            }
            
            if self.isComingFromTestResult {
                arrTestsResultJSONInSDK.remove(at: retryIndex)
                arrTestsResultJSONInSDK.insert(1, at: retryIndex)
            }
            else {
                arrTestsResultJSONInSDK.append(1)
            }
            
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
            
            self.loaderImgVW.image = UIImage(named: "rightGreen")
                        
            if self.isComingFromTestResult {
                self.navToSummaryPage()
            }
            else {
                self.dismissThisPage()
            }
            
        }
        else {
            if self.vibratorCount == 2 {
                
                if (AppUserDefaults.value(forKey: "AppResultJSON_Data") != nil) {
                    let resultJson = JSON.init(parseJSON: AppUserDefaults.value(forKey: "AppResultJSON_Data") as! String)
                    self.resultJSON = resultJson
                }
                
                if self.isComingFromTestResult {
                    arrTestsResultJSONInSDK.remove(at: retryIndex)
                    arrTestsResultJSONInSDK.insert(0, at: retryIndex)
                }
                else {
                    arrTestsResultJSONInSDK.append(0)
                }
                
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
                                
                if self.isComingFromTestResult {
                    self.navToSummaryPage()
                }
                else {
                    self.dismissThisPage()
                }
                
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
                
                if self.isComingFromTestResult {
                    arrTestsResultJSONInSDK.remove(at: retryIndex)
                    arrTestsResultJSONInSDK.insert(-2, at: retryIndex)
                }
                else {
                    arrTestsResultJSONInSDK.append(-2)
                }
                
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
                                
                if self.isComingFromTestResult {
                    self.navToSummaryPage()
                }
                else {
                    self.dismissThisPage()
                }
                
            }
            
        }
        
        //AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
    }
    
    // MARK: IBActions
    @IBAction func btn1Pressed(_ sender: UIButton) {
        
        if self.num1 == 1 {
            self.passMarkVibratorTest()
        }
        else {
            self.failMarkVibratorTest()
        }
        
    }
    
    @IBAction func btn2Pressed(_ sender: UIButton) {
        
        if self.num1 == 2 {
            self.passMarkVibratorTest()
        }
        else {
            self.failMarkVibratorTest()
        }
        
    }
    
    @IBAction func btn3Pressed(_ sender: UIButton) {
        
        if self.num1 == 3 {
            self.passMarkVibratorTest()
        }
        else {
            self.failMarkVibratorTest()
        }
        
    }
    
    @IBAction func btn4Pressed(_ sender: UIButton) {
        
        if self.num1 == 4 {
            self.passMarkVibratorTest()
        }
        else {
            self.failMarkVibratorTest()
        }
        
    }
    
    func passMarkVibratorTest() {
        
        if (AppUserDefaults.value(forKey: "AppResultJSON_Data") != nil) {
            let resultJson = JSON.init(parseJSON: AppUserDefaults.value(forKey: "AppResultJSON_Data") as! String)
            self.resultJSON = resultJson
        }
        
        if self.isComingFromTestResult {
            arrTestsResultJSONInSDK.remove(at: retryIndex)
            arrTestsResultJSONInSDK.insert(1, at: retryIndex)
        }
        else {
            arrTestsResultJSONInSDK.append(1)
        }
        
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
        
        self.loaderImgVW.image = UIImage(named: "rightGreen")
                    
        if self.isComingFromTestResult {
            self.navToSummaryPage()
        }
        else {
            self.dismissThisPage()
        }
        
    }
    
    func failMarkVibratorTest() {
        
        if (AppUserDefaults.value(forKey: "AppResultJSON_Data") != nil) {
            let resultJson = JSON.init(parseJSON: AppUserDefaults.value(forKey: "AppResultJSON_Data") as! String)
            self.resultJSON = resultJson
        }
        
        if self.isComingFromTestResult {
            arrTestsResultJSONInSDK.remove(at: retryIndex)
            arrTestsResultJSONInSDK.insert(0, at: retryIndex)
        }
        else {
            arrTestsResultJSONInSDK.append(0)
        }
        
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
        
        if self.isComingFromTestResult {
            self.navToSummaryPage()
        }
        else {
            self.dismissThisPage()
        }
        
    }
        
    @IBAction func backButtonPressed(_ sender: UIButton) {
        self.dismiss(animated: true, completion: {
            self.vibratorTimer?.invalidate()
            
            performDiagnostics = nil
        })
    }
    
    func setCustomNavigationBar() {
        
        self.navigationController?.navigationBar.barStyle = .default
        //self.navigationController?.navigationBar.barTintColor = UIColor.lightGray
        self.navigationController?.view.tintColor = .black
                
        //self.navigationController?.hidesBarsOnSwipe = true
                
        if self.isComingFromTestResult {
            
        }
        else {
            self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "backWhite"), style: .plain, target: self, action: #selector(backBtnPressed))
            
            self.title = "\(currentTestIndex)/\(totalTestsCount)"
        }
        
    }
    
    @objc func backBtnPressed() {
        self.dismiss(animated: true, completion: {
            self.vibratorTimer?.invalidate()
            
            performDiagnostics = nil
        })
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    
}
