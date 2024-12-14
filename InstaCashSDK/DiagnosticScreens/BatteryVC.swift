//
//  BatteryVC.swift
//  InstaCashSDK
//
//  Created by Sameer Khan on 29/07/24.
//

import UIKit
import SwiftyJSON
import SwiftGifOrigin
import Luminous

import os

class BatteryVC: UIViewController {
    
    @IBOutlet weak var lblTestTitle: UILabel!
    @IBOutlet weak var lblTestDesc: UILabel!
    @IBOutlet weak var loaderImgVW: UIImageView!
    
    var resultJSON = JSON()
    
    var batteryTimer: Timer?
    var batteryCount = 0
    
    var retryIndex = -1
    var isComingFromTestResult = false
    var batteryRetryDiagnosis: ((_ testJSON: JSON) -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setStatusBarColor(themeColor: GlobalUtility().AppThemeColor)

        self.loaderImgVW.loadGif(name: "ring_loader")
        
        self.batteryTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.runBatteryTimer), userInfo: nil, repeats: true)
                
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        appDelegate_Obj.orientationLock = .portrait
        
        self.setCustomNavigationBar()
        
        self.changeLanguageOfUI()
    }
    
    func changeLanguageOfUI() {
        self.lblTestTitle.text = self.getLocalizatioStringValue(key: "Battery")
        self.lblTestDesc.text = self.getLocalizatioStringValue(key: "Please wait we are checking...")
    }
        
    @objc func runBatteryTimer() {
        
        self.batteryTest()
        
        self.batteryCount += 1
        
    }
    
    func dismissThisPage() {
        
        //if self.batteryCount == 2 {
        
            self.batteryTimer?.invalidate()
            self.batteryCount = 0
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.0, execute: {
                
                //guard let didFinishTestDiagnosis = performDiagnostics else { return }
                //didFinishTestDiagnosis(self.resultJSON)
                //self.dismiss(animated: false, completion: nil)
                                
                
                self.dismiss(animated: false, completion: {
                    guard let didFinishTestDiagnosis = performDiagnostics else { return }
                    didFinishTestDiagnosis(self.resultJSON)
                })
            })
        //}
        
    }
    
    func navToSummaryPage() {
        
        self.batteryTimer?.invalidate()
        self.batteryCount = 0
        
        self.dismiss(animated: false, completion: {
            guard let didFinishRetryDiagnosis = self.batteryRetryDiagnosis else { return }
            didFinishRetryDiagnosis(self.resultJSON)
        })
        
    }
    
    func batteryTest() {
        
        if Luminous.Battery.state == .unknown {
            
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
            
            if self.batteryCount == 2 {
                
                if self.isComingFromTestResult {
                    self.navToSummaryPage()
                }
                else {
                    self.dismissThisPage()
                }
            }
            
        } else {
            
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
            
            self.loaderImgVW.image = UIImage(named: "rightGreen")            
            
            if self.isComingFromTestResult {
                self.navToSummaryPage()
            }
            else {
                self.dismissThisPage()
            }
            
        }
        
    }
    
    // MARK: IBActions
    @IBAction func backButtonPressed(_ sender: UIButton) {
        self.dismiss(animated: true, completion: {
            self.batteryTimer?.invalidate()
            
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
            self.batteryTimer?.invalidate()    
            
            performDiagnostics = nil
        })
        
        /*
        _ = self.navigationController?.popToRootViewController(animated: true)
        
        let controllers = self.navigationController?.viewControllers
        for vc in controllers! {
            if vc is DiagnoseVC {
                _ = self.navigationController?.popToViewController(vc as! DiagnoseVC, animated: true)
            }
        }
        */
        
    }
    
    // MARK: - Navigation
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }

}
