//
//  ScreenCalibrationVC.swift
//  InstaCash_Diagnostics
//
//  Created by Sameer Khan on 23/07/24.
//

import UIKit
import SwiftyJSON

import os

class ScreenCalibrationVC: UIViewController {
    
    @IBOutlet weak var lblTestTitle: UILabel!
    @IBOutlet weak var lblTestDesc: UILabel!
    @IBOutlet weak var btnStartTest: UIButton!

    var resultJSON = JSON()
    
    var obstacleViews : [UIView] = []
    var flags: [Bool] = []
    var countdownTimer: Timer!
    var totalTime = 40
    var startTest = false
    
    var retryIndex = -1
    var isComingFromTestResult = false
    var screenRetryDiagnosis: ((_ testJSON: JSON) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setStatusBarColor(themeColor: GlobalUtility().AppThemeColor)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        appDelegate_Obj.orientationLock = .portrait
        
        self.setCustomNavigationBar()                
        
    }
    
    // MARK: IBActions
    @IBAction func startBtnPressed(_ sender: UIButton) {
        drawScreenBoxs()
    }
    
    //MARK: Screen Box Method
    func drawScreenBoxs() {
        
        let screenSize = UIScreen.main.bounds
        let screenWidth = screenSize.width + 10
        let screenHeight = screenSize.height + 20
        
        let widthParameter : Int = Int(screenWidth/10)
        let heightParameter : Int = Int(screenHeight/15)
        
        var x = 0
        var y = 0
        
        //for (indr, _) in (0..<15).enumerated() {
        //for (indc, _) in (0..<10).enumerated() {
        //bxView.layer.borderColor = indr == 1 ? UIColor.magenta.cgColor : UIColor.red.cgColor
        
        for _ in (0..<15) {
            
            for _ in (0..<10) {
                
                let bxView = LevelView(frame: CGRect(x: x, y: y, width: widthParameter, height: heightParameter))
                x = x + widthParameter
                
                obstacleViews.append(bxView)
                flags.append(false)
                self.view.addSubview(bxView)
                
            }
            
            x = 0
            y = y + heightParameter
            
        }
        
        startTest = true
        startTimer()
        
        self.navigationController?.navigationBar.isHidden = true
        
    }
    
    func startTimer() {
        countdownTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.updateTime), userInfo: nil, repeats: true)
    }
    
    @objc func updateTime() {
        if totalTime != 0 {
            //print("totalTime", totalTime)
            totalTime -= 1
        } else {
            endTimer(type: 0)
        }
    }
    
    func endTimer(type : Int) {
        
        countdownTimer.invalidate()
        
        if type == 1 {
            
            if (AppUserDefaults.value(forKey: "AppResultJSON_Data") != nil) {
                let resultJson = JSON.init(parseJSON: AppUserDefaults.value(forKey: "AppResultJSON_Data") as! String)
                self.resultJSON = resultJson
            }
         
            self.removeGreenLayer()
            
            if self.isComingFromTestResult {
                arrTestsResultJSONInSDK.remove(at: retryIndex)
                arrTestsResultJSONInSDK.insert(1, at: retryIndex)
            }
            else {
                arrTestsResultJSONInSDK.append(1)
            }
            
            UserDefaults.standard.set(true, forKey: "Screen")
            self.resultJSON["Screen"].int = 1
            
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
                        
            self.ShowGlobalPopUp()
        }
        
    }
    
    func removeGreenLayer() {
        for bxV in self.obstacleViews {
            bxV.removeFromSuperview()
        }
        
        self.obstacleViews = []
    }
    
    //MARK: UITouch Event Methods
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        boxTouched(touches: touches)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        boxTouched(touches: touches)
    }
    
    func boxTouched(touches : Set<UITouch>) {
        
        // Get the first touch and its location in this view controller's view coordinate system
        let firstTouch = touches.first
        let touchLocation = firstTouch?.location(in: self.view)
        var finalFlag = true
        
        for (index, obstacleVW) in obstacleViews.enumerated() {
            // Convert the location of the obstacle view to this view controller's view coordinate system
            let obstacleVWFrame = self.view.convert(obstacleVW.frame, from: obstacleVW.superview)
            
            // Check if the touch is inside the obstacle view
            if obstacleVWFrame.contains(touchLocation ?? CGPointZero) {
                flags[index] = true
                
                let levelLayer = CAShapeLayer()
                levelLayer.path = UIBezierPath(roundedRect: CGRect(x: 0, y: 0, width: obstacleVWFrame.width + 10, height: obstacleVWFrame.height), cornerRadius: 0).cgPath
                levelLayer.fillColor = AppThemeColor.cgColor
                obstacleVW.layer.addSublayer(levelLayer)
                
            }
            
            finalFlag = flags[index] && finalFlag
            
        }
        
        if finalFlag && startTest {
            endTimer(type: 1)
        }
        
        
    }
    
    //MARK: Custom Method
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
            guard let didFinishRetryDiagnosis = self.screenRetryDiagnosis else { return }
            didFinishRetryDiagnosis(self.resultJSON)
        })
        
    }
    
    func ShowGlobalPopUp() {
        
        let popUpVC = self.storyboard?.instantiateViewController(withIdentifier: "GlobalSkipPopUpVC") as! GlobalSkipPopUpVC
        
        popUpVC.strTitle = "Test Failed!"
        popUpVC.strMessage = "Do you want to retry the test?"
        popUpVC.strBtnYesTitle = "Yes"
        popUpVC.strBtnNoTitle = "No"
        popUpVC.strBtnRetryTitle = ""
        popUpVC.isShowThirdBtn = false
        
        popUpVC.userConsent = { btnTag in
            switch btnTag {
            case 1:
                
                print("Screen Test Retry!")
                self.totalTime = 40
                
                //self.startTest = true
                //self.startTimer()
                
                self.drawScreenBoxs()
                
            case 2:
                
                print("Screen Test Failed!")
                
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
                
                UserDefaults.standard.set(false, forKey: "Screen")
                self.resultJSON["Screen"].int = 0
                
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
                
                break
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

class LevelView : UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.layer.borderWidth = 1.0
        let levelLayer = CAShapeLayer()
        levelLayer.path = UIBezierPath(roundedRect: CGRect(x: 0,
                                                           y: 0,
                                                           width: frame.width,
                                                           height: frame.height),
                                       cornerRadius: 0).cgPath
        
        levelLayer.fillColor = UIColor.lightGray.cgColor
        
        self.layer.addSublayer(levelLayer)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
}
