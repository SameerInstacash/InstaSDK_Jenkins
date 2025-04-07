//
//  CameraVC.swift
//  InstaCash_Diagnostics
//
//  Created by Sameer Khan on 23/07/24.
//

import UIKit
import SwiftyJSON
import AVFoundation
import CameraManager

import os

class CameraVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIGestureRecognizerDelegate, AVCapturePhotoCaptureDelegate {
    
    @IBOutlet weak var cameraPreview: UIView!
    
    @IBOutlet weak var btnFrontCamera: UIButton!
    @IBOutlet weak var btnBackCamera1: UIButton!
    @IBOutlet weak var btnBackCamera2: UIButton!
    @IBOutlet weak var btnBackCamera3: UIButton!
    
    var resultJSON = JSON()
    
    var retryIndex = -1
    var isComingFromTestResult = false
    var cameraRetryDiagnosis: ((_ testJSON: JSON) -> Void)?
    
    var isBackCamera1Avail = [AVCaptureDevice]()
    var isBackCamera2Avail = [AVCaptureDevice]()
    var isBackCamera3Avail = [AVCaptureDevice]()
    
    var isFrontClicked = false
    var isBack1Clicked = false
    var isBack2Clicked = false
    var isBack3Clicked = false
    
    private let photoOutput = AVCapturePhotoOutput()
    var cameraLayer = AVCaptureVideoPreviewLayer()
    var captureSession: AVCaptureSession?
    var cameraDevice: AVCaptureDevice?
    
    var isComeForFrontCamera = false
    var isComeForFrontAuto = false
    var isComeForBackAuto = false
    
    var isFrontCamDone : (() -> Void)?
    var isBack1CamDone : (() -> Void)?
    var isBack2CamDone : (() -> Void)?
    var isBack3CamDone : (() -> Void)?
    
    deinit {
        //cameraManager = nil
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setCustomNavigationBar()
        self.setStatusBarColor(themeColor: GlobalUtility().AppThemeColor)
        
        self.openCamera()
        
        self.setupCameraButtons()
        
        self.CheckAvailableCameras()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        appDelegate_Obj.orientationLock = .portrait
        
    }
    
    func CheckAvailableCameras() {
        
        isBackCamera1Avail = getAvailableBackCamera1()
        isBackCamera2Avail = getAvailableBackCamera2()
        isBackCamera3Avail = getAvailableBackCamera3()
        
        
        if isBackCamera1Avail.count > 0 {
            btnBackCamera1.isHidden = false
            
            isBack1Clicked = false
            
            if self.isComeForBackAuto {
                if self.isComeForBackAuto {
                    btnBackCamera1.isHidden = true
                }
            }
            
        }
        else {
            btnBackCamera1.isHidden = true
            
            isBack1Clicked = true
        }
        
        if isBackCamera2Avail.count > 0 {
            btnBackCamera2.isHidden = false
            
            isBack2Clicked = false
            
            if self.isComeForBackAuto {
                if self.isComeForBackAuto {
                    btnBackCamera2.isHidden = true
                }
            }
            
        }
        else {
            btnBackCamera2.isHidden = true
            
            isBack2Clicked = true
        }
        
        if isBackCamera3Avail.count > 0 {
            btnBackCamera3.isHidden = false
            
            isBack3Clicked = false
            
            if self.isComeForBackAuto {
                if self.isComeForBackAuto {
                    btnBackCamera3.isHidden = true
                }
            }
            
        }
        else {
            btnBackCamera3.isHidden = true
            
            isBack3Clicked = true
        }
        
    }
    
