//
//  BiometricVC.swift
//  InstaCash_Diagnostics
//
//  Created by Sameer Khan on 23/07/24.
//

import UIKit
import SwiftyJSON
import LocalAuthentication
import BiometricAuthentication

import os

enum BiometricType {
    case none
    case touch
    case face
    case optic
}

class BiometricVC: UIViewController {
    
    @IBOutlet weak var lblTestTitle: UILabel!
    @IBOutlet weak var supportedTestImgVW: UIImageView!
    @IBOutlet weak var lblTestDesc: UILabel!
    @IBOutlet weak var btnStartTest: UIButton!
    
    var resultJSON = JSON()
    
    var retryIndex = -1
    var isComingFromTestResult = false
    var biometricRetryDiagnosis: ((_ testJSON: JSON) -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()

        self.setStatusBarColor(themeColor: GlobalUtility().AppThemeColor)
                
        self.handleUIAccordingToBiometricType()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        appDelegate_Obj.orientationLock = .portrait
        
        self.setCustomNavigationBar()
        
        if !BioMetricAuthenticator.canAuthenticate() {
            self.promptForBiometricEnable()
        }
        
    }
    
    // MARK: IBActions
    @IBAction func startButtonPressed(_ sender: UIButton) {
        
        BioMetricAuthenticator.authenticateWithBioMetrics(reason: "") { (result) in
            
            switch result {
            case .success( _):
                
                print("Authentication Successful")
                
                if (AppUserDefaults.value(forKey: "AppResultJSON_Data") != nil) {
                    let resultJson = JSON.init(parseJSON: AppUserDefaults.value(forKey: "AppResultJSON_Data") as! String)
                    self.resultJSON = resultJson
                }
                
                if self.isComingFromTestResult {
                    arrTestsResultJSONInSDK.remove(at: self.retryIndex)
                    arrTestsResultJSONInSDK.insert(1, at: self.retryIndex)
                }
                else {
                    arrTestsResultJSONInSDK.append(1)
                }
                
                UserDefaults.standard.set(true, forKey: "fingerprint")
                self.resultJSON["Fingerprint Scanner"].int = 1
                
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
                
            case .failure(let error):
                                
                print("error.message" , error.message(), error)
                
                // do nothing on canceledr
                if error == .canceledByUser || error == .canceledBySystem {
                    
                    if (AppUserDefaults.value(forKey: "AppResultJSON_Data") != nil) {
                        let resultJson = JSON.init(parseJSON: AppUserDefaults.value(forKey: "AppResultJSON_Data") as! String)
                        self.resultJSON = resultJson
                    }
                    
                    if self.isComingFromTestResult {
                        arrTestsResultJSONInSDK.remove(at: self.retryIndex)
                        arrTestsResultJSONInSDK.insert(0, at: self.retryIndex)
                    }
                    else {
                        arrTestsResultJSONInSDK.append(0)
                    }
                    
                    UserDefaults.standard.set(false, forKey: "fingerprint")
                    self.resultJSON["Fingerprint Scanner"].int = 0
                    
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
                    
                    return
                }
                // device does not support biometric (face id or touch id) authentication
                else if error == .biometryNotAvailable {
                    
                    if (AppUserDefaults.value(forKey: "AppResultJSON_Data") != nil) {
                        let resultJson = JSON.init(parseJSON: AppUserDefaults.value(forKey: "AppResultJSON_Data") as! String)
                        self.resultJSON = resultJson
                    }
                    
                    if self.isComingFromTestResult {
                        arrTestsResultJSONInSDK.remove(at: self.retryIndex)
                        arrTestsResultJSONInSDK.insert(-2, at: self.retryIndex)
                    }
                    else {
                        arrTestsResultJSONInSDK.append(-2)
                    }
                    
                    UserDefaults.standard.set(true, forKey: "fingerprint")
                    self.resultJSON["Fingerprint Scanner"].int = -2
                    
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
                    
                    /*
                    DispatchQueue.main.async {
                        self.view.makeToast("\(error.message())", duration: 2.0, position: .bottom)
                    }
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.4) {
                        self.dismissThisPage()
                    }
                    */
                    
                }
                // show alternatives on fallback button clicked
                else if error == .fallback {
                    
                    if (AppUserDefaults.value(forKey: "AppResultJSON_Data") != nil) {
                        let resultJson = JSON.init(parseJSON: AppUserDefaults.value(forKey: "AppResultJSON_Data") as! String)
                        self.resultJSON = resultJson
                    }
                    
                    if self.isComingFromTestResult {
                        arrTestsResultJSONInSDK.remove(at: self.retryIndex)
                        arrTestsResultJSONInSDK.insert(0, at: self.retryIndex)
                    }
                    else {
                        arrTestsResultJSONInSDK.append(0)
                    }
                    
                    UserDefaults.standard.set(false, forKey: "fingerprint")
                    self.resultJSON["Fingerprint Scanner"].int = 0
                    
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
                    
                    /*
                    // here we're entering username and password
                    DispatchQueue.main.async {
                        self.view.makeToast("\(error.message())", duration: 2.0, position: .bottom)
                    }
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.4) {
                        self.dismissThisPage()
                    }
                    */
                    
                }
                // No biometry enrolled in this device, ask user to register fingerprint or face
                else if error == .biometryNotEnrolled {
                    
                    if (AppUserDefaults.value(forKey: "AppResultJSON_Data") != nil) {
                        let resultJson = JSON.init(parseJSON: AppUserDefaults.value(forKey: "AppResultJSON_Data") as! String)
                        self.resultJSON = resultJson
                    }
                    
                    if self.isComingFromTestResult {
                        arrTestsResultJSONInSDK.remove(at: self.retryIndex)
                        arrTestsResultJSONInSDK.insert(0, at: self.retryIndex)
                    }
                    else {
                        arrTestsResultJSONInSDK.append(0)
                    }
                    
                    UserDefaults.standard.set(false, forKey: "fingerprint")
                    self.resultJSON["Fingerprint Scanner"].int = 0
                    
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
                    
                    /*
                    DispatchQueue.main.async {
                        self.view.makeToast("\(error.message())", duration: 2.0, position: .bottom)
                    }
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.4) {
                        self.dismissThisPage()
                    }
                    */
                    
                }
                // Biometry is locked out now, because there were too many failed attempts.
                // Need to enter device passcode to unlock.
                else if error == .biometryLockedout {
                    
                    if (AppUserDefaults.value(forKey: "AppResultJSON_Data") != nil) {
                        let resultJson = JSON.init(parseJSON: AppUserDefaults.value(forKey: "AppResultJSON_Data") as! String)
                        self.resultJSON = resultJson
                    }
                    
                    if self.isComingFromTestResult {
                        arrTestsResultJSONInSDK.remove(at: self.retryIndex)
                        arrTestsResultJSONInSDK.insert(0, at: self.retryIndex)
                    }
                    else {
                        arrTestsResultJSONInSDK.append(0)
                    }
                    
                    UserDefaults.standard.set(false, forKey: "fingerprint")
                    self.resultJSON["Fingerprint Scanner"].int = 0
                    
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
                    
                    /*
                    // show passcode authentication
                    DispatchQueue.main.async {
                        self.view.makeToast("\(error.message())", duration: 2.0, position: .bottom)
                    }
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.4) {
                        self.dismissThisPage()
                    }
                    */
                    
                }
                // show error on authentication failed
                else {
                    
                    if (AppUserDefaults.value(forKey: "AppResultJSON_Data") != nil) {
                        let resultJson = JSON.init(parseJSON: AppUserDefaults.value(forKey: "AppResultJSON_Data") as! String)
                        self.resultJSON = resultJson
                    }
                    
                    if self.isComingFromTestResult {
                        arrTestsResultJSONInSDK.remove(at: self.retryIndex)
                        arrTestsResultJSONInSDK.insert(0, at: self.retryIndex)
                    }
                    else {
                        arrTestsResultJSONInSDK.append(0)
                    }
                    
                    UserDefaults.standard.set(false, forKey: "fingerprint")
                    self.resultJSON["Fingerprint Scanner"].int = 0
                    
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
                    
                    /*
                    DispatchQueue.main.async() {
                        self.view.makeToast("\(error.message())", duration: 2.0, position: .bottom)
                    }
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.4) {
                        self.dismissThisPage()
                    }
                    */
                    
                }
                
            }
            
        }
        
    }
    
