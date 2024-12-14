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
                    
                    UserDefaults.standard.set(false, forKey: "camera")
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
                    if arrTestsInSDK.contains("autofocus".lowercased()) {
                        if let ind = arrTestsInSDK.firstIndex(of: ("autofocus".lowercased())) {
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
            
            UserDefaults.standard.set(false, forKey: "camera")
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
            if arrTestsInSDK.contains("autofocus".lowercased()) {
                if let ind = arrTestsInSDK.firstIndex(of: ("autofocus".lowercased())) {
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
            
            UserDefaults.standard.set(false, forKey: "camera")
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
            if arrTestsInSDK.contains("autofocus".lowercased()) {
                if let ind = arrTestsInSDK.firstIndex(of: ("autofocus".lowercased())) {
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
            
            UserDefaults.standard.set(false, forKey: "camera")
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
            if arrTestsInSDK.contains("autofocus".lowercased()) {
                if let ind = arrTestsInSDK.firstIndex(of: ("autofocus".lowercased())) {
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
            
            UserDefaults.standard.set(false, forKey: "camera")
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
            if arrTestsInSDK.contains("autofocus".lowercased()) {
                if let ind = arrTestsInSDK.firstIndex(of: ("autofocus".lowercased())) {
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
            
            UserDefaults.standard.set(false, forKey: "camera")
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
            if arrTestsInSDK.contains("autofocus".lowercased()) {
                if let ind = arrTestsInSDK.firstIndex(of: ("autofocus".lowercased())) {
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
        
        UserDefaults.standard.set(true, forKey: "camera")
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
        if arrTestsInSDK.contains("autofocus".lowercased()) {
            if let ind = arrTestsInSDK.firstIndex(of: ("autofocus".lowercased())) {
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
                
                UserDefaults.standard.set(true, forKey: "camera")
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
                if arrTestsInSDK.contains("autofocus".lowercased()) {
                    if let ind = arrTestsInSDK.firstIndex(of: ("autofocus".lowercased())) {
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
                    
                    UserDefaults.standard.set(false, forKey: "camera")
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
                    if arrTestsInSDK.contains("autofocus".lowercased()) {
                        if let ind = arrTestsInSDK.firstIndex(of: ("autofocus".lowercased())) {
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
            
            UserDefaults.standard.set(false, forKey: "camera")
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
            if arrTestsInSDK.contains("autofocus".lowercased()) {
                if let ind = arrTestsInSDK.firstIndex(of: ("autofocus".lowercased())) {
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
            
            UserDefaults.standard.set(false, forKey: "camera")
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
            if arrTestsInSDK.contains("autofocus".lowercased()) {
                if let ind = arrTestsInSDK.firstIndex(of: ("autofocus".lowercased())) {
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
            
            UserDefaults.standard.set(false, forKey: "camera")
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
            if arrTestsInSDK.contains("autofocus".lowercased()) {
                if let ind = arrTestsInSDK.firstIndex(of: ("autofocus".lowercased())) {
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
            
            UserDefaults.standard.set(false, forKey: "camera")
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
            if arrTestsInSDK.contains("autofocus".lowercased()) {
                if let ind = arrTestsInSDK.firstIndex(of: ("autofocus".lowercased())) {
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
            
            UserDefaults.standard.set(false, forKey: "camera")
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
            if arrTestsInSDK.contains("autofocus".lowercased()) {
                if let ind = arrTestsInSDK.firstIndex(of: ("autofocus".lowercased())) {
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
            
            UserDefaults.standard.set(true, forKey: "camera")
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
            if arrTestsInSDK.contains("autofocus".lowercased()) {
                if let ind = arrTestsInSDK.firstIndex(of: ("autofocus".lowercased())) {
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





