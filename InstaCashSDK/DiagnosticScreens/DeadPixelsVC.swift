//
//  DeadPixelsVC.swift
//  InstaCash_Diagnostics
//
//  Created by Sameer Khan on 23/07/24.
//

import UIKit
import SwiftyJSON

import os

class DeadPixelsVC: UIViewController {
    
    @IBOutlet weak var lblTestTitle: UILabel!
    @IBOutlet weak var lblTestDesc: UILabel!
    @IBOutlet weak var btnStartTest: UIButton!
    @IBOutlet weak var loaderImgVW: UIImageView!
    
    var resultJSON = JSON()
    var testPixelView = UIView()
    var pixelTimer: Timer?
    var pixelTimerIndex = 0
    
    var retryIndex = -1
    var isComingFromTestResult = false
    var deadPixelRetryDiagnosis: ((_ testJSON: JSON) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setStatusBarColor(themeColor: GlobalUtility().AppThemeColor)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        appDelegate_Obj.orientationLock = .portrait
        
        self.setCustomNavigationBar()
        
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
            self.pixelTimer?.invalidate()
            
            self.pixelTimerIndex = 0
            performDiagnostics = nil
        })
    }
    
    func dismissThisPage() {
        
        self.dismiss(animated: false, completion: {
            guard let didFinishTestDiagnosis = performDiagnostics else { return }
            didFinishTestDiagnosis(self.resultJSON)
        })
        
    }
    
    func navToSummaryPage() {
        
        self.dismiss(animated: false, completion: {
            guard let didFinishRetryDiagnosis = self.deadPixelRetryDiagnosis else { return }
            didFinishRetryDiagnosis(self.resultJSON)
        })
        
    }
    
    // MARK: IBActions
    @IBAction func startTestButtonPressed(_ sender: UIButton) {
        
        let screenSize: CGRect = UIScreen.main.bounds
        self.testPixelView.frame = screenSize
        self.testPixelView.backgroundColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        self.view.addSubview(self.testPixelView)
        
        self.navigationController?.navigationBar.isHidden = true
        
        DispatchQueue.main.async {
            self.pixelTimer = Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(self.setRandomBackgroundColor), userInfo: nil, repeats: true)
        }
        
    }
    
    @objc func setRandomBackgroundColor() {
        self.pixelTimerIndex += 1
        
        let colors = [
            #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1),#colorLiteral(red: 0, green: 0.003921568627, blue: 0.9843137255, alpha: 1),#colorLiteral(red: 0.003921568627, green: 0.003921568627, blue: 0.003921568627, alpha: 1),#colorLiteral(red: 0.9960784314, green: 0, blue: 0, alpha: 1),#colorLiteral(red: 0, green: 1, blue: 0.003921568627, alpha: 1),#colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        ]
        
        switch self.pixelTimerIndex {
            
        case 5:
            
            self.testPixelView.removeFromSuperview()
            //self.pixelView.isHidden = !self.pixelView.isHidden
            
            self.pixelTimer?.invalidate()            
            
            self.navigationController?.navigationBar.isHidden = false
            self.ShowPopUpForDeadPixel()
            
            break
            
        default:
            
            if self.pixelTimerIndex < colors.count {
                DispatchQueue.main.async {
                    self.testPixelView.backgroundColor = colors[self.pixelTimerIndex]
                }
            }
            
        }
        
    }
    
    func ShowPopUpForDeadPixel() {
        
        let popUpVC = self.storyboard?.instantiateViewController(withIdentifier: "GlobalSkipPopUpVC") as! GlobalSkipPopUpVC
        
        popUpVC.strTitle = "Dead Pixels"
        popUpVC.strMessage = "Did you find any spot?"
        popUpVC.strBtnYesTitle = "Yes"
        popUpVC.strBtnNoTitle = "No"
        popUpVC.strBtnRetryTitle = "Retry"
        popUpVC.isShowThirdBtn = false
        
        popUpVC.userConsent = { btnTag in
            switch btnTag {
            case 1:
                
                print("Dead Pixel Failed!")
                
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
                
                self.resultJSON["Dead Pixels"].int = 0
                UserDefaults.standard.set(false, forKey: "deadPixel")
                
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
                
            case 2:
                
                print("Dead Pixel Passed!")
                
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
                
                self.resultJSON["Dead Pixels"].int = 1
                UserDefaults.standard.set(true, forKey: "deadPixel")
                
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
                
            default:
                
                self.pixelTimerIndex = 0
                
                self.startTestButtonPressed(UIButton())
                
            }
        }
        
        popUpVC.modalPresentationStyle = .overFullScreen
        self.present(popUpVC, animated: false) { }
        
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    
}