    func setupCameraButtons() {
        
        if self.isComingFromTestResult {
            
            if self.isComeForFrontCamera {
                
                DispatchQueue.main.async {
                    
                    self.isFrontClicked = false
                    self.isBack1Clicked = true
                    self.isBack2Clicked = true
                    self.isBack3Clicked = true
                    
                    self.btnFrontCamera.isHidden = false
                    self.btnBackCamera1.isHidden = true
                    self.btnBackCamera2.isHidden = true
                    self.btnBackCamera3.isHidden = true
                    
                    if self.isComeForFrontAuto {
                        
                        self.btnFrontCamera.isHidden = true
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: {
                            self.frontCameraBtnClicked(self.btnFrontCamera, true)
                        })
                        
                    }
                    
                }
                
            }
            else {
                
                DispatchQueue.main.async {
                    
                    self.isFrontClicked = true
                    //self.isBack1Clicked = false
                    //self.isBack2Clicked = false
                    //self.isBack3Clicked = false
                    
                    self.btnFrontCamera.isHidden = true
                    //self.btnBackCamera1.isHidden = true
                    //self.btnBackCamera2.isHidden = true
                    //self.btnBackCamera3.isHidden = true
                    
                    self.CheckAvailableCameras()
                    
                    
                    if self.isComeForBackAuto {
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: {
                            self.backCam1Auto()
                        })
                        
                    }
                    
                }
                
            }
            
            
        }
        else {
            
            if arrTestsInSDK.firstIndex(of: ("frontCamera_auto".lowercased())) != nil {
                
                DispatchQueue.main.async {
                    self.btnFrontCamera.isHidden = true
                    
                    self.btnBackCamera1.isHidden = true
                    self.btnBackCamera2.isHidden = true
                    self.btnBackCamera3.isHidden = true
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: {
                        self.frontCamAuto()
                    })
                }
                
            }
            
            if arrTestsInSDK.firstIndex(of: ("backCamera_auto".lowercased())) != nil {
                
                DispatchQueue.main.async {
                    self.btnBackCamera1.isHidden = true
                    self.btnBackCamera2.isHidden = true
                    self.btnBackCamera3.isHidden = true
                }
                
            }
            
        }
        
    }
    
    func frontCamAuto() {
        self.frontCameraBtnClicked(self.btnFrontCamera, true)
        
        self.isFrontCamDone = {
            self.isFrontCamDone = nil
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5, execute: {
                self.backCam1Auto()
            })
            
        }
        
    }
    
    func backCam1Auto() {
        
        if isBackCamera1Avail.count > 0 {
            
            backCamera1BtnClicked(self.btnBackCamera1, true)
            
            self.isBack1CamDone = {
                self.isBack1CamDone = nil
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5, execute: {
                    self.backCam2Auto()
                })
                
            }
            
        }
        else {
            
            if (self.isFrontClicked && self.isBack1Clicked && self.isBack2Clicked && self.isBack3Clicked ) {
                self.finishCameraTest()
            }
            
        }
        
    }
    
    func backCam2Auto() {
        
        if isBackCamera2Avail.count > 0 {
            backCamera2BtnClicked(self.btnBackCamera2, true)
            
            self.isBack2CamDone = {
                self.isBack2CamDone = nil
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5, execute: {
                    self.backCam3Auto()
                })
                
            }
            
        }
        else {
            
            if (self.isFrontClicked && self.isBack1Clicked && self.isBack2Clicked && self.isBack3Clicked ) {
                self.finishCameraTest()
            }
            
        }
        
    }
    
    func backCam3Auto() {
        
        if isBackCamera3Avail.count > 0 {
            backCamera3BtnClicked(self.btnBackCamera3, true)
            
            self.isBack3CamDone = {
                self.isBack3CamDone = nil
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5, execute: {
                    
                    if (self.isFrontClicked && self.isBack1Clicked && self.isBack2Clicked && self.isBack3Clicked ) {
                        self.finishCameraTest()
                    }
                    
                })
                
            }
            
        }
        else {
            
            if (self.isFrontClicked && self.isBack1Clicked && self.isBack2Clicked && self.isBack3Clicked ) {
                self.finishCameraTest()
            }
            
        }
        
    }
    
    //MARK: Custom Method
    func getAvailableBackCamera1() -> [AVCaptureDevice] {
        let deviceTypes: [AVCaptureDevice.DeviceType] = [
            .builtInWideAngleCamera
        ]
        let discoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: deviceTypes,
                                                                mediaType: .video,
                                                                position: .back)
        return discoverySession.devices
    }
    
    func getAvailableBackCamera2() -> [AVCaptureDevice] {
        let deviceTypes: [AVCaptureDevice.DeviceType] = [
            .builtInUltraWideCamera
        ]
        let discoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: deviceTypes,
                                                                mediaType: .video,
                                                                position: .back)
        return discoverySession.devices
    }
    
    func getAvailableBackCamera3() -> [AVCaptureDevice] {
        let deviceTypes: [AVCaptureDevice.DeviceType] = [
            .builtInTelephotoCamera
        ]
        let discoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: deviceTypes,
                                                                mediaType: .video,
                                                                position: .back)
        return discoverySession.devices
    }
    
    //MARK: IBActions
    @IBAction func frontCameraBtnClicked(_ sender: UIButton, _ isAuto: Bool) {
        
        let vc = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "CameraTestVC") as! CameraTestVC
        vc.isComeFrom = "1"
        vc.modalPresentationStyle = .overFullScreen
        
        vc.isAutoClick = isAuto
        
        vc.isPhotoClick = { click in
            
            self.isFrontClicked = click
            
            self.btnFrontCamera.isHidden = click
            
            if self.isFrontCamDone != nil {
                
                if let done = self.isFrontCamDone {
                    done()
                }
                
            }
            else {
                
                if (self.isFrontClicked && self.isBack1Clicked && self.isBack2Clicked && self.isBack3Clicked ) {
                    self.finishCameraTest()
                }
                
            }
            
        }
        
        self.present(vc, animated: true)
        
    }
    
    @IBAction func backCamera1BtnClicked(_ sender: UIButton, _ isAuto: Bool) {
        
        let vc = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "CameraTestVC") as! CameraTestVC
        vc.isComeFrom = "2"
        vc.modalPresentationStyle = .overFullScreen
        
        vc.isAutoClick = isAuto
        
        vc.isPhotoClick = { click in
            
            self.isBack1Clicked = click
            
            self.btnBackCamera1.isHidden = click
            
            if self.isBack1CamDone != nil {
                
                if let done = self.isBack1CamDone {
                    done()
                }
                
            }
            else {
                
                if (self.isFrontClicked && self.isBack1Clicked && self.isBack2Clicked && self.isBack3Clicked ) {
                    self.finishCameraTest()
                }
                
            }
            
        }
        
        self.present(vc, animated: true)
        
    }
    
    @IBAction func backCamera2BtnClicked(_ sender: UIButton, _ isAuto: Bool) {
        
        let vc = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "CameraTestVC") as! CameraTestVC
        vc.isComeFrom = "3"
        vc.modalPresentationStyle = .overFullScreen
        
        vc.isAutoClick = isAuto
        
        vc.isPhotoClick = { click in
            
            self.isBack2Clicked = click
            
            self.btnBackCamera2.isHidden = click
            
            if self.isBack2CamDone != nil {
                
                if let done = self.isBack2CamDone {
                    done()
                }
                
            }
            else {
                
                if (self.isFrontClicked && self.isBack1Clicked && self.isBack2Clicked && self.isBack3Clicked ) {
                    self.finishCameraTest()
                }
                
            }
            
        }
        
        self.present(vc, animated: true)
        
    }
    
    @IBAction func backCamera3BtnClicked(_ sender: UIButton, _ isAuto: Bool) {
        
        let vc = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "CameraTestVC") as! CameraTestVC
        vc.isComeFrom = "4"
        vc.modalPresentationStyle = .overFullScreen
        
        vc.isAutoClick = isAuto
        
        vc.isPhotoClick = { click in
            
            self.isBack3Clicked = click
            
            self.btnBackCamera3.isHidden = click
            
            if self.isBack3CamDone != nil {
                
                if let done = self.isBack3CamDone {
                    done()
                }
                
            }
            else {
                
                if (self.isFrontClicked && self.isBack1Clicked && self.isBack2Clicked && self.isBack3Clicked ) {
                    self.finishCameraTest()
                }
                
            }
            
        }
        
        self.present(vc, animated: true)
        
    }
    
    @IBAction func cameraTestSkipButtonPressed(_ sender: UIButton) {
        
        if self.isFrontCamDone != nil {
            self.isFrontCamDone = nil
        }
        
        if self.isBack1CamDone != nil {
            self.isBack1CamDone = nil
        }
        
        if self.isBack2CamDone != nil {
            self.isBack2CamDone = nil
        }
        
        if self.isBack3CamDone != nil {
            self.isBack3CamDone = nil
        }
        
        print("Camera test Skipped!")
        
        if (AppUserDefaults.value(forKey: "AppResultJSON_Data") != nil) {
            let resultJson = JSON.init(parseJSON: AppUserDefaults.value(forKey: "AppResultJSON_Data") as! String)
            self.resultJSON = resultJson
        }
        
        /*
         if self.isComingFromTestResult {
         arrTestsResultJSONInSDK.remove(at: retryIndex)
         arrTestsResultJSONInSDK.insert(-1, at: retryIndex)
         }
         else {
         arrTestsResultJSONInSDK.append(-1)
         }
         
         UserDefaults.standard.set(false, forKey: "Camera")
         self.resultJSON["Camera"].int = -1
         */
        
        
        if self.isComingFromTestResult {
            
            if self.isComeForFrontCamera {
                
                if self.isComeForFrontAuto {
                    arrTestsResultJSONInSDK.remove(at: retryIndex)
                    arrTestsResultJSONInSDK.insert(-1, at: retryIndex)
                    
                    UserDefaults.standard.set(false, forKey: "frontCamera_auto")
                    self.resultJSON["frontCamera_auto"].int = -1
                }
                else {
                    arrTestsResultJSONInSDK.remove(at: retryIndex)
                    arrTestsResultJSONInSDK.insert(-1, at: retryIndex)
                    
                    UserDefaults.standard.set(false, forKey: "frontCamera_manual")
                    self.resultJSON["frontCamera_manual"].int = -1
                }
                
            }
            else {
                
                if self.isComeForBackAuto {
                    arrTestsResultJSONInSDK.remove(at: retryIndex)
                    arrTestsResultJSONInSDK.insert(-1, at: retryIndex)
                    
                    UserDefaults.standard.set(false, forKey: "backCamera_auto")
                    self.resultJSON["backCamera_auto"].int = -1
                }
                else {
                    arrTestsResultJSONInSDK.remove(at: retryIndex)
                    arrTestsResultJSONInSDK.insert(-1, at: retryIndex)
                    
                    UserDefaults.standard.set(false, forKey: "backCamera_manual")
                    self.resultJSON["backCamera_manual"].int = -1
                }
                
            }
            
        }
        else {
            
            if let ind = arrTestsInSDK.firstIndex(of: ("frontCamera_auto".lowercased())) {
                arrTestsInSDK.remove(at: ind)
                
                arrTestsResultJSONInSDK.append(-1)
                
                UserDefaults.standard.set(false, forKey: "frontCamera_auto")
                self.resultJSON["frontCamera_auto"].int = -1
            }
            
            if let ind = arrTestsInSDK.firstIndex(of: ("frontCamera_manual".lowercased())) {
                arrTestsInSDK.remove(at: ind)
                
                arrTestsResultJSONInSDK.append(-1)
                
                UserDefaults.standard.set(false, forKey: "frontCamera_manual")
                self.resultJSON["frontCamera_manual"].int = -1
            }
            
            if let ind = arrTestsInSDK.firstIndex(of: ("backCamera_auto".lowercased())) {
                arrTestsInSDK.remove(at: ind)
                
                arrTestsResultJSONInSDK.append(-1)
                
                UserDefaults.standard.set(false, forKey: "backCamera_auto")
                self.resultJSON["backCamera_auto"].int = -1
            }
            
            if let ind = arrTestsInSDK.firstIndex(of: ("backCamera_manual".lowercased())) {
                arrTestsInSDK.remove(at: ind)
                
                arrTestsResultJSONInSDK.append(-1)
                
                UserDefaults.standard.set(false, forKey: "backCamera_manual")
                self.resultJSON["backCamera_manual"].int = -1
            }
            
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
        
        
        //Auto-Focus Test
        if arrTestsInSDK.contains("Autofocus".lowercased()) {
            if let ind = arrTestsInSDK.firstIndex(of: ("Autofocus".lowercased())) {
                arrTestsInSDK.remove(at: ind)
                
                if (AppUserDefaults.value(forKey: "AppResultJSON_Data") != nil) {
                    let resultJson = JSON.init(parseJSON: AppUserDefaults.value(forKey: "AppResultJSON_Data") as! String)
                    self.resultJSON = resultJson
                }
                
                if self.isComingFromTestResult {
                    arrTestsResultJSONInSDK.remove(at: retryIndex + 1)
                    arrTestsResultJSONInSDK.insert(-1, at: retryIndex + 1)
                }
                else {
                    arrTestsResultJSONInSDK.append(-1)
                }
                
                UserDefaults.standard.set(false, forKey: "Autofocus")
                self.resultJSON["Autofocus"].int = -1
                
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
        }
        
        
        if self.isComingFromTestResult {
            self.navToSummaryPage()
        }
        else {
            self.dismissThisPage()
        }
    }
    
    func finishCameraTest() {
        
        if (AppUserDefaults.value(forKey: "AppResultJSON_Data") != nil) {
            let resultJson = JSON.init(parseJSON: AppUserDefaults.value(forKey: "AppResultJSON_Data") as! String)
            self.resultJSON = resultJson
        }
        
        /*
         if self.isComingFromTestResult {
         arrTestsResultJSONInSDK.remove(at: retryIndex)
         arrTestsResultJSONInSDK.insert(1, at: retryIndex)
         }
         else {
         arrTestsResultJSONInSDK.append(1)
         }
         
         UserDefaults.standard.set(true, forKey: "Camera")
         self.resultJSON["Camera"].int = 1
         */
        
        if self.isComingFromTestResult {
            
            if self.isComeForFrontCamera {
                
                if self.isComeForFrontAuto {
                    arrTestsResultJSONInSDK.remove(at: retryIndex)
                    arrTestsResultJSONInSDK.insert(1, at: retryIndex)
                    
                    UserDefaults.standard.set(true, forKey: "frontCamera_auto")
                    self.resultJSON["frontCamera_auto"].int = 1
                }
                else {
                    arrTestsResultJSONInSDK.remove(at: retryIndex)
                    arrTestsResultJSONInSDK.insert(1, at: retryIndex)
                    
                    UserDefaults.standard.set(true, forKey: "frontCamera_manual")
                    self.resultJSON["frontCamera_manual"].int = 1
                }
                
            }
            else {
                
                if self.isComeForBackAuto {
                    arrTestsResultJSONInSDK.remove(at: retryIndex)
                    arrTestsResultJSONInSDK.insert(1, at: retryIndex)
                    
                    UserDefaults.standard.set(true, forKey: "backCamera_auto")
                    self.resultJSON["backCamera_auto"].int = 1
                }
                else {
                    arrTestsResultJSONInSDK.remove(at: retryIndex)
                    arrTestsResultJSONInSDK.insert(1, at: retryIndex)
                    
                    UserDefaults.standard.set(true, forKey: "backCamera_manual")
                    self.resultJSON["backCamera_manual"].int = 1
                }
                
            }
            
        }
        else {
            
            if let ind = arrTestsInSDK.firstIndex(of: ("frontCamera_auto".lowercased())) {
                arrTestsInSDK.remove(at: ind)
                
                arrTestsResultJSONInSDK.append(1)
                
                UserDefaults.standard.set(true, forKey: "frontCamera_auto")
                self.resultJSON["frontCamera_auto"].int = 1
            }
            
            if let ind = arrTestsInSDK.firstIndex(of: ("frontCamera_manual".lowercased())) {
                arrTestsInSDK.remove(at: ind)
                
                arrTestsResultJSONInSDK.append(1)
                
                UserDefaults.standard.set(true, forKey: "frontCamera_manual")
                self.resultJSON["frontCamera_manual"].int = 1
            }
            
            if let ind = arrTestsInSDK.firstIndex(of: ("backCamera_auto".lowercased())) {
                arrTestsInSDK.remove(at: ind)
                
                arrTestsResultJSONInSDK.append(1)
                
                UserDefaults.standard.set(true, forKey: "backCamera_auto")
                self.resultJSON["backCamera_auto"].int = 1
            }
            
            if let ind = arrTestsInSDK.firstIndex(of: ("backCamera_manual".lowercased())) {
                arrTestsInSDK.remove(at: ind)
                
                arrTestsResultJSONInSDK.append(1)
                
                UserDefaults.standard.set(true, forKey: "backCamera_manual")
                self.resultJSON["backCamera_manual"].int = 1
            }
            
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
        
        //Auto-Focus Test
        if arrTestsInSDK.contains("Autofocus".lowercased()) {
            if let ind = arrTestsInSDK.firstIndex(of: ("Autofocus".lowercased())) {
                arrTestsInSDK.remove(at: ind)
                
                if (AppUserDefaults.value(forKey: "AppResultJSON_Data") != nil) {
                    let resultJson = JSON.init(parseJSON: AppUserDefaults.value(forKey: "AppResultJSON_Data") as! String)
                    self.resultJSON = resultJson
                }
                
                if self.isComingFromTestResult {
                    arrTestsResultJSONInSDK.remove(at: retryIndex + 1)
                    arrTestsResultJSONInSDK.insert(1, at: retryIndex + 1)
                }
                else {
                    arrTestsResultJSONInSDK.append(1)
                }
                
                UserDefaults.standard.set(true, forKey: "Autofocus")
                self.resultJSON["Autofocus"].int = 1
                
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
        }
        
        if self.isComingFromTestResult {
            self.navToSummaryPage()
        }
        else {
            self.dismissThisPage()
        }
    }
    
    private func openCamera() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            // the user has already authorized to access the camera.
            
            DispatchQueue.main.async {
                //self.frontCameraClick()
            }
            
            break
            
        case .notDetermined: // the user has not yet asked for camera access.
            AVCaptureDevice.requestAccess(for: .video) { (granted) in
                if granted { // if user has granted to access the camera.
                    
                    print("the user has granted to access the camera")
                    
                    DispatchQueue.main.async {
                        //self.frontCameraClick()
                    }
                    
                } else {
                    print("the user has not granted to access the camera")
                    
                    if (AppUserDefaults.value(forKey: "AppResultJSON_Data") != nil) {
                        let resultJson = JSON.init(parseJSON: AppUserDefaults.value(forKey: "AppResultJSON_Data") as! String)
                        self.resultJSON = resultJson
                    }
                    
                    /*
                     if self.isComingFromTestResult {
                     arrTestsResultJSONInSDK.remove(at: self.retryIndex)
                     arrTestsResultJSONInSDK.insert(0, at: self.retryIndex)
                     }
                     else {
                     arrTestsResultJSONInSDK.append(0)
                     }
                     
                     UserDefaults.standard.set(false, forKey: "Camera")
                     self.resultJSON["Camera"].int = 0
                     */
                    
                    
                    if self.isComingFromTestResult {
                        
                        if self.isComeForFrontCamera {
                            
                            if self.isComeForFrontAuto {
                                arrTestsResultJSONInSDK.remove(at: self.retryIndex)
                                arrTestsResultJSONInSDK.insert(0, at: self.retryIndex)
                                
                                UserDefaults.standard.set(false, forKey: "frontCamera_auto")
                                self.resultJSON["frontCamera_auto"].int = 0
                            }
                            else {
                                arrTestsResultJSONInSDK.remove(at: self.retryIndex)
                                arrTestsResultJSONInSDK.insert(0, at: self.retryIndex)
                                
                                UserDefaults.standard.set(false, forKey: "frontCamera_manual")
                                self.resultJSON["frontCamera_manual"].int = 0
                            }
                            
                        }
                        else {
                            
                            if self.isComeForBackAuto {
                                arrTestsResultJSONInSDK.remove(at: self.retryIndex)
                                arrTestsResultJSONInSDK.insert(0, at: self.retryIndex)
                                
                                UserDefaults.standard.set(false, forKey: "backCamera_auto")
                                self.resultJSON["backCamera_auto"].int = 0
                            }
                            else {
                                arrTestsResultJSONInSDK.remove(at: self.retryIndex)
                                arrTestsResultJSONInSDK.insert(0, at: self.retryIndex)
                                
                                UserDefaults.standard.set(false, forKey: "backCamera_manual")
                                self.resultJSON["backCamera_manual"].int = 0
                            }
                            
                        }
                        
                    }
                    else {
                        
                        if let ind = arrTestsInSDK.firstIndex(of: ("frontCamera_auto".lowercased())) {
                            arrTestsInSDK.remove(at: ind)
                            
                            arrTestsResultJSONInSDK.append(0)
                            
                            UserDefaults.standard.set(false, forKey: "frontCamera_auto")
                            self.resultJSON["frontCamera_auto"].int = 0
                        }
                        
                        if let ind = arrTestsInSDK.firstIndex(of: ("frontCamera_manual".lowercased())) {
                            arrTestsInSDK.remove(at: ind)
                            
                            arrTestsResultJSONInSDK.append(0)
                            
                            UserDefaults.standard.set(false, forKey: "frontCamera_manual")
                            self.resultJSON["frontCamera_manual"].int = 0
                        }
                        
                        if let ind = arrTestsInSDK.firstIndex(of: ("backCamera_auto".lowercased())) {
                            arrTestsInSDK.remove(at: ind)
                            
                            arrTestsResultJSONInSDK.append(0)
                            
                            UserDefaults.standard.set(false, forKey: "backCamera_auto")
                            self.resultJSON["backCamera_auto"].int = 0
                        }
                        
                        if let ind = arrTestsInSDK.firstIndex(of: ("backCamera_manual".lowercased())) {
                            arrTestsInSDK.remove(at: ind)
                            
                            arrTestsResultJSONInSDK.append(0)
                            
                            UserDefaults.standard.set(false, forKey: "backCamera_manual")
                            self.resultJSON["backCamera_manual"].int = 0
                        }
                        
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
                    
                    
                    //Auto-Focus Test
                    if arrTestsInSDK.contains("Autofocus".lowercased()) {
                        if let ind = arrTestsInSDK.firstIndex(of: ("Autofocus".lowercased())) {
                            arrTestsInSDK.remove(at: ind)
                            
                            if (AppUserDefaults.value(forKey: "AppResultJSON_Data") != nil) {
                                let resultJson = JSON.init(parseJSON: AppUserDefaults.value(forKey: "AppResultJSON_Data") as! String)
                                self.resultJSON = resultJson
                            }
                            
                            if self.isComingFromTestResult {
                                arrTestsResultJSONInSDK.remove(at: self.retryIndex + 1)
                                arrTestsResultJSONInSDK.insert(0, at: self.retryIndex + 1)
                            }
                            else {
                                arrTestsResultJSONInSDK.append(0)
                            }
                            
                            UserDefaults.standard.set(false, forKey: "Autofocus")
                            self.resultJSON["Autofocus"].int = 0
                            
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
                    }
                    
                    
                    if self.isComingFromTestResult {
                        self.navToSummaryPage()
                    }
                    else {
                        self.dismissThisPage()
                    }
                    
                }
            }
            
            break
            
        case .denied:
            print("the user has denied previously to access the camera.")
            
            if (AppUserDefaults.value(forKey: "AppResultJSON_Data") != nil) {
                let resultJson = JSON.init(parseJSON: AppUserDefaults.value(forKey: "AppResultJSON_Data") as! String)
                self.resultJSON = resultJson
            }
            
            /*
             if self.isComingFromTestResult {
             arrTestsResultJSONInSDK.remove(at: retryIndex)
             arrTestsResultJSONInSDK.insert(0, at: retryIndex)
             }
             else {
             arrTestsResultJSONInSDK.append(0)
             }
             
             UserDefaults.standard.set(false, forKey: "Camera")
             self.resultJSON["Camera"].int = 0
             */
            
            
            if self.isComingFromTestResult {
                
                if self.isComeForFrontCamera {
                    
                    if self.isComeForFrontAuto {
                        arrTestsResultJSONInSDK.remove(at: retryIndex)
                        arrTestsResultJSONInSDK.insert(0, at: retryIndex)
                        
                        UserDefaults.standard.set(false, forKey: "frontCamera_auto")
                        self.resultJSON["frontCamera_auto"].int = 0
                    }
                    else {
                        arrTestsResultJSONInSDK.remove(at: retryIndex)
                        arrTestsResultJSONInSDK.insert(0, at: retryIndex)
                        
                        UserDefaults.standard.set(false, forKey: "frontCamera_manual")
                        self.resultJSON["frontCamera_manual"].int = 0
                    }
                    
                }
                else {
                    
                    if self.isComeForBackAuto {
                        arrTestsResultJSONInSDK.remove(at: retryIndex)
                        arrTestsResultJSONInSDK.insert(0, at: retryIndex)
                        
                        UserDefaults.standard.set(false, forKey: "backCamera_auto")
                        self.resultJSON["backCamera_auto"].int = 0
                    }
                    else {
                        arrTestsResultJSONInSDK.remove(at: retryIndex)
                        arrTestsResultJSONInSDK.insert(0, at: retryIndex)
                        
                        UserDefaults.standard.set(false, forKey: "backCamera_manual")
                        self.resultJSON["backCamera_manual"].int = 0
                    }
                    
                }
                
            }
            else {
                
                if let ind = arrTestsInSDK.firstIndex(of: ("frontCamera_auto".lowercased())) {
                    arrTestsInSDK.remove(at: ind)
                    
                    arrTestsResultJSONInSDK.append(0)
                    
                    UserDefaults.standard.set(false, forKey: "frontCamera_auto")
                    self.resultJSON["frontCamera_auto"].int = 0
                }
                
                if let ind = arrTestsInSDK.firstIndex(of: ("frontCamera_manual".lowercased())) {
                    arrTestsInSDK.remove(at: ind)
                    
                    arrTestsResultJSONInSDK.append(0)
                    
                    UserDefaults.standard.set(false, forKey: "frontCamera_manual")
                    self.resultJSON["frontCamera_manual"].int = 0
                }
                
                if let ind = arrTestsInSDK.firstIndex(of: ("backCamera_auto".lowercased())) {
                    arrTestsInSDK.remove(at: ind)
                    
                    arrTestsResultJSONInSDK.append(0)
                    
                    UserDefaults.standard.set(false, forKey: "backCamera_auto")
                    self.resultJSON["backCamera_auto"].int = 0
                }
                
                if let ind = arrTestsInSDK.firstIndex(of: ("backCamera_manual".lowercased())) {
                    arrTestsInSDK.remove(at: ind)
                    
                    arrTestsResultJSONInSDK.append(0)
                    
                    UserDefaults.standard.set(false, forKey: "backCamera_manual")
                    self.resultJSON["backCamera_manual"].int = 0
                }
                
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
            
            //Auto-Focus Test
            if arrTestsInSDK.contains("Autofocus".lowercased()) {
                if let ind = arrTestsInSDK.firstIndex(of: ("Autofocus".lowercased())) {
                    arrTestsInSDK.remove(at: ind)
                    
                    if (AppUserDefaults.value(forKey: "AppResultJSON_Data") != nil) {
                        let resultJson = JSON.init(parseJSON: AppUserDefaults.value(forKey: "AppResultJSON_Data") as! String)
                        self.resultJSON = resultJson
                    }
                    
                    if self.isComingFromTestResult {
                        arrTestsResultJSONInSDK.remove(at: retryIndex + 1)
                        arrTestsResultJSONInSDK.insert(0, at: retryIndex + 1)
                    }
                    else {
                        arrTestsResultJSONInSDK.append(0)
                    }
                    
                    UserDefaults.standard.set(false, forKey: "Autofocus")
                    self.resultJSON["Autofocus"].int = 0
                    
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
            }
            
            
            if self.isComingFromTestResult {
                self.navToSummaryPage()
            }
            else {
                self.dismissThisPage()
            }
            
            break
            
        case .restricted:
            print("the user can't give camera access due to some restriction.")
            
            if (AppUserDefaults.value(forKey: "AppResultJSON_Data") != nil) {
                let resultJson = JSON.init(parseJSON: AppUserDefaults.value(forKey: "AppResultJSON_Data") as! String)
                self.resultJSON = resultJson
            }
            
            /*
             if self.isComingFromTestResult {
             arrTestsResultJSONInSDK.remove(at: retryIndex)
             arrTestsResultJSONInSDK.insert(0, at: retryIndex)
             }
             else {
             arrTestsResultJSONInSDK.append(0)
             }
             
             UserDefaults.standard.set(false, forKey: "Camera")
             self.resultJSON["Camera"].int = 0
             */
            
            
            if self.isComingFromTestResult {
                
                if self.isComeForFrontCamera {
                    
                    if self.isComeForFrontAuto {
                        arrTestsResultJSONInSDK.remove(at: retryIndex)
                        arrTestsResultJSONInSDK.insert(0, at: retryIndex)
                        
                        UserDefaults.standard.set(false, forKey: "frontCamera_auto")
                        self.resultJSON["frontCamera_auto"].int = 0
                    }
                    else {
                        arrTestsResultJSONInSDK.remove(at: retryIndex)
                        arrTestsResultJSONInSDK.insert(0, at: retryIndex)
                        
                        UserDefaults.standard.set(false, forKey: "frontCamera_manual")
                        self.resultJSON["frontCamera_manual"].int = 0
                    }
                    
                }
                else {
                    
                    if self.isComeForBackAuto {
                        arrTestsResultJSONInSDK.remove(at: retryIndex)
                        arrTestsResultJSONInSDK.insert(0, at: retryIndex)
                        
                        UserDefaults.standard.set(false, forKey: "backCamera_auto")
                        self.resultJSON["backCamera_auto"].int = 0
                    }
                    else {
                        arrTestsResultJSONInSDK.remove(at: retryIndex)
                        arrTestsResultJSONInSDK.insert(0, at: retryIndex)
                        
                        UserDefaults.standard.set(false, forKey: "backCamera_manual")
                        self.resultJSON["backCamera_manual"].int = 0
                    }
                    
                }
                
            }
            else {
                
                if let ind = arrTestsInSDK.firstIndex(of: ("frontCamera_auto".lowercased())) {
                    arrTestsInSDK.remove(at: ind)
                    
                    arrTestsResultJSONInSDK.append(0)
                    
                    UserDefaults.standard.set(false, forKey: "frontCamera_auto")
                    self.resultJSON["frontCamera_auto"].int = 0
                }
                
                if let ind = arrTestsInSDK.firstIndex(of: ("frontCamera_manual".lowercased())) {
                    arrTestsInSDK.remove(at: ind)
                    
                    arrTestsResultJSONInSDK.append(0)
                    
                    UserDefaults.standard.set(false, forKey: "frontCamera_manual")
                    self.resultJSON["frontCamera_manual"].int = 0
                }
                
                if let ind = arrTestsInSDK.firstIndex(of: ("backCamera_auto".lowercased())) {
                    arrTestsInSDK.remove(at: ind)
                    
                    arrTestsResultJSONInSDK.append(0)
                    
                    UserDefaults.standard.set(false, forKey: "backCamera_auto")
                    self.resultJSON["backCamera_auto"].int = 0
                }
                
                if let ind = arrTestsInSDK.firstIndex(of: ("backCamera_manual".lowercased())) {
                    arrTestsInSDK.remove(at: ind)
                    
                    arrTestsResultJSONInSDK.append(0)
                    
                    UserDefaults.standard.set(false, forKey: "backCamera_manual")
                    self.resultJSON["backCamera_manual"].int = 0
                }
                
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
            
            //Auto-Focus Test
            if arrTestsInSDK.contains("Autofocus".lowercased()) {
                if let ind = arrTestsInSDK.firstIndex(of: ("Autofocus".lowercased())) {
                    arrTestsInSDK.remove(at: ind)
                    
                    if (AppUserDefaults.value(forKey: "AppResultJSON_Data") != nil) {
                        let resultJson = JSON.init(parseJSON: AppUserDefaults.value(forKey: "AppResultJSON_Data") as! String)
                        self.resultJSON = resultJson
                    }
                    
                    if self.isComingFromTestResult {
                        arrTestsResultJSONInSDK.remove(at: retryIndex + 1)
                        arrTestsResultJSONInSDK.insert(0, at: retryIndex + 1)
                    }
                    else {
                        arrTestsResultJSONInSDK.append(0)
                    }
                    
                    UserDefaults.standard.set(false, forKey: "Autofocus")
                    self.resultJSON["Autofocus"].int = 0
                    
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
            }
            
            
            if self.isComingFromTestResult {
                self.navToSummaryPage()
            }
            else {
                self.dismissThisPage()
            }
            
            break
            
        default:
            print("something has wrong due to we can't access the camera.")
            
            if (AppUserDefaults.value(forKey: "AppResultJSON_Data") != nil) {
                let resultJson = JSON.init(parseJSON: AppUserDefaults.value(forKey: "AppResultJSON_Data") as! String)
                self.resultJSON = resultJson
            }
            
            /*
             if self.isComingFromTestResult {
             arrTestsResultJSONInSDK.remove(at: retryIndex)
             arrTestsResultJSONInSDK.insert(0, at: retryIndex)
             }
             else {
             arrTestsResultJSONInSDK.append(0)
             }
             
             UserDefaults.standard.set(false, forKey: "Camera")
             self.resultJSON["Camera"].int = 0
             */
            
            
            if self.isComingFromTestResult {
                
                if self.isComeForFrontCamera {
                    
                    if self.isComeForFrontAuto {
                        arrTestsResultJSONInSDK.remove(at: retryIndex)
                        arrTestsResultJSONInSDK.insert(0, at: retryIndex)
                        
                        UserDefaults.standard.set(false, forKey: "frontCamera_auto")
                        self.resultJSON["frontCamera_auto"].int = 0
                    }
                    else {
                        arrTestsResultJSONInSDK.remove(at: retryIndex)
                        arrTestsResultJSONInSDK.insert(0, at: retryIndex)
                        
                        UserDefaults.standard.set(false, forKey: "frontCamera_manual")
                        self.resultJSON["frontCamera_manual"].int = 0
                    }
                    
                }
                else {
                    if self.isComeForBackAuto {
                        arrTestsResultJSONInSDK.remove(at: retryIndex)
                        arrTestsResultJSONInSDK.insert(0, at: retryIndex)
                        
                        UserDefaults.standard.set(false, forKey: "backCamera_auto")
                        self.resultJSON["backCamera_auto"].int = 0
                    }
                    else {
                        arrTestsResultJSONInSDK.remove(at: retryIndex)
                        arrTestsResultJSONInSDK.insert(0, at: retryIndex)
                        
                        UserDefaults.standard.set(false, forKey: "backCamera_manual")
                        self.resultJSON["backCamera_manual"].int = 0
                    }
                }
                
            }
            else {
                
                if let ind = arrTestsInSDK.firstIndex(of: ("frontCamera_auto".lowercased())) {
                    arrTestsInSDK.remove(at: ind)
                    
                    arrTestsResultJSONInSDK.append(0)
                    
                    UserDefaults.standard.set(false, forKey: "frontCamera_auto")
                    self.resultJSON["frontCamera_auto"].int = 0
                }
                
                if let ind = arrTestsInSDK.firstIndex(of: ("frontCamera_manual".lowercased())) {
                    arrTestsInSDK.remove(at: ind)
                    
                    arrTestsResultJSONInSDK.append(0)
                    
                    UserDefaults.standard.set(false, forKey: "frontCamera_manual")
                    self.resultJSON["frontCamera_manual"].int = 0
                }
                
                if let ind = arrTestsInSDK.firstIndex(of: ("backCamera_auto".lowercased())) {
                    arrTestsInSDK.remove(at: ind)
                    
                    arrTestsResultJSONInSDK.append(0)
                    
                    UserDefaults.standard.set(false, forKey: "backCamera_auto")
                    self.resultJSON["backCamera_auto"].int = 0
                }
                
                if let ind = arrTestsInSDK.firstIndex(of: ("backCamera_manual".lowercased())) {
                    arrTestsInSDK.remove(at: ind)
                    
                    arrTestsResultJSONInSDK.append(0)
                    
                    UserDefaults.standard.set(false, forKey: "backCamera_manual")
                    self.resultJSON["backCamera_manual"].int = 0
                }
                
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
            
            //Auto-Focus Test
            if arrTestsInSDK.contains("Autofocus".lowercased()) {
                if let ind = arrTestsInSDK.firstIndex(of: ("Autofocus".lowercased())) {
                    arrTestsInSDK.remove(at: ind)
                    
                    if (AppUserDefaults.value(forKey: "AppResultJSON_Data") != nil) {
                        let resultJson = JSON.init(parseJSON: AppUserDefaults.value(forKey: "AppResultJSON_Data") as! String)
                        self.resultJSON = resultJson
                    }
                    
                    if self.isComingFromTestResult {
                        arrTestsResultJSONInSDK.remove(at: retryIndex + 1)
                        arrTestsResultJSONInSDK.insert(0, at: retryIndex + 1)
                    }
                    else {
                        arrTestsResultJSONInSDK.append(0)
                    }
                    
                    UserDefaults.standard.set(false, forKey: "Autofocus")
                    self.resultJSON["Autofocus"].int = 0
                    
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
            }
            
            
            if self.isComingFromTestResult {
                self.navToSummaryPage()
            }
            else {
                self.dismissThisPage()
            }
            
            break
            
        }
    }
    
    //MARK: Custom Methods
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
        
        if self.isFrontCamDone != nil {
            self.isFrontCamDone = nil
        }
        
        if self.isBack1CamDone != nil {
            self.isBack1CamDone = nil
        }
        
        if self.isBack2CamDone != nil {
            self.isBack2CamDone = nil
        }
        
        if self.isBack3CamDone != nil {
            self.isBack3CamDone = nil
        }
        
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
            guard let didFinishRetryDiagnosis = self.cameraRetryDiagnosis else { return }
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




/*
 class CameraVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIGestureRecognizerDelegate {
 
 @IBOutlet weak var cameraCircularProgress: CircularProgressView!
 @IBOutlet weak var cameraPreview: UIView!
 
 var resultJSON = JSON()
 
 var objImagePicker = UIImagePickerController()
 //var objImagePicker : UIImagePickerController?
 
 var cameraManager : CameraManager? = nil
 
 var retryIndex = -1
 var isComingFromTestResult = false
 var cameraRetryDiagnosis: ((_ testJSON: JSON) -> Void)?
 
 deinit {
 cameraManager = nil
 }
 
 override func viewDidLoad() {
 super.viewDidLoad()
 
 self.setStatusBarColor(themeColor: GlobalUtility().AppThemeColor)
 
 cameraCircularProgress.trackClr = UIColor.lightGray
 cameraCircularProgress.progressClr = GlobalUtility().AppThemeColor
 
 }
 
 override func viewWillAppear(_ animated: Bool) {
 super.viewWillAppear(animated)
 
 appDelegate_Obj.orientationLock = .portrait
 
 self.setCustomNavigationBar()
 
 self.openCamera()
 
 }
 
 func setCameraUsingCameraManager() {
 
 //let cameraManager = CameraManager()
 cameraManager = CameraManager()
 cameraManager?.cameraDevice = .front
 cameraManager?.writeFilesToPhoneLibrary = false
 cameraManager?.addPreviewLayerToView(self.cameraPreview)
 
 DispatchQueue.main.asyncAfter(deadline: .now() + 2.0, execute: {
 
 self.cameraManager?.capturePictureWithCompletion({ result in
 
 /*
  switch result {
  case .failure(let err):
  print(err)
  case .success(let content):
  print(content.asImage ?? UIImage())
  }*/
 
 })
 
 self.cameraManager?.cameraDevice = .back
 })
 
 
 DispatchQueue.main.asyncAfter(deadline: .now() + 4.0, execute: {
 
 self.cameraManager?.capturePictureWithCompletion({ result in
 
 self.finishCameraTest()
 
 /*
  switch result {
  case .failure(let err):
  print(err)
  case .success(let content):
  print(content.asImage ?? UIImage())
  }*/
 
 })
 })
 
 }
 
 private func openCamera() {
 switch AVCaptureDevice.authorizationStatus(for: .video) {
 case .authorized:
 // the user has already authorized to access the camera.
 
 //DispatchQueue.main.async {
 //self.checkFrontCamera()
 //}
 
 self.cameraCircularProgress.setProgressWithAnimation(duration: 5.0, value: 1.0)
 self.setCameraUsingCameraManager()
 
 break
 
 case .notDetermined: // the user has not yet asked for camera access.
 AVCaptureDevice.requestAccess(for: .video) { (granted) in
 if granted { // if user has granted to access the camera.
 
 print("the user has granted to access the camera")
 
 //DispatchQueue.main.async {
 //self.checkFrontCamera()
 //}
 
 self.cameraCircularProgress.setProgressWithAnimation(duration: 5.0, value: 1.0)
 self.setCameraUsingCameraManager()
 
 } else {
 print("the user has not granted to access the camera")
 
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
 
 UserDefaults.standard.set(false, forKey: "Camera")
 self.resultJSON["Camera"].int = 0
 
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
 
 
 //Auto-Focus Test
 if arrTestsInSDK.contains("Autofocus") {
 if let ind = arrTestsInSDK.firstIndex(of: ("Autofocus")) {
 arrTestsInSDK.remove(at: ind)
 
 if (AppUserDefaults.value(forKey: "AppResultJSON_Data") != nil) {
 let resultJson = JSON.init(parseJSON: AppUserDefaults.value(forKey: "AppResultJSON_Data") as! String)
 self.resultJSON = resultJson
 }
 
 if self.isComingFromTestResult {
 arrTestsResultJSONInSDK.remove(at: self.retryIndex + 1)
 arrTestsResultJSONInSDK.insert(0, at: self.retryIndex + 1)
 }
 else {
 arrTestsResultJSONInSDK.append(0)
 }
 
 UserDefaults.standard.set(false, forKey: "Autofocus")
 self.resultJSON["Autofocus"].int = 0
 
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
 }
 
 
 if self.isComingFromTestResult {
 self.navToSummaryPage()
 }
 else {
 self.dismissThisPage()
 }
 
 }
 }
 
 break
 
 case .denied:
 print("the user has denied previously to access the camera.")
 
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
 
 UserDefaults.standard.set(false, forKey: "Camera")
 self.resultJSON["Camera"].int = 0
 
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
 
 //Auto-Focus Test
 if arrTestsInSDK.contains("Autofocus") {
 if let ind = arrTestsInSDK.firstIndex(of: ("Autofocus")) {
 arrTestsInSDK.remove(at: ind)
 
 if (AppUserDefaults.value(forKey: "AppResultJSON_Data") != nil) {
 let resultJson = JSON.init(parseJSON: AppUserDefaults.value(forKey: "AppResultJSON_Data") as! String)
 self.resultJSON = resultJson
 }
 
 if self.isComingFromTestResult {
 arrTestsResultJSONInSDK.remove(at: retryIndex + 1)
 arrTestsResultJSONInSDK.insert(0, at: retryIndex + 1)
 }
 else {
 arrTestsResultJSONInSDK.append(0)
 }
 
 UserDefaults.standard.set(false, forKey: "Autofocus")
 self.resultJSON["Autofocus"].int = 0
 
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
 }
 
 
 if self.isComingFromTestResult {
 self.navToSummaryPage()
 }
 else {
 self.dismissThisPage()
 }
 
 break
 
 case .restricted:
 print("the user can't give camera access due to some restriction.")
 
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
 
 UserDefaults.standard.set(false, forKey: "Camera")
 self.resultJSON["Camera"].int = 0
 
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
 
 //Auto-Focus Test
 if arrTestsInSDK.contains("Autofocus") {
 if let ind = arrTestsInSDK.firstIndex(of: ("Autofocus")) {
 arrTestsInSDK.remove(at: ind)
 
 if (AppUserDefaults.value(forKey: "AppResultJSON_Data") != nil) {
 let resultJson = JSON.init(parseJSON: AppUserDefaults.value(forKey: "AppResultJSON_Data") as! String)
 self.resultJSON = resultJson
 }
 
 if self.isComingFromTestResult {
 arrTestsResultJSONInSDK.remove(at: retryIndex + 1)
 arrTestsResultJSONInSDK.insert(0, at: retryIndex + 1)
 }
 else {
 arrTestsResultJSONInSDK.append(0)
 }
 
 UserDefaults.standard.set(false, forKey: "Autofocus")
 self.resultJSON["Autofocus"].int = 0
 
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
 }
 
 
 if self.isComingFromTestResult {
 self.navToSummaryPage()
 }
 else {
 self.dismissThisPage()
 }
 
 break
 
 default:
 print("something has wrong due to we can't access the camera.")
 
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
 
 UserDefaults.standard.set(false, forKey: "Camera")
 self.resultJSON["Camera"].int = 0
 
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
 
 //Auto-Focus Test
 if arrTestsInSDK.contains("Autofocus") {
 if let ind = arrTestsInSDK.firstIndex(of: ("Autofocus")) {
 arrTestsInSDK.remove(at: ind)
 
 if (AppUserDefaults.value(forKey: "AppResultJSON_Data") != nil) {
 let resultJson = JSON.init(parseJSON: AppUserDefaults.value(forKey: "AppResultJSON_Data") as! String)
 self.resultJSON = resultJson
 }
 
 if self.isComingFromTestResult {
 arrTestsResultJSONInSDK.remove(at: retryIndex + 1)
 arrTestsResultJSONInSDK.insert(0, at: retryIndex + 1)
 }
 else {
 arrTestsResultJSONInSDK.append(0)
 }
 
 UserDefaults.standard.set(false, forKey: "Autofocus")
 self.resultJSON["Autofocus"].int = 0
 
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
 }
 
 
 if self.isComingFromTestResult {
 self.navToSummaryPage()
 }
 else {
 self.dismissThisPage()
 }
 
 break
 
 }
 }
 
 func checkFrontCamera() {
 
 self.cameraCircularProgress.setProgressWithAnimation(duration: 5.0, value: 1.0)
 
 if UIImagePickerController.isSourceTypeAvailable(.camera) {
 
 //objImagePicker = UIImagePickerController()
 objImagePicker.delegate = self
 objImagePicker.sourceType = .camera
 objImagePicker.cameraDevice = .front
 objImagePicker.allowsEditing = false
 objImagePicker.showsCameraControls = false
 
 //self.objImagePicker.cameraViewTransform = CGAffineTransformScale(self.objImagePicker.cameraViewTransform, 2.0, 2.0) // change 1.5 to suit your needs
 
 cameraPreview.addSubview(objImagePicker.view)
 
 objImagePicker.view.frame = self.cameraPreview.bounds
 //objImagePicker.view.center = self.cameraPreview.center
 objImagePicker.allowsEditing = false
 objImagePicker.showsCameraControls = false
 objImagePicker.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
 
 DispatchQueue.main.asyncAfter(deadline: .now() + 2.0, execute: {
 self.objImagePicker.takePicture()
 })
 
 //objImagePicker.mediaTypes = [kUTTypeMovie as String] // If you want to start auto recording video by camera
 
 } else {
 debugPrint("Simulator has no camera")
 
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
 
 UserDefaults.standard.set(false, forKey: "Camera")
 self.resultJSON["Camera"].int = 0
 
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
 
 //Auto-Focus Test
 if arrTestsInSDK.contains("Autofocus") {
 if let ind = arrTestsInSDK.firstIndex(of: ("Autofocus")) {
 arrTestsInSDK.remove(at: ind)
 
 if (AppUserDefaults.value(forKey: "AppResultJSON_Data") != nil) {
 let resultJson = JSON.init(parseJSON: AppUserDefaults.value(forKey: "AppResultJSON_Data") as! String)
 self.resultJSON = resultJson
 }
 
 if self.isComingFromTestResult {
 arrTestsResultJSONInSDK.remove(at: retryIndex + 1)
 arrTestsResultJSONInSDK.insert(0, at: retryIndex + 1)
 }
 else {
 arrTestsResultJSONInSDK.append(0)
 }
 
 UserDefaults.standard.set(false, forKey: "Autofocus")
 self.resultJSON["Autofocus"].int = 0
 
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
 }
 
 
 if self.isComingFromTestResult {
 self.navToSummaryPage()
 }
 else {
 self.dismissThisPage()
 }
 }
 
 }
 
 func checkBackCamera() {
 
 if UIImagePickerController.isSourceTypeAvailable(.camera) {
 
 //objImagePicker = UIImagePickerController()
 objImagePicker.delegate = self
 objImagePicker.sourceType = .camera
 objImagePicker.cameraDevice = .rear
 objImagePicker.allowsEditing = false
 objImagePicker.showsCameraControls = false
 
 //self.objImagePicker.cameraViewTransform = CGAffineTransformScale(self.objImagePicker.cameraViewTransform, 2.0, 2.0)
 
 cameraPreview.addSubview(objImagePicker.view)
 
 objImagePicker.view.frame = self.cameraPreview.bounds
 objImagePicker.view.center = self.cameraPreview.center
 objImagePicker.allowsEditing = false
 objImagePicker.showsCameraControls = false
 objImagePicker.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
 
 DispatchQueue.main.asyncAfter(deadline: .now() + 2.0, execute: {
 self.objImagePicker.takePicture()
 })
 
 } else {
 debugPrint("Simulator has no camera")
 
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
 
 UserDefaults.standard.set(false, forKey: "Camera")
 self.resultJSON["Camera"].int = 0
 
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
 
 //Auto-Focus Test
 if arrTestsInSDK.contains("Autofocus") {
 if let ind = arrTestsInSDK.firstIndex(of: ("Autofocus")) {
 arrTestsInSDK.remove(at: ind)
 
 if (AppUserDefaults.value(forKey: "AppResultJSON_Data") != nil) {
 let resultJson = JSON.init(parseJSON: AppUserDefaults.value(forKey: "AppResultJSON_Data") as! String)
 self.resultJSON = resultJson
 }
 
 if self.isComingFromTestResult {
 arrTestsResultJSONInSDK.remove(at: retryIndex + 1)
 arrTestsResultJSONInSDK.insert(0, at: retryIndex + 1)
 }
 else {
 arrTestsResultJSONInSDK.append(0)
 }
 
 UserDefaults.standard.set(false, forKey: "Autofocus")
 self.resultJSON["Autofocus"].int = 0
 
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
 }
 
 
 if self.isComingFromTestResult {
 self.navToSummaryPage()
 }
 else {
 self.dismissThisPage()
 }
 }
 
 }
 
 func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
 
 //case rear = 0
 //case front = 1
 
 if picker.cameraDevice.rawValue == 1 {
 self.checkBackCamera()
 }
 else {
 finishCameraTest()
 }
 
 }
 
 func finishCameraTest() {
 
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
 
 UserDefaults.standard.set(true, forKey: "Camera")
 self.resultJSON["Camera"].int = 1
 
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
 
 //Auto-Focus Test
 if arrTestsInSDK.contains("Autofocus") {
 if let ind = arrTestsInSDK.firstIndex(of: ("Autofocus")) {
 arrTestsInSDK.remove(at: ind)
 
 if (AppUserDefaults.value(forKey: "AppResultJSON_Data") != nil) {
 let resultJson = JSON.init(parseJSON: AppUserDefaults.value(forKey: "AppResultJSON_Data") as! String)
 self.resultJSON = resultJson
 }
 
 if self.isComingFromTestResult {
 arrTestsResultJSONInSDK.remove(at: retryIndex + 1)
 arrTestsResultJSONInSDK.insert(1, at: retryIndex + 1)
 }
 else {
 arrTestsResultJSONInSDK.append(1)
 }
 
 UserDefaults.standard.set(true, forKey: "Autofocus")
 self.resultJSON["Autofocus"].int = 1
 
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
 }
 
 if self.isComingFromTestResult {
 self.navToSummaryPage()
 }
 else {
 self.dismissThisPage()
 }
 }
 
 //MARK: Custom Methods
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
 guard let didFinishRetryDiagnosis = self.cameraRetryDiagnosis else { return }
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
 */


/*
 class CameraVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIGestureRecognizerDelegate , AVCapturePhotoCaptureDelegate {
 
 @IBOutlet weak var cameraCircularProgress: CircularProgressView!
 @IBOutlet weak var cameraPreview: UIView!
 
 var resultJSON = JSON()
 
 var objImagePicker = UIImagePickerController()
 
 var retryIndex = -1
 var isComingFromTestResult = false
 var cameraRetryDiagnosis: ((_ testJSON: JSON) -> Void)?
 
 //
 var isBackClicked = false
 var isFrontClicked = false
 let photoOutput = AVCapturePhotoOutput()
 var cameraLayer : AVCaptureVideoPreviewLayer?
 var captureSession: AVCaptureSession?
 var cameraDevice: AVCaptureDevice?
 
 
 override func viewDidLoad() {
 super.viewDidLoad()
 
 self.setStatusBarColor(themeColor: GlobalUtility().AppThemeColor)
 
 cameraCircularProgress.trackClr = UIColor.lightGray
 cameraCircularProgress.progressClr = GlobalUtility().AppThemeColor
 
 }
 
 override func viewWillAppear(_ animated: Bool) {
 super.viewWillAppear(animated)
 
 appDelegate_Obj.orientationLock = .portrait
 
 self.setCustomNavigationBar()
 
 self.openCamera()
 
 }
 
 private func setupCaptureSession() {
 
 self.cameraCircularProgress.setProgressWithAnimation(duration: 5.0, value: 1.0)
 
 self.captureSession = AVCaptureSession()
 
 if let captureDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: AVMediaType.video, position: .front) {
 
 do {
 let input = try AVCaptureDeviceInput(device: captureDevice)
 if ((captureSession?.canAddInput(input)) != nil) {
 captureSession?.addInput(input)
 }
 } catch let error {
 print("Failed to set input device with error: \(error)")
 }
 
 if ((captureSession?.canAddOutput(photoOutput)) != nil) {
 captureSession?.addOutput(photoOutput)
 }
 
 let cameraLayer = AVCaptureVideoPreviewLayer(session: captureSession ?? AVCaptureSession())
 cameraLayer.frame = self.cameraPreview.bounds
 cameraLayer.videoGravity = .resizeAspectFill
 cameraPreview.layer.addSublayer(cameraLayer)
 
 DispatchQueue.global().async {
 self.captureSession?.startRunning()
 }
 
 DispatchQueue.main.asyncAfter(deadline: .now() + 2.0, execute: {
 
 let photoSettings = AVCapturePhotoSettings()
 if photoSettings.availablePreviewPhotoPixelFormatTypes.first != nil {
 self.photoOutput.capturePhoto(with: photoSettings, delegate: self)
 }
 })
 
 }
 }
 
 //MARK: AVCapturePhotoOutput Delegate
 func photoOutput(_ output: AVCapturePhotoOutput, willBeginCaptureFor resolvedSettings: AVCaptureResolvedPhotoSettings) {
 print("willBeginCaptureFor")
 }
 
 func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
 
 print("didFinishProcessingPhoto")
 
 if self.isFrontClicked {
 self.isBackClicked = true
 }
 
 self.isFrontClicked = true
 
 //guard let isBackCameraClick = self.isBackCameraClicked else { return }
 //isBackCameraClick()
 
 
 if self.isBackClicked == true && self.isFrontClicked == true {
 
 if self.isComingFromTestResult {
 arrTestsResultJSONInSDK.remove(at: retryIndex)
 arrTestsResultJSONInSDK.insert(1, at: retryIndex)
 }
 else {
 arrTestsResultJSONInSDK.append(1)
 }
 
 UserDefaults.standard.set(true, forKey: "Camera")
 self.resultJSON["Camera"].int = 1
 
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
 
 //Auto-Focus Test
 if arrTestsInSDK.contains("Autofocus") {
 if let ind = arrTestsInSDK.firstIndex(of: ("Autofocus")) {
 arrTestsInSDK.remove(at: ind)
 
 if self.isComingFromTestResult {
 arrTestsResultJSONInSDK.remove(at: retryIndex + 1)
 arrTestsResultJSONInSDK.insert(1, at: retryIndex + 1)
 }
 else {
 arrTestsResultJSONInSDK.append(1)
 }
 
 UserDefaults.standard.set(true, forKey: "Autofocus")
 self.resultJSON["Autofocus"].int = 1
 
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
 }
 
 if self.isComingFromTestResult {
 self.navToSummaryPage()
 }
 else {
 self.dismissThisPage()
 }
 
 }else {
 
 self.captureSession = AVCaptureSession()
 
 if let captureDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: AVMediaType.video, position: .back) {
 
 do {
 let input = try AVCaptureDeviceInput(device: captureDevice)
 if ((captureSession?.canAddInput(input)) != nil) {
 captureSession?.addInput(input)
 }
 } catch let error {
 print("Failed to set input device with error: \(error)")
 }
 
 
 let cameraLayer = AVCaptureVideoPreviewLayer(session: captureSession ?? AVCaptureSession())
 cameraLayer.frame = self.cameraPreview.bounds
 cameraLayer.videoGravity = .resizeAspectFill
 cameraPreview.layer.addSublayer(cameraLayer)
 
 DispatchQueue.global().async {
 self.captureSession?.startRunning()
 }
 
 DispatchQueue.main.asyncAfter(deadline: .now() + 2.0, execute: {
 
 let photoSettings = AVCapturePhotoSettings()
 if photoSettings.availablePreviewPhotoPixelFormatTypes.first != nil {
 self.photoOutput.capturePhoto(with: photoSettings, delegate: self)
 }
 })
 
 }
 
 }
 
 }
 
 private func openCamera() {
 switch AVCaptureDevice.authorizationStatus(for: .video) {
 case .authorized:
 // the user has already authorized to access the camera.
 
 DispatchQueue.main.async {
 //self.checkFrontCamera()
 self.setupCaptureSession()
 }
 
 break
 
 case .notDetermined: // the user has not yet asked for camera access.
 AVCaptureDevice.requestAccess(for: .video) { (granted) in
 if granted { // if user has granted to access the camera.
 
 print("the user has granted to access the camera")
 
 DispatchQueue.main.async {
 //self.checkFrontCamera()
 self.setupCaptureSession()
 }
 
 } else {
 print("the user has not granted to access the camera")
 
 if self.isComingFromTestResult {
 arrTestsResultJSONInSDK.remove(at: self.retryIndex)
 arrTestsResultJSONInSDK.insert(0, at: self.retryIndex)
 }
 else {
 arrTestsResultJSONInSDK.append(0)
 }
 
 UserDefaults.standard.set(false, forKey: "Camera")
 self.resultJSON["Camera"].int = 0
 
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
 
 
 //Auto-Focus Test
 if arrTestsInSDK.contains("Autofocus") {
 if let ind = arrTestsInSDK.firstIndex(of: ("Autofocus")) {
 arrTestsInSDK.remove(at: ind)
 
 if self.isComingFromTestResult {
 arrTestsResultJSONInSDK.remove(at: self.retryIndex + 1)
 arrTestsResultJSONInSDK.insert(0, at: self.retryIndex + 1)
 }
 else {
 arrTestsResultJSONInSDK.append(0)
 }
 
 UserDefaults.standard.set(false, forKey: "Autofocus")
 self.resultJSON["Autofocus"].int = 0
 
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
 }
 
 
 if self.isComingFromTestResult {
 self.navToSummaryPage()
 }
 else {
 self.dismissThisPage()
 }
 
 }
 }
 
 break
 
 case .denied:
 print("the user has denied previously to access the camera.")
 
 if self.isComingFromTestResult {
 arrTestsResultJSONInSDK.remove(at: retryIndex)
 arrTestsResultJSONInSDK.insert(0, at: retryIndex)
 }
 else {
 arrTestsResultJSONInSDK.append(0)
 }
 
 UserDefaults.standard.set(false, forKey: "Camera")
 self.resultJSON["Camera"].int = 0
 
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
 
 //Auto-Focus Test
 if arrTestsInSDK.contains("Autofocus") {
 if let ind = arrTestsInSDK.firstIndex(of: ("Autofocus")) {
 arrTestsInSDK.remove(at: ind)
 
 if self.isComingFromTestResult {
 arrTestsResultJSONInSDK.remove(at: retryIndex + 1)
 arrTestsResultJSONInSDK.insert(0, at: retryIndex + 1)
 }
 else {
 arrTestsResultJSONInSDK.append(0)
 }
 
 UserDefaults.standard.set(false, forKey: "Autofocus")
 self.resultJSON["Autofocus"].int = 0
 
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
 }
 
 
 if self.isComingFromTestResult {
 self.navToSummaryPage()
 }
 else {
 self.dismissThisPage()
 }
 
 break
 
 case .restricted:
 print("the user can't give camera access due to some restriction.")
 
 if self.isComingFromTestResult {
 arrTestsResultJSONInSDK.remove(at: retryIndex)
 arrTestsResultJSONInSDK.insert(0, at: retryIndex)
 }
 else {
 arrTestsResultJSONInSDK.append(0)
 }
 
 UserDefaults.standard.set(false, forKey: "Camera")
 self.resultJSON["Camera"].int = 0
 
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
 
 //Auto-Focus Test
 if arrTestsInSDK.contains("Autofocus") {
 if let ind = arrTestsInSDK.firstIndex(of: ("Autofocus")) {
 arrTestsInSDK.remove(at: ind)
 
 if self.isComingFromTestResult {
 arrTestsResultJSONInSDK.remove(at: retryIndex + 1)
 arrTestsResultJSONInSDK.insert(0, at: retryIndex + 1)
 }
 else {
 arrTestsResultJSONInSDK.append(0)
 }
 
 UserDefaults.standard.set(false, forKey: "Autofocus")
 self.resultJSON["Autofocus"].int = 0
 
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
 }
 
 
 if self.isComingFromTestResult {
 self.navToSummaryPage()
 }
 else {
 self.dismissThisPage()
 }
 
 break
 
 default:
 print("something has wrong due to we can't access the camera.")
 
 if self.isComingFromTestResult {
 arrTestsResultJSONInSDK.remove(at: retryIndex)
 arrTestsResultJSONInSDK.insert(0, at: retryIndex)
 }
 else {
 arrTestsResultJSONInSDK.append(0)
 }
 
 UserDefaults.standard.set(false, forKey: "Camera")
 self.resultJSON["Camera"].int = 0
 
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
 
 //Auto-Focus Test
 if arrTestsInSDK.contains("Autofocus") {
 if let ind = arrTestsInSDK.firstIndex(of: ("Autofocus")) {
 arrTestsInSDK.remove(at: ind)
 
 if self.isComingFromTestResult {
 arrTestsResultJSONInSDK.remove(at: retryIndex + 1)
 arrTestsResultJSONInSDK.insert(0, at: retryIndex + 1)
 }
 else {
 arrTestsResultJSONInSDK.append(0)
 }
 
 UserDefaults.standard.set(false, forKey: "Autofocus")
 self.resultJSON["Autofocus"].int = 0
 
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
 }
 
 
 if self.isComingFromTestResult {
 self.navToSummaryPage()
 }
 else {
 self.dismissThisPage()
 }
 
 break
 
 }
 }
 
 func checkFrontCamera() {
 
 self.cameraCircularProgress.setProgressWithAnimation(duration: 5.0, value: 1.0)
 
 if UIImagePickerController.isSourceTypeAvailable(.camera) {
 
 objImagePicker = UIImagePickerController()
 objImagePicker.delegate = self
 objImagePicker.sourceType = .camera
 objImagePicker.cameraDevice = .front
 objImagePicker.allowsEditing = false
 objImagePicker.showsCameraControls = false
 
 self.objImagePicker.cameraViewTransform = CGAffineTransformScale(self.objImagePicker.cameraViewTransform , 2.0, 2.0) // change 1.5 to suit your needs
 
 cameraPreview.addSubview(objImagePicker.view ?? UIView())
 
 objImagePicker.view.frame = self.cameraPreview.bounds
 //objImagePicker.view.center = self.cameraPreview.center
 objImagePicker.allowsEditing = false
 objImagePicker.showsCameraControls = false
 objImagePicker.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
 
 DispatchQueue.main.asyncAfter(deadline: .now() + 2.0, execute: {
 self.objImagePicker.takePicture()
 })
 
 //imagePicker.mediaTypes = [kUTTypeMovie as String] // If you want to start auto recording video by camera
 } else {
 debugPrint("Simulator has no camera")
 
 if self.isComingFromTestResult {
 arrTestsResultJSONInSDK.remove(at: retryIndex)
 arrTestsResultJSONInSDK.insert(0, at: retryIndex)
 }
 else {
 arrTestsResultJSONInSDK.append(0)
 }
 
 UserDefaults.standard.set(false, forKey: "Camera")
 self.resultJSON["Camera"].int = 0
 
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
 
 //Auto-Focus Test
 if arrTestsInSDK.contains("Autofocus") {
 if let ind = arrTestsInSDK.firstIndex(of: ("Autofocus")) {
 arrTestsInSDK.remove(at: ind)
 
 if self.isComingFromTestResult {
 arrTestsResultJSONInSDK.remove(at: retryIndex + 1)
 arrTestsResultJSONInSDK.insert(0, at: retryIndex + 1)
 }
 else {
 arrTestsResultJSONInSDK.append(0)
 }
 
 UserDefaults.standard.set(false, forKey: "Autofocus")
 self.resultJSON["Autofocus"].int = 0
 
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
 }
 
 
 if self.isComingFromTestResult {
 self.navToSummaryPage()
 }
 else {
 self.dismissThisPage()
 }
 }
 
 }
 
 func checkBackCamera() {
 
 if UIImagePickerController.isSourceTypeAvailable(.camera) {
 
 objImagePicker = UIImagePickerController()
 objImagePicker.delegate = self
 objImagePicker.sourceType = .camera
 objImagePicker.cameraDevice = .rear
 objImagePicker.allowsEditing = false
 objImagePicker.showsCameraControls = false
 
 self.objImagePicker.cameraViewTransform = CGAffineTransformScale(self.objImagePicker.cameraViewTransform , 2.0, 2.0)
 
 cameraPreview.addSubview(objImagePicker.view)
 
 objImagePicker.view.frame = self.cameraPreview.bounds
 objImagePicker.view.center = self.cameraPreview.center
 objImagePicker.allowsEditing = false
 objImagePicker.showsCameraControls = false
 objImagePicker.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
 
 DispatchQueue.main.asyncAfter(deadline: .now() + 2.0, execute: {
 self.objImagePicker.takePicture()
 })
 
 } else {
 debugPrint("Simulator has no camera")
 
 if self.isComingFromTestResult {
 arrTestsResultJSONInSDK.remove(at: retryIndex)
 arrTestsResultJSONInSDK.insert(0, at: retryIndex)
 }
 else {
 arrTestsResultJSONInSDK.append(0)
 }
 
 UserDefaults.standard.set(false, forKey: "Camera")
 self.resultJSON["Camera"].int = 0
 
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
 
 //Auto-Focus Test
 if arrTestsInSDK.contains("Autofocus") {
 if let ind = arrTestsInSDK.firstIndex(of: ("Autofocus")) {
 arrTestsInSDK.remove(at: ind)
 
 if self.isComingFromTestResult {
 arrTestsResultJSONInSDK.remove(at: retryIndex + 1)
 arrTestsResultJSONInSDK.insert(0, at: retryIndex + 1)
 }
 else {
 arrTestsResultJSONInSDK.append(0)
 }
 
 UserDefaults.standard.set(false, forKey: "Autofocus")
 self.resultJSON["Autofocus"].int = 0
 
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
 }
 
 
 if self.isComingFromTestResult {
 self.navToSummaryPage()
 }
 else {
 self.dismissThisPage()
 }
 }
 
 }
 
 func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
 
 //case rear = 0
 //case front = 1
 
 if picker.cameraDevice.rawValue == 1 {
 self.checkBackCamera()
 }
 else {
 
 if self.isComingFromTestResult {
 arrTestsResultJSONInSDK.remove(at: retryIndex)
 arrTestsResultJSONInSDK.insert(1, at: retryIndex)
 }
 else {
 arrTestsResultJSONInSDK.append(1)
 }
 
 UserDefaults.standard.set(true, forKey: "Camera")
 self.resultJSON["Camera"].int = 1
 
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
 
 //Auto-Focus Test
 if arrTestsInSDK.contains("Autofocus") {
 if let ind = arrTestsInSDK.firstIndex(of: ("Autofocus")) {
 arrTestsInSDK.remove(at: ind)
 
 if self.isComingFromTestResult {
 arrTestsResultJSONInSDK.remove(at: retryIndex + 1)
 arrTestsResultJSONInSDK.insert(1, at: retryIndex + 1)
 }
 else {
 arrTestsResultJSONInSDK.append(1)
 }
 
 UserDefaults.standard.set(true, forKey: "Autofocus")
 self.resultJSON["Autofocus"].int = 1
 
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
 }
 
 if self.isComingFromTestResult {
 self.navToSummaryPage()
 }
 else {
 self.dismissThisPage()
 }
 }
 
 }
 
 //MARK: Custom Methods
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
 guard let didFinishRetryDiagnosis = self.cameraRetryDiagnosis else { return }
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
 */





