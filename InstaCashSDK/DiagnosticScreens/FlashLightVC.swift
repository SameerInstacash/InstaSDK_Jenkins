//
//  FlashLightVC.swift
//  InstaCash_Diagnostics
//
//  Created by Sameer Khan on 23/07/24.
//

import UIKit
import SwiftyJSON
import AVFoundation

import os

class FlashLightVC: UIViewController {        
    
    @IBOutlet weak var lblTestTitle: UILabel!
    @IBOutlet weak var lblTestDesc: UILabel!
    @IBOutlet weak var txtFieldNum: UITextField!
    @IBOutlet weak var btnStartFlashing: UIButton!
    @IBOutlet weak var loaderImgVW: UIImageView!
    
    @IBOutlet weak var stkVW1: UIStackView!
    @IBOutlet weak var stkVW2: UIStackView!
    
    @IBOutlet weak var btn1: UIButton!
    @IBOutlet weak var btn2: UIButton!
    @IBOutlet weak var btn3: UIButton!
    @IBOutlet weak var btn4: UIButton!
    
    var resultJSON = JSON()
    var num1 = 0
    var flashTimer: Timer?
    var flashCount = 0
    
    var retryIndex = -1
    var isComingFromTestResult = false
    var flashlightRetryDiagnosis: ((_ testJSON: JSON) -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()

        self.setStatusBarColor(themeColor: GlobalUtility().AppThemeColor)

        self.loaderImgVW.loadGif(name: "ring_loader")
        
        self.changeLanguageOfUI()
        
    }       
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        appDelegate_Obj.orientationLock = .portrait
        
        self.setUIElementsProperties()
        
        self.hideKeyboardWhenTappedAroundView()
        
        self.setCustomNavigationBar()
        
    }
    
    // MARK: Custom Methods
    func changeLanguageOfUI() {
        self.lblTestTitle.text = self.getLocalizatioStringValue(key: "Flashlight")
        //self.lblTestDesc.text = self.getLocalizatioStringValue(key: "Please wait we are checking...")
        self.lblTestDesc.text = self.getLocalizatioStringValue(key: "Please count how many times flashlight blynked")
    }
    
    func setUIElementsProperties() {
        
        self.txtFieldNum.layer.cornerRadius = 20.0
        self.txtFieldNum.layer.borderWidth = 1.0
        self.txtFieldNum.layer.borderColor = UIColor.lightGray.cgColor
        
    }
    
    // MARK: IBActions
    @IBAction func backButtonPressed(_ sender: UIButton) {
        self.dismiss(animated: true, completion: {            
            self.flashTimer?.invalidate()
            
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
            self.flashTimer?.invalidate()
            
            performDiagnostics = nil
        })
    }
    
    @IBAction func startFlashingButtonPressed(_ sender: UIButton) {
        
        if sender.titleLabel?.text == "Start" {
            
            self.btnStartFlashing.isUserInteractionEnabled = false
            
            self.num1 = 0
            self.flashTimer?.invalidate()
            self.flashCount = 0
            
            self.startTest()
            
        }
        else {
            
            guard !(self.txtFieldNum.text?.isEmpty ?? false) else {
                
                DispatchQueue.main.async() {
                    self.view.makeToast("Enter Code", duration: 2.0, position: .bottom)
                }
                
                return
            }
            
            if self.txtFieldNum.text == String(num1) {
                
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
                
                self.resultJSON["Torch"].int = 1
                UserDefaults.standard.set(true, forKey: "Torch")
                
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
                
                self.resultJSON["Torch"].int = 0
                UserDefaults.standard.set(false, forKey: "Torch")
                
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
        
        self.resultJSON["Torch"].int = 1
        UserDefaults.standard.set(true, forKey: "Torch")
        
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
        
        self.resultJSON["Torch"].int = 0
        UserDefaults.standard.set(false, forKey: "Torch")
        
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
    
    func startTest() {
        
        let randomNumber = Int.random(in: 1...4)
        print("Number: \(randomNumber)")
        self.num1 = randomNumber
        
        self.flashTimer = Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(self.runTimedCode), userInfo: nil, repeats: true)
     
    }
    
    @objc func runTimedCode() {
        
        self.flashCount += 1
        
        self.toggleTorch(on: true)
        
        if flashCount == self.num1 {
            self.flashTimer?.invalidate()
            
            //self.txtFieldNum.isHidden = false
            //self.btnStartFlashing.isUserInteractionEnabled = true
            //self.btnStartFlashing.setTitle("Submit", for: .normal)
            
            self.btn1.isHidden = false
            self.btn2.isHidden = false
            self.btn3.isHidden = false
            self.btn4.isHidden = false
            
            self.stkVW1.isHidden = true
            self.stkVW2.isHidden = false
            
        }
        
    }

    func toggleTorch(on: Bool) {
        
        guard let device = AVCaptureDevice.default(for: .video) else { return }

        if device.hasTorch {
            //To on the Torch
            do {
                try device.lockForConfiguration()
                if on == true {
                    device.torchMode = .on
                } else {
                    device.torchMode = .off
                }
                device.unlockForConfiguration()
                
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    
                    //To off the Torch
                    do {
                        try device.lockForConfiguration()
                        if on == true {
                            device.torchMode = .off
                        } else {
                            device.torchMode = .on
                        }
                        device.unlockForConfiguration()
                    } catch {
                        
                        self.flashTimer?.invalidate()
                        
                        DispatchQueue.main.async() {
                            self.view.makeToast("FlashLight not working", duration: 2.0, position: .bottom)
                        }
                        
                    }
                }
                
            } catch {
                
                self.flashTimer?.invalidate()
                
                DispatchQueue.main.async() {
                    self.view.makeToast("FlashLight not working", duration: 2.0, position: .bottom)
                }
                
            }
        } else {
            self.flashTimer?.invalidate()
            
            DispatchQueue.main.async() {
                self.view.makeToast("FlashLight not working", duration: 2.0, position: .bottom)
            }
            
        }
    }
    
    func dismissThisPage() {
        
        self.flashTimer?.invalidate()
        self.flashCount = 0
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.0, execute: {
            
            self.dismiss(animated: false, completion: {
                guard let didFinishTestDiagnosis = performDiagnostics else { return }
                didFinishTestDiagnosis(self.resultJSON)
            })
            
        })
        
    }
    
    func navToSummaryPage() {
        
        self.dismiss(animated: false, completion: {
            guard let didFinishRetryDiagnosis = self.flashlightRetryDiagnosis else { return }
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