    //MARK: Custom Methods
    func handleUIAccordingToBiometricType() {
        
        let currentBiometric = checkBiometricType()
        print("currentBiometric -> " , currentBiometric)
        
        if currentBiometric == .face {
            
            self.lblTestTitle.text = "Face ID"
            self.lblTestDesc.text = "Please enable the face-Id feature from settings." + "\n" + "Disabling the face-Id will result in price drop during evaluation"
            self.supportedTestImgVW.image = UIImage(named: "face-id")
            
        }
        else if currentBiometric == .touch {
            
            self.lblTestTitle.text = "Touch ID"
            self.lblTestDesc.text = "Please enable the fingerprint feature from settings." + "\n" + "Disabling the fingerprint scanner will result in price drop during evaluation"
            self.supportedTestImgVW.image = UIImage(named: "fingerprint scanner")
            
        }
        else if currentBiometric == .optic {
            
            self.lblTestTitle.text = "Optic ID"
            self.lblTestDesc.text = "Please enable the Optic-Id feature from settings." + "\n" + "Disabling the Optic-Id will result in price drop during evaluation"
            self.supportedTestImgVW.image = UIImage(named: "optic-id")
            
        }
        else {
            
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
            
            UserDefaults.standard.set(true, forKey: "fingerprint")
            self.resultJSON["Fingerprint Scanner"].int = -2
            
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
    
    func promptForBiometricEnable() {
        
        DispatchQueue.main.async {
            
            let alertController = UIAlertController (title:  "Enable Biometric" , message: "Go to Settings -> Touch ID & Passcode", preferredStyle: .alert)
            
            let settingsAction = UIAlertAction(title: "Settings", style: .default) { (_) -> Void in
                
                guard let settingsUrl = URL(string: "App-Prefs:root") else {
                    return
                }
                
                if UIApplication.shared.canOpenURL(settingsUrl) {
                    if #available(iOS 10.0, *) {
                        
                        UIApplication.shared.open(settingsUrl, options: [:]) { (success) in
                        }
                        
                    } else {
                        // Fallback on earlier versions
                        UIApplication.shared.openURL(settingsUrl)
                    }
                }
            }
                        
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .default) { (_) -> Void in
                
                if (AppUserDefaults.value(forKey: "AppResultJSON_Data") != nil) {
                    let resultJson = JSON.init(parseJSON: AppUserDefaults.value(forKey: "AppResultJSON_Data") as! String)
                    self.resultJSON = resultJson
                }
                
                if self.isComingFromTestResult {
                    arrTestsResultJSONInSDK.remove(at: self.retryIndex)
                    arrTestsResultJSONInSDK.insert(0, at: self.retryIndex)
                }
                else {
                    arrTestsResultJSONInSDK.append(0)
                }
                
                UserDefaults.standard.set(false, forKey: "fingerprint")
                self.resultJSON["Fingerprint Scanner"].int = 0
                
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
            
            alertController.addAction(settingsAction)
            alertController.addAction(cancelAction)
            
            alertController.popoverPresentationController?.sourceView = self.view
            alertController.popoverPresentationController?.sourceRect = self.view.bounds
            self.present(alertController, animated: true, completion: nil)
            
        }
        
    }
    
    func checkBiometricType() -> BiometricType {
        let authContext = LAContext()
        
        if #available(iOS 11, *) {
            let _ = authContext.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil)
            switch(authContext.biometryType) {
            case .none:
                return .none
            case .touchID:
                return .touch
            case .faceID:
                return .face
            case .opticID:
                return .optic
            @unknown default:
                return .none
            }
        } else {
            return authContext.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil) ? .touch : .none
        }
        
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
            performDiagnostics = nil
        })
    }
    
    func dismissThisPage() {
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.0, execute: {
            
            self.dismiss(animated: false, completion: {
                guard let didFinishTestDiagnosis = performDiagnostics else { return }
                didFinishTestDiagnosis(self.resultJSON)
            })
            
        })
        
    }
    
    func navToSummaryPage() {
        
        self.dismiss(animated: false, completion: {
            guard let didFinishRetryDiagnosis = self.biometricRetryDiagnosis else { return }
            didFinishRetryDiagnosis(self.resultJSON)
        })
        
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }


}
