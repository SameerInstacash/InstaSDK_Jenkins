//
//  GsmVC.swift
//  InstaCashSDK
//
//  Created by Sameer Khan on 29/07/24.
//

import UIKit
import SwiftyJSON
import Luminous
import CoreTelephony

import os

class GsmVC: UIViewController {
    
    @IBOutlet weak var lblTestTitle: UILabel!
    @IBOutlet weak var lblTestDesc: UILabel!
    @IBOutlet weak var loaderImgVW: UIImageView!
    
    var resultJSON = JSON()
    
    var gsmTimer: Timer?
    var gsmCount = 0
    var isCapableToCall : Bool = false
    
    var retryIndex = -1
    var isComingFromTestResult = false
    var gsmRetryDiagnosis: ((_ testJSON: JSON) -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setStatusBarColor(themeColor: GlobalUtility().AppThemeColor)

        self.loaderImgVW.loadGif(name: "ring_loader")                
        
        self.gsmTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.runGsmTimer), userInfo: nil, repeats: true)
                
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        appDelegate_Obj.orientationLock = .portrait
        
        self.setCustomNavigationBar()
        
        self.changeLanguageOfUI()
    }
    
    func changeLanguageOfUI() {
        self.lblTestTitle.text = self.getLocalizatioStringValue(key: "GSM Network")
        self.lblTestDesc.text = self.getLocalizatioStringValue(key: "Please wait we are checking...")
    }
    
    @objc func runGsmTimer() {
        
        self.gsmTest()
        
        self.gsmCount += 1
        
    }
    
    func dismissThisPage() {
        
        //if self.gsmCount == 2 {
        
            self.gsmTimer?.invalidate()
            self.gsmCount = 0                
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.0, execute: {
                
                self.dismiss(animated: false, completion: {
                    guard let didFinishTestDiagnosis = performDiagnostics else { return }
                    didFinishTestDiagnosis(self.resultJSON)
                })
                
            })
                        
        //}
        
    }
    
    func navToSummaryPage() {
        
        self.gsmTimer?.invalidate()
        self.gsmCount = 0
        
        self.dismiss(animated: false, completion: {
            guard let didFinishRetryDiagnosis = self.gsmRetryDiagnosis else { return }
            didFinishRetryDiagnosis(self.resultJSON)
        })
        
    }
    
    func gsmTest() {
        
        if self.checkGSM() {
            
            if Luminous.Carrier.mobileCountryCode != nil {
                
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
                
                self.resultJSON["GSM Network"].int = 1
                UserDefaults.standard.set(true, forKey: "GSM Network")
                
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
                
                return
            }
            
            if Luminous.Carrier.mobileNetworkCode != nil {
                
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
                
                self.resultJSON["GSM Network"].int = 1
                UserDefaults.standard.set(true, forKey: "GSM Network")
                
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
                
                return
            }
            
            if Luminous.Carrier.ISOCountryCode != nil {
                
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
                
                self.resultJSON["GSM Network"].int = 1
                UserDefaults.standard.set(true, forKey: "GSM Network")
                
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
                
                return
            }
            
            
            //MARK: ***** TO CHECK GSM TEST WHEN E-SIM AVAILABLE ***** //
            
            // First, check if the currentRadioAccessTechnology is nil
            // It means that no physical Sim card is inserted
            let telephonyInfo = CTTelephonyNetworkInfo()
            
            if #available(iOS 12.0, *) {
                if telephonyInfo.serviceCurrentRadioAccessTechnology != nil {
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
                                                
                        if self.isComingFromTestResult {
                            arrTestsResultJSONInSDK.remove(at: retryIndex)
                            arrTestsResultJSONInSDK.insert(1, at: retryIndex)
                        }
                        else {
                            arrTestsResultJSONInSDK.append(1)
                        }
                        
                        self.resultJSON["GSM Network"].int = 1
                        UserDefaults.standard.set(true, forKey: "GSM Network")
                        
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
                    
                    if self.isComingFromTestResult {
                        arrTestsResultJSONInSDK.remove(at: retryIndex)
                        arrTestsResultJSONInSDK.insert(1, at: retryIndex)
                    }
                    else {
                        arrTestsResultJSONInSDK.append(1)
                    }
                                        
                    self.resultJSON["GSM Network"].int = 1
                    UserDefaults.standard.set(true, forKey: "GSM Network")
                    
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
                    
                    return
                }
                else {
                    
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
                    
                    self.resultJSON["GSM Network"].int = 0
                    UserDefaults.standard.set(false, forKey: "GSM Network")
                    
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
            
            // ***** TO CHECK GSM TEST WHEN E-SIM AVAILABLE ***** //
            
            
        }else {
            
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
            
            self.resultJSON["GSM Network"].int = -2
            UserDefaults.standard.set(true, forKey: "GSM Network")
            
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
            
            if self.gsmCount == 2 {
                
                if self.isComingFromTestResult {
                    self.navToSummaryPage()
                }
                else {
                    self.dismissThisPage()
                }
                
            }
            
        }
        
    }
    
    // MARK: IBActions
    @IBAction func backButtonPressed(_ sender: UIButton) {
        self.dismiss(animated: true, completion: {
            self.gsmTimer?.invalidate()
            
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
            self.gsmTimer?.invalidate()            
            
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

extension GsmVC {
    
    func checkGSM() -> Bool {
        
        if UIApplication.shared.canOpenURL(NSURL(string: "tel://")! as URL) {
            
            // Check if iOS Device supports phone calls
            // User will get an alert error when they will try to make a phone call in airplane mode
            
            if let mnc = CTTelephonyNetworkInfo().subscriberCellularProvider?.mobileNetworkCode, !mnc.isEmpty {
                
                // iOS Device is capable for making calls
                self.isCapableToCall = true
                
            } else {
                
                // Device cannot place a call at this time. SIM might be removed
                //self.isCapableToCall = true
                self.isCapableToCall = false
                
            }
            
        } else {
            // iOS Device is not capable for making calls
            self.isCapableToCall = false
        }
        
        print("isCapableToCall" , isCapableToCall)
        return self.isCapableToCall
        
    }
    
}
