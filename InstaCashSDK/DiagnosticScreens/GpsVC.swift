//
//  GpsVC.swift
//  InstaCashSDK
//
//  Created by Sameer Khan on 29/07/24.
//

import UIKit
import SwiftyJSON
import INTULocationManager
import CoreLocation

import os

var checkLocationState : (() -> Void)?

class GpsVC: UIViewController, CLLocationManagerDelegate {
    
    @IBOutlet weak var lblTestTitle: UILabel!
    @IBOutlet weak var lblTestDesc: UILabel!
    @IBOutlet weak var loaderImgVW: UIImageView!
    
    var resultJSON = JSON()
    
    var gpsTimer: Timer?
    var gpsCount = 0
    
    let locationManager = CLLocationManager()
    
    var isUserTakeAction : Bool = false
    var currentLocation: CLLocation!
    
    var retryIndex = -1
    var isComingFromTestResult = false
    var gpsRetryDiagnosis: ((_ testJSON: JSON) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setStatusBarColor(themeColor: GlobalUtility().AppThemeColor)
        
        self.loaderImgVW.loadGif(name: "ring_loader")        
        
        self.isLocationAccessEnabled()
    }    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        appDelegate_Obj.orientationLock = .portrait
        
        checkLocationState = {
            
            self.isUserTakeAction = true
            
            self.isLocationAccessEnabled()
            
        }
        
        self.setCustomNavigationBar()
        
        self.changeLanguageOfUI()
    }
    
    func changeLanguageOfUI() {
        self.lblTestTitle.text = self.getLocalizatioStringValue(key: "GPS")
        self.lblTestDesc.text = self.getLocalizatioStringValue(key: "Please wait we are checking...")
    }
    
    @objc func runGpsTimer() {
        
        self.gpsCount += 1
        
    }
    
    func dismissThisPage() {
        
        //if self.gpsCount == 2 {
                
        self.locationManager.stopUpdatingLocation()
        //self.locationManager = nil
        
        self.isUserTakeAction = false
        checkLocationState = nil
        
        
        self.gpsTimer?.invalidate()
        self.gpsCount = 0
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: {
            
            self.dismiss(animated: false, completion: {
                guard let didFinishTestDiagnosis = performDiagnostics else { return }
                didFinishTestDiagnosis(self.resultJSON)
            })
            
        })
        
        //}
        
    }
    
    func navToSummaryPage() {
        
        self.locationManager.stopUpdatingLocation()
        
        self.isUserTakeAction = false
        checkLocationState = nil
                
        self.gpsTimer?.invalidate()
        self.gpsCount = 0
        
        self.dismiss(animated: false, completion: {
            guard let didFinishRetryDiagnosis = self.gpsRetryDiagnosis else { return }
            didFinishRetryDiagnosis(self.resultJSON)
        })
        
    }
    
    // MARK: IBActions
    @IBAction func backButtonPressed(_ sender: UIButton) {
        self.dismiss(animated: true, completion: {
            self.gpsTimer?.invalidate()
            
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
            self.gpsTimer?.invalidate()
            
            performDiagnostics = nil
        })
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
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
                        
                        if self.isComingFromTestResult {
                            arrTestsResultJSONInSDK.remove(at: self.retryIndex)
                            arrTestsResultJSONInSDK.insert(1, at: self.retryIndex)
                        }
                        else {
                            arrTestsResultJSONInSDK.append(1)
                        }
                        
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
                        
                        if self.isComingFromTestResult {
                            self.navToSummaryPage()
                        }
                        else {
                            self.dismissThisPage()
                        }
                    }
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
                        
                        if self.isComingFromTestResult {
                            self.navToSummaryPage()
                        }
                        else {
                            self.dismissThisPage()
                        }
                    }
                    
                case .denied:
                    print("No access of location")
                    
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
                    
                    if self.isComingFromTestResult {
                        self.navToSummaryPage()
                    }
                    else {
                        self.dismissThisPage()
                    }
                    
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
                
                if self.isUserTakeAction {
                    
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
                    
                    if self.isComingFromTestResult {
                        self.navToSummaryPage()
                    }
                    else {
                        self.dismissThisPage()
                    }
                }
                else {
                    self.gpsTimer?.invalidate()
                    self.locationManager.requestAlwaysAuthorization()
                }
                
            }
            
        }
        
    }
    
}

