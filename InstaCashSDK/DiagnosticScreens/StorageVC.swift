//
//  StorageVC.swift
//  InstaCashSDK
//
//  Created by Sameer Khan on 29/07/24.
//

import UIKit
import SwiftyJSON
import Luminous

import os

class StorageVC: UIViewController {
    
    @IBOutlet weak var lblTestTitle: UILabel!
    @IBOutlet weak var lblTestDesc: UILabel!
    @IBOutlet weak var loaderImgVW: UIImageView!
    
    var resultJSON = JSON()
    
    var storageTimer: Timer?
    var storageCount = 0
    
    var retryIndex = -1
    var isComingFromTestResult = false
    var storageRetryDiagnosis: ((_ testJSON: JSON) -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setStatusBarColor(themeColor: GlobalUtility().AppThemeColor)

        self.loaderImgVW.loadGif(name: "ring_loader")                
        
        self.storageTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.runStorageTimer), userInfo: nil, repeats: true)
                
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        appDelegate_Obj.orientationLock = .portrait
        
        self.setCustomNavigationBar()
        
        self.changeLanguageOfUI()
    }
    
    func changeLanguageOfUI() {
        self.lblTestTitle.text = self.getLocalizatioStringValue(key: "Storage")
        self.lblTestDesc.text = self.getLocalizatioStringValue(key: "Please wait we are checking...")
    }
    
    @objc func runStorageTimer() {
        
        self.storageTest()
        
        self.storageCount += 1
        
    }
    
    func dismissThisPage() {
        
        //if self.storageCount == 2 {
        
            self.storageTimer?.invalidate()
            self.storageCount = 0            
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.0, execute: {
                
                self.dismiss(animated: false, completion: {
                    guard let didFinishTestDiagnosis = performDiagnostics else { return }
                    didFinishTestDiagnosis(self.resultJSON)
                })
                
            })
                        
        //}
        
    }
    
    func navToSummaryPage() {
        
        self.storageTimer?.invalidate()
        self.storageCount = 0
        
        self.dismiss(animated: false, completion: {
            guard let didFinishRetryDiagnosis = self.storageRetryDiagnosis else { return }
            didFinishRetryDiagnosis(self.resultJSON)
        })
        
    }
    
    func storageTest() {
        
        if Luminous.Hardware.physicalMemory(with: .kilobytes) > 1024.0 {
            
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
            
            self.loaderImgVW.image = UIImage(named: "rightGreen")         
            
            if self.isComingFromTestResult {
                self.navToSummaryPage()
            }
            else {
                self.dismissThisPage()
            }
            
        }else {
            
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
            
            if self.storageCount == 2 {
                
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
            self.storageTimer?.invalidate()
            
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
            self.storageTimer?.invalidate()           
            
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
