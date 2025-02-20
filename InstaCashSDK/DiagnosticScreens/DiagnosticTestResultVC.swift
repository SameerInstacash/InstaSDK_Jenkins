//
//  DiagnosticTestResultVC.swift
//  InstaCash_Diagnostics
//
//  Created by Sameer Khan on 23/07/24.
//

import UIKit
import SwiftyJSON

import os

class ModelCompleteDiagnosticFlow: NSObject {
    var priority = 0
    var strTestName = ""
    var strSuccess = ""
}

class DiagnosticTestResultVC: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var summaryTableView: UITableView!
    
    var resultJSON = JSON()
    var arrPassedTest = [ModelCompleteDiagnosticFlow]()
    var arrFailedTest = [ModelCompleteDiagnosticFlow]()
    var arrSkippedTest = [ModelCompleteDiagnosticFlow]()
    
    var submitDiagnoseData: ((_ testJSON: JSON) -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()

        self.setStatusBarColor(themeColor: GlobalUtility().AppThemeColor)
        
        self.summaryTableView.register(UINib(nibName: "TestResultCell", bundle: nil), forCellReuseIdentifier: "TestResultCell")
        self.summaryTableView.register(UINib(nibName: "TestResultTitleCell", bundle: nil), forCellReuseIdentifier: "TestResultTitleCell")
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        appDelegate_Obj.orientationLock = .portrait
        
        self.setCustomNavigationBar()
        
        self.groupingAllTests()
    }
    
    //MARK: IBAction
    @IBAction func doneButtonClicked(_ sender: UIButton) {
        print("resultJSON on Test Summary page :", self.resultJSON)
        
        self.dismiss(animated: false, completion: {
            guard let didFinishDiagnosis = self.submitDiagnoseData else { return }
            didFinishDiagnosis(self.resultJSON)
        })
        
    }
    
    //MARK: Custom Methods
    func groupingAllTests() {
        
        self.arrPassedTest = []
        self.arrSkippedTest = []
        self.arrFailedTest = []
            
        
        //MARK: 1. Battery Test
        if self.resultJSON["Battery"].int != nil {
            
            let model = ModelCompleteDiagnosticFlow()
            model.strTestName = "Battery"
            
            if self.resultJSON["Battery"].int == 1 {
                self.arrPassedTest.append(model)
            }
            else if self.resultJSON["Battery"].int == -1 {
                self.arrSkippedTest.append(model)
            }
            else if self.resultJSON["Battery"].int == 0 {
                self.arrFailedTest.append(model)
            }
            else {
                
            }
        }
        
        //MARK: 2. GSM Test
        if self.resultJSON["GSM Network"].int != nil {
            
            let model = ModelCompleteDiagnosticFlow()
            model.strTestName = "GSM Network"
            
            if self.resultJSON["GSM Network"].int == 1 {
                self.arrPassedTest.append(model)
            }
            else if self.resultJSON["GSM Network"].int == -1 {
                self.arrSkippedTest.append(model)
            }
            else if self.resultJSON["GSM Network"].int == 0 {
                self.arrFailedTest.append(model)
            }
            else {
                
            }
        }
        
        //MARK: 3. Storage Test
        if self.resultJSON["Storage"].int != nil {
            
            let model = ModelCompleteDiagnosticFlow()
            model.strTestName = "Storage"
            
            if self.resultJSON["Storage"].int == 1 {
                self.arrPassedTest.append(model)
            }
            else if self.resultJSON["Storage"].int == -1 {
                self.arrSkippedTest.append(model)
            }
            else if self.resultJSON["Storage"].int == 0 {
                self.arrFailedTest.append(model)
            }
            else {
                
            }
        }
                
        //MARK: 4. WiFi Test
        if self.resultJSON["WiFi"].int != nil {
            
            let model = ModelCompleteDiagnosticFlow()
            model.strTestName = "WiFi"
            
            if self.resultJSON["WiFi"].int == 1 {
                self.arrPassedTest.append(model)
            }
            else if self.resultJSON["WiFi"].int == -1 {
                self.arrSkippedTest.append(model)
            }
            else if self.resultJSON["WiFi"].int == 0 {
                self.arrFailedTest.append(model)
            }
            else {
                
            }
        }
        
        //MARK: 5. Bluetooth Test
        if self.resultJSON["Bluetooth"].int != nil {
            
            let model = ModelCompleteDiagnosticFlow()
            model.strTestName = "Bluetooth"
            
            if self.resultJSON["Bluetooth"].int == 1 {
                self.arrPassedTest.append(model)
            }
            else if self.resultJSON["Bluetooth"].int == -1 {
                self.arrSkippedTest.append(model)
            }
            else if self.resultJSON["Bluetooth"].int == 0 {
                self.arrFailedTest.append(model)
            }
            else {
                
            }
        }
        
        //MARK: 6. GPS Test
        if self.resultJSON["GPS"].int != nil {
            
            let model = ModelCompleteDiagnosticFlow()
            model.strTestName = "GPS"
            
            if self.resultJSON["GPS"].int == 1 {
                self.arrPassedTest.append(model)
            }
            else if self.resultJSON["GPS"].int == -1 {
                self.arrSkippedTest.append(model)
            }
            else if self.resultJSON["GPS"].int == 0 {
                self.arrFailedTest.append(model)
            }
            else {
                
            }
        }
        
        //MARK: 7. Vibrator Test
        if self.resultJSON["Vibrator"].int != nil {
            
            let model = ModelCompleteDiagnosticFlow()
            model.strTestName = "Vibrator"
            
            if self.resultJSON["Vibrator"].int == 1 {
                self.arrPassedTest.append(model)
            }
            else if self.resultJSON["Vibrator"].int == -1 {
                self.arrSkippedTest.append(model)
            }
            else if self.resultJSON["Vibrator"].int == 0 {
                self.arrFailedTest.append(model)
            }
            else {
                
            }
        }
        
        //MARK: 8. Speaker Test
        if self.resultJSON["Top Speakers"].int != nil {
            
            let model = ModelCompleteDiagnosticFlow()
            model.strTestName = "Top Speakers"
            
            if self.resultJSON["Top Speakers"].int == 1 {
                self.arrPassedTest.append(model)
            }
            else if self.resultJSON["Top Speakers"].int == -1 {
                self.arrSkippedTest.append(model)
            }
            else if self.resultJSON["Top Speakers"].int == 0 {
                self.arrFailedTest.append(model)
            }
            else {
                
            }
        }
        
        if self.resultJSON["Bottom Speakers"].int != nil {
            
            let model = ModelCompleteDiagnosticFlow()
            model.strTestName = "Bottom Speakers"
            
            if self.resultJSON["Bottom Speakers"].int == 1 {
                self.arrPassedTest.append(model)
            }
            else if self.resultJSON["Bottom Speakers"].int == -1 {
                self.arrSkippedTest.append(model)
            }
            else if self.resultJSON["Bottom Speakers"].int == 0 {
                self.arrFailedTest.append(model)
            }
            else {
                
            }
        }
        
        //MARK: 9. Mic Test
        if self.resultJSON["Top Microphone"].int != nil {
            
            let model = ModelCompleteDiagnosticFlow()
            model.strTestName = "Top Microphone"
            
            if self.resultJSON["Top Microphone"].int == 1 {
                self.arrPassedTest.append(model)
            }
            else if self.resultJSON["Top Microphone"].int == -1 {
                self.arrSkippedTest.append(model)
            }
            else if self.resultJSON["Top Microphone"].int == 0 {
                self.arrFailedTest.append(model)
            }
            else {
                
            }
        }
        
        if self.resultJSON["Bottom Microphone"].int != nil {
            
            let model = ModelCompleteDiagnosticFlow()
            model.strTestName = "Bottom Microphone"
            
            if self.resultJSON["Bottom Microphone"].int == 1 {
                self.arrPassedTest.append(model)
            }
            else if self.resultJSON["Bottom Microphone"].int == -1 {
                self.arrSkippedTest.append(model)
            }
            else if self.resultJSON["Bottom Microphone"].int == 0 {
                self.arrFailedTest.append(model)
            }
            else {
                
            }
        }
        
        //MARK: 10. FlashLight Test
        if self.resultJSON["Torch"].int != nil {
            
            let model = ModelCompleteDiagnosticFlow()
            model.strTestName = "FlashLight"
            
            if self.resultJSON["Torch"].int == 1 {
                self.arrPassedTest.append(model)
            }
            else if self.resultJSON["Torch"].int == -1 {
                self.arrSkippedTest.append(model)
            }
            else if self.resultJSON["Torch"].int == 0 {
                self.arrFailedTest.append(model)
            }
            else {
                
            }
        }
        
        //MARK: 11. Earphone Test
        if self.resultJSON["Earphone Jack"].int != nil {
            
            let model = ModelCompleteDiagnosticFlow()
            model.strTestName = "Earphone Jack"
            
            if self.resultJSON["Earphone Jack"].int == 1 {
                self.arrPassedTest.append(model)
            }
            else if self.resultJSON["Earphone Jack"].int == -1 {
                self.arrSkippedTest.append(model)
            }
            else if self.resultJSON["Earphone Jack"].int == 0 {
                self.arrFailedTest.append(model)
            }
            else {
                
            }
        }
        
        //MARK: 12. Rotation Test
        if self.resultJSON["Auto Rotation"].int != nil {
            
            let model = ModelCompleteDiagnosticFlow()
            model.strTestName = "Auto Rotation"
            
            if self.resultJSON["Auto Rotation"].int == 1 {
                self.arrPassedTest.append(model)
            }
            else if self.resultJSON["Auto Rotation"].int == -1 {
                self.arrSkippedTest.append(model)
            }
            else if self.resultJSON["Auto Rotation"].int == 0 {
                self.arrFailedTest.append(model)
            }
            else {
                
            }
        }
        
        //MARK: 13. Proximity Test
        if self.resultJSON["Proximity"].int != nil {
            
            let model = ModelCompleteDiagnosticFlow()
            model.strTestName = "Proximity"
            
            if self.resultJSON["Proximity"].int == 1 {
                self.arrPassedTest.append(model)
            }
            else if self.resultJSON["Proximity"].int == -1 {
                self.arrSkippedTest.append(model)
            }
            else if self.resultJSON["Proximity"].int == 0 {
                self.arrFailedTest.append(model)
            }
            else {
                
            }
        }
        
        //MARK: 14. USB Test
        if self.resultJSON["USB Slot"].int != nil {
            
            let model = ModelCompleteDiagnosticFlow()
            model.strTestName = "USB Slot"
            
            if self.resultJSON["USB Slot"].int == 1 {
                self.arrPassedTest.append(model)
            }
            else if self.resultJSON["USB Slot"].int == -1 {
                self.arrSkippedTest.append(model)
            }
            else if self.resultJSON["USB Slot"].int == 0 {
                self.arrFailedTest.append(model)
            }
            else {
                
            }
        }
        
        //MARK: 15. Dead-Pixels Test
        if self.resultJSON["Dead Pixel"].int != nil {
            
            let model = ModelCompleteDiagnosticFlow()
            model.strTestName = "Dead Pixel"
            
            if self.resultJSON["Dead Pixel"].int == 1 {
                self.arrPassedTest.append(model)
            }
            else if self.resultJSON["Dead Pixel"].int == -1 {
                self.arrSkippedTest.append(model)
            }
            else if self.resultJSON["Dead Pixel"].int == 0 {
                self.arrFailedTest.append(model)
            }
            else {
                
            }
        }
        
        //MARK: 16. Camera Test
        if self.resultJSON["Camera"].int != nil {
            
            let model = ModelCompleteDiagnosticFlow()
            model.strTestName = "Camera"
            
            if self.resultJSON["Camera"].int == 1 {
                self.arrPassedTest.append(model)
            }
            else if self.resultJSON["Camera"].int == -1 {
                self.arrSkippedTest.append(model)
            }
            else if self.resultJSON["Camera"].int == 0 {
                self.arrFailedTest.append(model)
            }
            else {
                
            }
        }
        
        //MARK: 17. AutoFocus Test
        if self.resultJSON["Autofocus"].int != nil {
            
            let model = ModelCompleteDiagnosticFlow()
            model.strTestName = "Autofocus"
            
            if self.resultJSON["Autofocus"].int == 1 {
                self.arrPassedTest.append(model)
            }
            else if self.resultJSON["Autofocus"].int == -1 {
                self.arrSkippedTest.append(model)
            }
            else if self.resultJSON["Autofocus"].int == 0 {
                self.arrFailedTest.append(model)
            }
            else {
                
            }
        }
        
        //MARK: 18. Screen-Calibration Test
        if self.resultJSON["Touch Screen"].int != nil {
            
            let model = ModelCompleteDiagnosticFlow()
            model.strTestName = "Touch Screen"
            
            if self.resultJSON["Touch Screen"].int == 1 {
                self.arrPassedTest.append(model)
            }
            else if self.resultJSON["Touch Screen"].int == -1 {
                self.arrSkippedTest.append(model)
            }
            else if self.resultJSON["Touch Screen"].int == 0 {
                self.arrFailedTest.append(model)
            }
            else {
                
            }
        }
        
        //MARK: 19. Volume-Button Test
        if self.resultJSON["Device Button"].int != nil {
            
            let model = ModelCompleteDiagnosticFlow()
            model.strTestName = "Device Button"
            
            if self.resultJSON["Device Button"].int == 1 {
                self.arrPassedTest.append(model)
            }
            else if self.resultJSON["Device Button"].int == -1 {
                self.arrSkippedTest.append(model)
            }
            else if self.resultJSON["Device Button"].int == 0 {
                self.arrFailedTest.append(model)
            }
            else {
                
            }
        }
        
        //MARK: 20. Biometric Test
        if self.resultJSON["Finger Print"].int != nil {
            
            let model = ModelCompleteDiagnosticFlow()
            model.strTestName = "Biometric"
            
            if self.resultJSON["Finger Print"].int == 1 {
                self.arrPassedTest.append(model)
            }
            else if self.resultJSON["Finger Print"].int == -1 {
                self.arrSkippedTest.append(model)
            }
            else if self.resultJSON["Finger Print"].int == 0 {
                self.arrFailedTest.append(model)
            }
            else {
                
            }
        }
             
        
        self.summaryTableView.dataSource = self
        self.summaryTableView.delegate = self
        
    }
    
    func setCustomNavigationBar() {
        
        self.navigationController?.navigationBar.barStyle = .default
        self.navigationController?.view.tintColor = .black
                
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "backWhite"), style: .plain, target: self, action: #selector(backBtnPressed))
        
        self.title = "Test Summary"
    }
    
    @objc func backBtnPressed() {
        self.dismiss(animated: true, completion: {
            performDiagnostics = nil
        })
    }
    
    //MARK: UITableView DataSource & Delegates
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        switch section {
        case 0:
            return (self.arrPassedTest.count > 0) ? (self.arrPassedTest.count + 1) : 0
        case 1:
            return (self.arrSkippedTest.count > 0) ? (self.arrSkippedTest.count + 1) : 0
        default:
            return (self.arrFailedTest.count > 0) ? (self.arrFailedTest.count + 1) : 0
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch indexPath.section {
        case 0:
            
            if indexPath.row == 0 {
                
                let passTitleCell = tableView.dequeueReusableCell(withIdentifier: "TestResultTitleCell", for: indexPath) as! TestResultTitleCell
                passTitleCell.lblTitle.text = "Passed Tests"
                passTitleCell.lblSeperator.isHidden = true
                passTitleCell.lblTitle.textColor = #colorLiteral(red: 0, green: 0.5607843137, blue: 0, alpha: 1)
                
                return passTitleCell
                
            }else {
                
                let passTestCell = tableView.dequeueReusableCell(withIdentifier: "TestResultCell", for: indexPath) as! TestResultCell
                
                passTestCell.lblTestName.text = self.arrPassedTest[indexPath.row - 1].strTestName
                passTestCell.lblTestRetry.isHidden = true
                passTestCell.lblSeperator.isHidden = false
                
                if indexPath.row == self.arrPassedTest.count {
                    passTestCell.lblSeperator.isHidden = true
                }
                
                return passTestCell
            }
            
        case 1:
            
            if indexPath.row == 0 {
                
                let skipTitleCell = tableView.dequeueReusableCell(withIdentifier: "TestResultTitleCell", for: indexPath) as! TestResultTitleCell
                skipTitleCell.lblTitle.text = "Skipped Tests"
                skipTitleCell.lblTitle.textColor = #colorLiteral(red: 1, green: 0.1491314173, blue: 0, alpha: 1)
                skipTitleCell.lblSeperator.isHidden = true
                
                return skipTitleCell
                
            }else {
                
                let skipTestCell = tableView.dequeueReusableCell(withIdentifier: "TestResultCell", for: indexPath) as! TestResultCell
                
                skipTestCell.lblTestName.text = self.arrSkippedTest[indexPath.row - 1].strTestName
                skipTestCell.lblTestRetry.isHidden = false
                skipTestCell.lblTestRetry.text = "Retry"
                skipTestCell.lblSeperator.isHidden = false
                
                if indexPath.row == self.arrSkippedTest.count {
                    skipTestCell.lblSeperator.isHidden = true
                }
                
                return skipTestCell
            }
            
        default:
            
            if indexPath.row == 0 {
                
                let failTitleCell = tableView.dequeueReusableCell(withIdentifier: "TestResultTitleCell", for: indexPath) as! TestResultTitleCell
                failTitleCell.lblTitle.text = "Failed Tests"
                failTitleCell.lblTitle.textColor = #colorLiteral(red: 1, green: 0.1491314173, blue: 0, alpha: 1)
                failTitleCell.lblSeperator.isHidden = true
                
                return failTitleCell
                
            }else {
                
                let failTestCell = tableView.dequeueReusableCell(withIdentifier: "TestResultCell", for: indexPath) as! TestResultCell
                
                failTestCell.lblTestName.text = self.arrFailedTest[indexPath.row - 1].strTestName
                failTestCell.lblTestRetry.isHidden = false
                failTestCell.lblTestRetry.text = "Retry"
                failTestCell.lblSeperator.isHidden = false
                
                if indexPath.row == self.arrFailedTest.count {
                    failTestCell.lblSeperator.isHidden = true
                }
                
                return failTestCell
            }
            
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if (indexPath.section == 1) {
            
            if indexPath.row == 0 {
                return
            }
            else {
                
                if (self.arrSkippedTest[indexPath.row - 1].strTestName == "Battery") {
                    
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "BatteryVC") as! BatteryVC
                    vc.isComingFromTestResult = true
                    
                    vc.batteryRetryDiagnosis = { retryJSON in
                        self.resultJSON = retryJSON
                    }
                    
                    vc.resultJSON = self.resultJSON
                    vc.modalPresentationStyle = .fullScreen
                    self.present(vc, animated: true, completion: nil)
                }
                else if (self.arrSkippedTest[indexPath.row - 1].strTestName == "GSM Network") {
                    
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "GsmVC") as! GsmVC
                    vc.isComingFromTestResult = true
                    
                    vc.gsmRetryDiagnosis = { retryJSON in
                        self.resultJSON = retryJSON
                    }
                    
                    vc.resultJSON = self.resultJSON
                    vc.modalPresentationStyle = .fullScreen
                    self.present(vc, animated: true, completion: nil)
                }
                else if (self.arrSkippedTest[indexPath.row - 1].strTestName == "Storage") {
                    
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "StorageVC") as! StorageVC
                    vc.isComingFromTestResult = true
                    
                    vc.storageRetryDiagnosis = { retryJSON in
                        self.resultJSON = retryJSON
                    }
                    
                    vc.resultJSON = self.resultJSON
                    vc.modalPresentationStyle = .fullScreen
                    self.present(vc, animated: true, completion: nil)
                }
                else if (self.arrSkippedTest[indexPath.row - 1].strTestName == "WiFi") {
                    
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "WiFiVC") as! WiFiVC
                    vc.isComingFromTestResult = true
                    
                    vc.wifiRetryDiagnosis = { retryJSON in
                        self.resultJSON = retryJSON
                    }
                    
                    vc.resultJSON = self.resultJSON
                    vc.modalPresentationStyle = .fullScreen
                    self.present(vc, animated: true, completion: nil)
                }
                else if (self.arrSkippedTest[indexPath.row - 1].strTestName == "Bluetooth") {
                    
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "BluetoothVC") as! BluetoothVC
                    vc.isComingFromTestResult = true
                    
                    vc.bluetoothRetryDiagnosis = { retryJSON in
                        self.resultJSON = retryJSON
                    }
                    
                    vc.resultJSON = self.resultJSON
                    vc.modalPresentationStyle = .fullScreen
                    self.present(vc, animated: true, completion: nil)
                }
                else if (self.arrSkippedTest[indexPath.row - 1].strTestName == "GPS") {
                    
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "GpsVC") as! GpsVC
                    vc.isComingFromTestResult = true
                    
                    vc.gpsRetryDiagnosis = { retryJSON in
                        self.resultJSON = retryJSON
                    }
                    
                    vc.resultJSON = self.resultJSON
                    vc.modalPresentationStyle = .fullScreen
                    self.present(vc, animated: true, completion: nil)
                }
                else if (self.arrSkippedTest[indexPath.row - 1].strTestName == "Vibrator") {
                    
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "VibratorVC") as! VibratorVC
                    vc.isComingFromTestResult = true
                    
                    vc.vibratorRetryDiagnosis = { retryJSON in
                        self.resultJSON = retryJSON
                    }
                    
                    vc.resultJSON = self.resultJSON
                    vc.modalPresentationStyle = .fullScreen
                    self.present(vc, animated: true, completion: nil)
                }
                else if (self.arrSkippedTest[indexPath.row - 1].strTestName == "Top Speakers") {
                    
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "SpeakerVC") as! SpeakerVC
                    vc.isComingFromTestResult = true
                    
                    vc.isComeForTopSpeaker = true
                    vc.isComeForBottomSpeaker = false
                    
                    vc.speakerRetryDiagnosis = { retryJSON in
                        self.resultJSON = retryJSON
                    }
                    
                    vc.resultJSON = self.resultJSON
                    vc.modalPresentationStyle = .fullScreen
                    self.present(vc, animated: true, completion: nil)
                }
                else if (self.arrSkippedTest[indexPath.row - 1].strTestName == "Bottom Speakers") {
                    
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "SpeakerVC") as! SpeakerVC
                    vc.isComingFromTestResult = true
                    
                    vc.isComeForTopSpeaker = false
                    vc.isComeForBottomSpeaker = true
                    
                    vc.speakerRetryDiagnosis = { retryJSON in
                        self.resultJSON = retryJSON
                    }
                    
                    vc.resultJSON = self.resultJSON
                    vc.modalPresentationStyle = .fullScreen
                    self.present(vc, animated: true, completion: nil)
                }
                else if (self.arrSkippedTest[indexPath.row - 1].strTestName == "Top Microphone") {
                    
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "MicroPhoneVC") as! MicroPhoneVC
                    vc.isComingFromTestResult = true
                    
                    vc.isComeForTopMic = true
                    vc.isComeForBottomMic = false
                    
                    vc.micRetryDiagnosis = { retryJSON in
                        self.resultJSON = retryJSON
                    }
                    
                    vc.resultJSON = self.resultJSON
                    vc.modalPresentationStyle = .fullScreen
                    self.present(vc, animated: true, completion: nil)
                }
                else if (self.arrSkippedTest[indexPath.row - 1].strTestName == "Bottom Microphone") {
                    
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "MicroPhoneVC") as! MicroPhoneVC
                    vc.isComingFromTestResult = true
                    
                    vc.isComeForTopMic = false
                    vc.isComeForBottomMic = true
                    
                    vc.micRetryDiagnosis = { retryJSON in
                        self.resultJSON = retryJSON
                    }
                    
                    vc.resultJSON = self.resultJSON
                    vc.modalPresentationStyle = .fullScreen
                    self.present(vc, animated: true, completion: nil)
                }
                else if (self.arrSkippedTest[indexPath.row - 1].strTestName == "FlashLight") {
                    
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "FlashLightVC") as! FlashLightVC
                    vc.isComingFromTestResult = true
                    
                    vc.flashlightRetryDiagnosis = { retryJSON in
                        self.resultJSON = retryJSON
                    }
                    
                    vc.resultJSON = self.resultJSON
                    vc.modalPresentationStyle = .fullScreen
                    self.present(vc, animated: true, completion: nil)
                }
                else if (self.arrSkippedTest[indexPath.row - 1].strTestName == "Earphone Jack") {
                    
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "EarphoneVC") as! EarphoneVC
                    vc.isComingFromTestResult = true
                    
                    vc.earphoneRetryDiagnosis = { retryJSON in
                        self.resultJSON = retryJSON
                    }
                    
                    vc.resultJSON = self.resultJSON
                    vc.modalPresentationStyle = .fullScreen
                    self.present(vc, animated: true, completion: nil)
                }
                else if (self.arrSkippedTest[indexPath.row - 1].strTestName == "Auto Rotation") {
                    
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "AutoRotationVC") as! AutoRotationVC
                    vc.isComingFromTestResult = true
                    
                    vc.rotationRetryDiagnosis = { retryJSON in
                        self.resultJSON = retryJSON
                    }
                    
                    vc.resultJSON = self.resultJSON
                    vc.modalPresentationStyle = .fullScreen
                    self.present(vc, animated: true, completion: nil)
                }
                else if (self.arrSkippedTest[indexPath.row - 1].strTestName == "Proximity") {
                    
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "ProximityVC") as! ProximityVC
                    vc.isComingFromTestResult = true
                    
                    vc.proximityRetryDiagnosis = { retryJSON in
                        self.resultJSON = retryJSON
                    }
                    
                    vc.resultJSON = self.resultJSON
                    vc.modalPresentationStyle = .fullScreen
                    self.present(vc, animated: true, completion: nil)
                }
                else if (self.arrSkippedTest[indexPath.row - 1].strTestName == "USB Slot") {
                    
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "ChargerVC") as! ChargerVC
                    vc.isComingFromTestResult = true
                    
                    vc.chargerRetryDiagnosis = { retryJSON in
                        self.resultJSON = retryJSON
                    }
                    
                    vc.resultJSON = self.resultJSON
                    vc.modalPresentationStyle = .fullScreen
                    self.present(vc, animated: true, completion: nil)
                }
                else if (self.arrSkippedTest[indexPath.row - 1].strTestName == "Dead Pixel") {
                    
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "DeadPixelsVC") as! DeadPixelsVC
                    vc.isComingFromTestResult = true
                    
                    vc.deadPixelRetryDiagnosis = { retryJSON in
                        self.resultJSON = retryJSON
                    }
                    
                    vc.resultJSON = self.resultJSON
                    vc.modalPresentationStyle = .fullScreen
                    self.present(vc, animated: true, completion: nil)
                }
                else if (self.arrSkippedTest[indexPath.row - 1].strTestName == "Camera") {
                    
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "CameraVC") as! CameraVC
                    vc.isComingFromTestResult = true
                    
                    vc.cameraRetryDiagnosis = { retryJSON in
                        self.resultJSON = retryJSON
                    }
                    
                    vc.resultJSON = self.resultJSON
                    vc.modalPresentationStyle = .fullScreen
                    self.present(vc, animated: true, completion: nil)
                }
                else if (self.arrSkippedTest[indexPath.row - 1].strTestName == "Autofocus") {
                    
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "CameraVC") as! CameraVC
                    vc.isComingFromTestResult = true
                    
                    vc.cameraRetryDiagnosis = { retryJSON in
                        self.resultJSON = retryJSON
                    }
                    
                    vc.resultJSON = self.resultJSON
                    vc.modalPresentationStyle = .fullScreen
                    self.present(vc, animated: true, completion: nil)
                }
                else if (self.arrSkippedTest[indexPath.row - 1].strTestName == "Touch Screen") {
                    
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "ScreenCalibrationVC") as! ScreenCalibrationVC
                    vc.isComingFromTestResult = true
                    
                    vc.screenRetryDiagnosis = { retryJSON in
                        self.resultJSON = retryJSON
                    }
                    
                    vc.resultJSON = self.resultJSON
                    vc.modalPresentationStyle = .fullScreen
                    self.present(vc, animated: true, completion: nil)
                }
                else if (self.arrSkippedTest[indexPath.row - 1].strTestName == "Device Button") {
                    
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "VolumeButtonVC") as! VolumeButtonVC
                    vc.isComingFromTestResult = true
                    
                    vc.volumeRetryDiagnosis = { retryJSON in
                        self.resultJSON = retryJSON
                    }
                    
                    vc.resultJSON = self.resultJSON
                    vc.modalPresentationStyle = .fullScreen
                    self.present(vc, animated: true, completion: nil)
                }
                else if (self.arrSkippedTest[indexPath.row - 1].strTestName == "Biometric") {
                    
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "BiometricVC") as! BiometricVC
                    vc.isComingFromTestResult = true
                    
                    vc.biometricRetryDiagnosis = { retryJSON in
                        self.resultJSON = retryJSON
                    }
                    
                    vc.resultJSON = self.resultJSON
                    vc.modalPresentationStyle = .fullScreen
                    self.present(vc, animated: true, completion: nil)
                }
                else {
                    
                }
                
            }
            
        }
        else if indexPath.section == 2 {
            
            if indexPath.row == 0 {
                return
            }
            else {
                
                if (self.arrFailedTest[indexPath.row - 1].strTestName == "Battery") {
                    
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "BatteryVC") as! BatteryVC
                    vc.isComingFromTestResult = true
                    
                    vc.batteryRetryDiagnosis = { retryJSON in
                        self.resultJSON = retryJSON
                    }
                    
                    vc.resultJSON = self.resultJSON
                    vc.modalPresentationStyle = .fullScreen
                    self.present(vc, animated: true, completion: nil)
                }
                else if (self.arrFailedTest[indexPath.row - 1].strTestName == "GSM Network") {
                    
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "GsmVC") as! GsmVC
                    vc.isComingFromTestResult = true
                    
                    vc.gsmRetryDiagnosis = { retryJSON in
                        self.resultJSON = retryJSON
                    }
                    
                    vc.resultJSON = self.resultJSON
                    vc.modalPresentationStyle = .fullScreen
                    self.present(vc, animated: true, completion: nil)
                }
                else if (self.arrFailedTest[indexPath.row - 1].strTestName == "Storage") {
                    
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "StorageVC") as! StorageVC
                    vc.isComingFromTestResult = true
                    
                    vc.storageRetryDiagnosis = { retryJSON in
                        self.resultJSON = retryJSON
                    }
                    
                    vc.resultJSON = self.resultJSON
                    vc.modalPresentationStyle = .fullScreen
                    self.present(vc, animated: true, completion: nil)
                }
                else if (self.arrFailedTest[indexPath.row - 1].strTestName == "WiFi") {
                    
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "WiFiVC") as! WiFiVC
                    vc.isComingFromTestResult = true
                    
                    vc.wifiRetryDiagnosis = { retryJSON in
                        self.resultJSON = retryJSON
                    }
                    
                    vc.resultJSON = self.resultJSON
                    vc.modalPresentationStyle = .fullScreen
                    self.present(vc, animated: true, completion: nil)
                }
                else if (self.arrFailedTest[indexPath.row - 1].strTestName == "Bluetooth") {
                    
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "BluetoothVC") as! BluetoothVC
                    vc.isComingFromTestResult = true
                    
                    vc.bluetoothRetryDiagnosis = { retryJSON in
                        self.resultJSON = retryJSON
                    }
                    
                    vc.resultJSON = self.resultJSON
                    vc.modalPresentationStyle = .fullScreen
                    self.present(vc, animated: true, completion: nil)
                }
                else if (self.arrFailedTest[indexPath.row - 1].strTestName == "GPS") {
                    
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "GpsVC") as! GpsVC
                    vc.isComingFromTestResult = true
                    
                    vc.gpsRetryDiagnosis = { retryJSON in
                        self.resultJSON = retryJSON
                    }
                    
                    vc.resultJSON = self.resultJSON
                    vc.modalPresentationStyle = .fullScreen
                    self.present(vc, animated: true, completion: nil)
                }
                else if (self.arrFailedTest[indexPath.row - 1].strTestName == "Vibrator") {
                    
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "VibratorVC") as! VibratorVC
                    vc.isComingFromTestResult = true
                    
                    vc.vibratorRetryDiagnosis = { retryJSON in
                        self.resultJSON = retryJSON
                    }
                    
                    vc.resultJSON = self.resultJSON
                    vc.modalPresentationStyle = .fullScreen
                    self.present(vc, animated: true, completion: nil)
                }
                else if (self.arrFailedTest[indexPath.row - 1].strTestName == "Top Speakers") {
                    
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "SpeakerVC") as! SpeakerVC
                    vc.isComingFromTestResult = true
                    
                    vc.isComeForTopSpeaker = true
                    vc.isComeForBottomSpeaker = false
                    
                    vc.speakerRetryDiagnosis = { retryJSON in
                        self.resultJSON = retryJSON
                    }
                    
                    vc.resultJSON = self.resultJSON
                    vc.modalPresentationStyle = .fullScreen
                    self.present(vc, animated: true, completion: nil)
                }
                else if (self.arrFailedTest[indexPath.row - 1].strTestName == "Bottom Speakers") {
                    
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "SpeakerVC") as! SpeakerVC
                    vc.isComingFromTestResult = true
                    
                    vc.isComeForTopSpeaker = false
                    vc.isComeForBottomSpeaker = true
                    
                    vc.speakerRetryDiagnosis = { retryJSON in
                        self.resultJSON = retryJSON
                    }
                    
                    vc.resultJSON = self.resultJSON
                    vc.modalPresentationStyle = .fullScreen
                    self.present(vc, animated: true, completion: nil)
                }
                else if (self.arrFailedTest[indexPath.row - 1].strTestName == "Top Microphone") {
                    
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "MicroPhoneVC") as! MicroPhoneVC
                    vc.isComingFromTestResult = true
                    
                    vc.isComeForTopMic = true
                    vc.isComeForBottomMic = false
                    
                    vc.micRetryDiagnosis = { retryJSON in
                        self.resultJSON = retryJSON
                    }
                    
                    vc.resultJSON = self.resultJSON
                    vc.modalPresentationStyle = .fullScreen
                    self.present(vc, animated: true, completion: nil)
                }
                else if (self.arrFailedTest[indexPath.row - 1].strTestName == "Bottom Microphone") {
                    
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "MicroPhoneVC") as! MicroPhoneVC
                    vc.isComingFromTestResult = true
                    
                    vc.isComeForTopMic = false
                    vc.isComeForBottomMic = true
                    
                    vc.micRetryDiagnosis = { retryJSON in
                        self.resultJSON = retryJSON
                    }
                    
                    vc.resultJSON = self.resultJSON
                    vc.modalPresentationStyle = .fullScreen
                    self.present(vc, animated: true, completion: nil)
                }
                else if (self.arrFailedTest[indexPath.row - 1].strTestName == "FlashLight") {
                    
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "FlashLightVC") as! FlashLightVC
                    vc.isComingFromTestResult = true
                    
                    vc.flashlightRetryDiagnosis = { retryJSON in
                        self.resultJSON = retryJSON
                    }
                    
                    vc.resultJSON = self.resultJSON
                    vc.modalPresentationStyle = .fullScreen
                    self.present(vc, animated: true, completion: nil)
                }
                else if (self.arrFailedTest[indexPath.row - 1].strTestName == "Earphone Jack") {
                    
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "EarphoneVC") as! EarphoneVC
                    vc.isComingFromTestResult = true
                    
                    vc.earphoneRetryDiagnosis = { retryJSON in
                        self.resultJSON = retryJSON
                    }
                    
                    vc.resultJSON = self.resultJSON
                    vc.modalPresentationStyle = .fullScreen
                    self.present(vc, animated: true, completion: nil)
                }
                else if (self.arrFailedTest[indexPath.row - 1].strTestName == "Auto Rotation") {
                    
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "AutoRotationVC") as! AutoRotationVC
                    vc.isComingFromTestResult = true
                    
                    vc.rotationRetryDiagnosis = { retryJSON in
                        self.resultJSON = retryJSON
                    }
                    
                    vc.resultJSON = self.resultJSON
                    vc.modalPresentationStyle = .fullScreen
                    self.present(vc, animated: true, completion: nil)
                }
                else if (self.arrFailedTest[indexPath.row - 1].strTestName == "Proximity") {
                    
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "ProximityVC") as! ProximityVC
                    vc.isComingFromTestResult = true
                    
                    vc.proximityRetryDiagnosis = { retryJSON in
                        self.resultJSON = retryJSON
                    }
                    
                    vc.resultJSON = self.resultJSON
                    vc.modalPresentationStyle = .fullScreen
                    self.present(vc, animated: true, completion: nil)
                }
                else if (self.arrFailedTest[indexPath.row - 1].strTestName == "USB Slot") {
                    
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "ChargerVC") as! ChargerVC
                    vc.isComingFromTestResult = true
                    
                    vc.chargerRetryDiagnosis = { retryJSON in
                        self.resultJSON = retryJSON
                    }
                    
                    vc.resultJSON = self.resultJSON
                    vc.modalPresentationStyle = .fullScreen
                    self.present(vc, animated: true, completion: nil)
                }
                else if (self.arrFailedTest[indexPath.row - 1].strTestName == "Dead Pixel") {
                    
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "DeadPixelsVC") as! DeadPixelsVC
                    vc.isComingFromTestResult = true
                    
                    vc.deadPixelRetryDiagnosis = { retryJSON in
                        self.resultJSON = retryJSON
                    }
                    
                    vc.resultJSON = self.resultJSON
                    vc.modalPresentationStyle = .fullScreen
                    self.present(vc, animated: true, completion: nil)
                }
                else if (self.arrFailedTest[indexPath.row - 1].strTestName == "Camera") {
                    
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "CameraVC") as! CameraVC
                    vc.isComingFromTestResult = true
                    
                    vc.cameraRetryDiagnosis = { retryJSON in
                        self.resultJSON = retryJSON
                    }
                    
                    vc.resultJSON = self.resultJSON
                    vc.modalPresentationStyle = .fullScreen
                    self.present(vc, animated: true, completion: nil)
                }
                else if (self.arrFailedTest[indexPath.row - 1].strTestName == "Autofocus") {
                    
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "CameraVC") as! CameraVC
                    vc.isComingFromTestResult = true
                    
                    vc.cameraRetryDiagnosis = { retryJSON in
                        self.resultJSON = retryJSON
                    }
                    
                    vc.resultJSON = self.resultJSON
                    vc.modalPresentationStyle = .fullScreen
                    self.present(vc, animated: true, completion: nil)
                }
                else if (self.arrFailedTest[indexPath.row - 1].strTestName == "Touch Screen") {
                    
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "ScreenCalibrationVC") as! ScreenCalibrationVC
                    vc.isComingFromTestResult = true
                    
                    vc.screenRetryDiagnosis = { retryJSON in
                        self.resultJSON = retryJSON
                    }
                    
                    vc.resultJSON = self.resultJSON
                    vc.modalPresentationStyle = .fullScreen
                    self.present(vc, animated: true, completion: nil)
                }
                else if (self.arrFailedTest[indexPath.row - 1].strTestName == "Device Button") {
                    
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "VolumeButtonVC") as! VolumeButtonVC
                    vc.isComingFromTestResult = true
                    
                    vc.volumeRetryDiagnosis = { retryJSON in
                        self.resultJSON = retryJSON
                    }
                    
                    vc.resultJSON = self.resultJSON
                    vc.modalPresentationStyle = .fullScreen
                    self.present(vc, animated: true, completion: nil)
                }
                else if (self.arrFailedTest[indexPath.row - 1].strTestName == "Biometric") {
                    
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "BiometricVC") as! BiometricVC
                    vc.isComingFromTestResult = true
                    
                    vc.biometricRetryDiagnosis = { retryJSON in
                        self.resultJSON = retryJSON
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
    

}