extension GpsVC {
    /*
    func gpsTest() {
        
        if #available(iOS 14.0, *) {
            
            switch self.locationManager.authorizationStatus {
            case .authorizedAlways, .authorizedWhenInUse:
                     
     
                self.resultJSON["GPS"].int = 1
                UserDefaults.standard.set(true, forKey: "GPS")
     
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
                self.dismissThisPage()
                
                break
            case .notDetermined, .restricted, .denied:
                
                if gpsCount == 2 {
     
                    self.resultJSON["GPS"].int = 0
                    UserDefaults.standard.set(false, forKey: "GPS")
     
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
                    
                    self.dismissThisPage()
                }
                
                break
                
            default:
                
                if gpsCount == 2 {
     
                    self.resultJSON["GPS"].int = 0
                    UserDefaults.standard.set(false, forKey: "GPS")
     
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
                    
                    self.dismissThisPage()
                }
                
                break
            }
            
        } else {
            
            // Fallback on earlier versions
            if CLLocationManager.locationServicesEnabled() {
                
                switch CLLocationManager.authorizationStatus() {
                case .authorizedAlways, .authorizedWhenInUse:
                         
     
                    self.resultJSON["GPS"].int = 1
                    UserDefaults.standard.set(true, forKey: "GPS")
     
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
                    self.dismissThisPage()
                    
                    break
                    
                case .notDetermined, .restricted, .denied:
                    
                    if gpsCount == 2 {
     
                        self.resultJSON["GPS"].int = 0
                        UserDefaults.standard.set(false, forKey: "GPS")
     
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
                        
                        self.dismissThisPage()
                    }
                    
                    break
                    
                @unknown default:
                    
                    if gpsCount == 2 {
     
                        self.resultJSON["GPS"].int = 0
                        UserDefaults.standard.set(false, forKey: "GPS")
     
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
                        
                        self.dismissThisPage()
                    }
                    
                    break
                }
                
            } else {
                
                if gpsCount == 2 {
     
                    self.resultJSON["GPS"].int = 0
                    UserDefaults.standard.set(false, forKey: "GPS")
     
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
                    
                    self.dismissThisPage()
                }
                
            }
            
        }
        
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        
        if #available(iOS 14.0, *) {
            switch manager.authorizationStatus {
            case .authorizedAlways, .authorizedWhenInUse:
                
                print("Location permission authorize already!")
                break
            case .denied:
                
                if !self.isUserTakeAction {
                    self.gpsTimer?.invalidate()
                    
                    self.openLocationPromptAlert()
                    
                }
                
                break
            case .notDetermined:
                
                if !self.isUserTakeAction {
                    self.gpsTimer?.invalidate()
                    
                    self.openLocationPromptAlert()
                    
                }
                
                break
            case .restricted:
                
                if !self.isUserTakeAction {
                    self.gpsTimer?.invalidate()
                    
                    self.openLocationPromptAlert()
                    
                }
                
                break
            default:
                
                if !self.isUserTakeAction {
                    self.gpsTimer?.invalidate()
                    
                    self.openLocationPromptAlert()
                    
                }
                
                break
            }
        } else {
            
            // Fallback on earlier versions
            if CLLocationManager.locationServicesEnabled() {
                
                switch CLLocationManager.authorizationStatus() {
                case .authorizedAlways, .authorizedWhenInUse:
                    
                    print("Access of location allowed!")
                    break
                    
                case .notDetermined, .restricted, .denied:
                    print("No access of location")
                    
                    if !self.isUserTakeAction {
                        self.gpsTimer?.invalidate()
                        
                        self.openLocationPromptAlert()
                        
                    }
                    
                    break
                    
                @unknown default:
                    
                    if !self.isUserTakeAction {
                        self.gpsTimer?.invalidate()
                        
                        self.openLocationPromptAlert()
                        
                    }
                    
                    break
                }
                
            } else {
                print("Location services not enabled")
                
                if !self.isUserTakeAction {
                    self.gpsTimer?.invalidate()
                    
                    self.openLocationPromptAlert()
                    
                }
                
            }
            
        }
    }
        
    func openLocationPromptAlert() {
        
        let alertController = UIAlertController (title:  "Location Permission Required" , message: "Please enable location permissions in settings.", preferredStyle: .alert)
        
        let settingsAction = UIAlertAction(title: "Settings", style: .default) { (_) -> Void in
            
            self.isUserTakeAction = true
            
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
        
        alertController.addAction(settingsAction)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .default) { (_) -> Void in
     
            self.resultJSON["GPS"].int = 0
            UserDefaults.standard.set(false, forKey: "GPS")
     
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
            
            self.dismissThisPage()
        }
        
        alertController.addAction(cancelAction)
        
        alertController.popoverPresentationController?.sourceView = self.view
        alertController.popoverPresentationController?.sourceRect = self.view.bounds
        
        self.present(alertController, animated: true, completion: nil)
        
    }
    */
}
