//
//  SpeakerVC.swift
//  InstaCash_Diagnostics
//
//  Created by Sameer Khan on 23/07/24.
//

import UIKit
import SwiftyJSON
import AVFoundation
import Toast_Swift

import os

class SpeakerVC: UIViewController {    
    
    @IBOutlet weak var topSpeakerView: UIView!
    @IBOutlet weak var topLblTestTitle: UILabel!
    @IBOutlet weak var topLblTestDesc: UILabel!
    @IBOutlet weak var topTxtFieldSpeaker: UITextField!
    @IBOutlet weak var topBtnStartSpeaker: UIButton!
    @IBOutlet weak var topBtnRetrySpeaker: UIButton!
    @IBOutlet weak var topLoaderImgVW: UIImageView!
    
    @IBOutlet weak var bottomSpeakerView: UIView!
    @IBOutlet weak var bottomLblTestTitle: UILabel!
    @IBOutlet weak var bottomLblTestDesc: UILabel!
    @IBOutlet weak var bottomTxtFieldSpeaker: UITextField!
    @IBOutlet weak var bottomBtnStartSpeaker: UIButton!
    @IBOutlet weak var bottomBtnRetrySpeaker: UIButton!
    @IBOutlet weak var bottomLoaderImgVW: UIImageView!
    
    var resultJSON = JSON()
    
    var num1 = 0
    var num2 = 0
    var num3 = 0
    var num4 = 0
    
    var soundFiles = ["zero", "one", "two", "three", "four", "five", "six", "seven", "eight", "nine"]
    
    var audioPlayer: AVAudioPlayer!
    var audioSession: AVAudioSession?
    
    var isTopSpeakerPass = false
    var isBottomSpeakerPass = false
    
    var retryIndex = -1
    var isComingFromTestResult = false
    var speakerRetryDiagnosis: ((_ testJSON: JSON) -> Void)?    
    
    var isComeForTopSpeaker = false
    var isComeForBottomSpeaker = false
    
    var isComeForTopAutoTest = false
    var isComeForBottomAutoTest = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setStatusBarColor(themeColor: GlobalUtility().AppThemeColor)
        
        self.topLoaderImgVW.loadGif(name: "ring_loader")
        self.bottomLoaderImgVW.loadGif(name: "ring_loader")
                
    }        
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        appDelegate_Obj.orientationLock = .portrait
        
        self.setUIElementsProperties()
        
        self.hideKeyboardWhenTappedAroundView()
        
        self.setCustomNavigationBar()
        
        self.changeLanguageOfUI()
        
        if self.isComeForTopSpeaker {
            self.topSpeakerView.isHidden = false
            self.bottomSpeakerView.isHidden = true
        }
        else {
            self.topSpeakerView.isHidden = true
            self.bottomSpeakerView.isHidden = false
        }
        
    }
    
    func changeLanguageOfUI() {
        
        self.topLblTestTitle.text = self.getLocalizatioStringValue(key: "Top Speakers")
        self.topLblTestDesc.text = self.getLocalizatioStringValue(key: "Listen number from top speaker by clicking on start button")
        self.topTxtFieldSpeaker.placeholder = self.getLocalizatioStringValue(key: "")
        self.topBtnStartSpeaker.setTitle(self.getLocalizatioStringValue(key: "Start"), for: .normal)
        self.topBtnRetrySpeaker.setTitle(self.getLocalizatioStringValue(key: "Retry"), for: .normal)
                
        
        self.bottomLblTestTitle.text = self.getLocalizatioStringValue(key: "Bottom Speakers")
        self.bottomLblTestDesc.text = self.getLocalizatioStringValue(key: "Listen number from bottom speaker by clicking on start button")
        self.bottomTxtFieldSpeaker.placeholder = self.getLocalizatioStringValue(key: "")
        self.bottomBtnStartSpeaker.setTitle(self.getLocalizatioStringValue(key: "Start"), for: .normal)
        self.bottomBtnRetrySpeaker.setTitle(self.getLocalizatioStringValue(key: "Retry"), for: .normal)
        
    }
    
    // MARK: Custom Methods
    func setUIElementsProperties() {
        
        self.topTxtFieldSpeaker.layer.cornerRadius = 20.0
        self.topTxtFieldSpeaker.layer.borderWidth = 1.0
        self.topTxtFieldSpeaker.layer.borderColor = UIColor.lightGray.cgColor
        
        self.bottomTxtFieldSpeaker.layer.cornerRadius = 20.0
        self.bottomTxtFieldSpeaker.layer.borderWidth = 1.0
        self.bottomTxtFieldSpeaker.layer.borderColor = UIColor.lightGray.cgColor
        
    }
    
    // MARK: IBActions
    @IBAction func backButtonPressed(_ sender: UIButton) {
        self.dismiss(animated: true, completion: {            
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
        
        
        if #available(iOS 13.0, *) {
            UINavigationBar.appearance().setBackgroundImage(UIImage(), for: .default)
            UINavigationBar.appearance().shadowImage = UIImage()
            UINavigationBar.appearance().isTranslucent = true
        } else {
            // Fallback on earlier versions
        }
        
    }
    
    @objc func backBtnPressed() {
        self.dismiss(animated: true, completion: {
            performDiagnostics = nil
        })
    }
    
    @IBAction func topSpeakerStartBtnPressed(_ sender: UIButton) {
        self.view.endEditing(true)
        
        if sender.titleLabel?.text == self.getLocalizatioStringValue(key: "Start") {
            
            self.topBtnStartSpeaker.isUserInteractionEnabled = true
            
            self.playSoundFromTopSpeaker()
            
        }
        else {
            
            guard !(self.topTxtFieldSpeaker.text?.isEmpty ?? false) else {
                
                DispatchQueue.main.async() {
                    self.view.makeToast(self.getLocalizatioStringValue(key: "Please Enter Top Speaker Code"), duration: 2.0, position: .bottom)
                }
                
                return
            }
            
            if self.topTxtFieldSpeaker.text == String(self.num1) + String(self.num2) {
                
                self.isTopSpeakerPass = true
                self.topTxtFieldSpeaker.text = ""
                
                self.topLoaderImgVW.image = UIImage(named: "rightGreen")
                
            }else {
                
                self.isTopSpeakerPass = false
                self.topTxtFieldSpeaker.text = ""
                
            }
            
            UIView.animate(withDuration: 0.1, animations: {
                
                //self.topSpeakerView.isHidden = true
                //self.bottomSpeakerView.isHidden = false
                
                if (self.isTopSpeakerPass) {
                    
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
                                                    
                    
                    if self.isComeForTopAutoTest {
                        
                        self.resultJSON["top speaker_auto"].int = 1
                        UserDefaults.standard.set(true, forKey: "top speaker_auto")
                        
                    }
                    else {
                        
                        self.resultJSON["top speaker"].int = 1
                        UserDefaults.standard.set(true, forKey: "top speaker")
                        
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
                    
                    //self.resultJSON["Speakers"].int = 0
                    //UserDefaults.standard.set(false, forKey: "Speakers")
                                        
                    if self.isComeForTopAutoTest {
                        self.resultJSON["top speaker_auto"].int = 0
                        UserDefaults.standard.set(false, forKey: "top speaker_auto")
                    }
                    else {
                        self.resultJSON["top speaker"].int = 0
                        UserDefaults.standard.set(false, forKey: "top speaker")
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
                }
                
                if self.isComingFromTestResult {
                    self.navToSummaryPage()
                }
                else {
                    self.dismissThisPage()
                }
                
            })
            
        }
        
    }
    
    @IBAction func topSpeakerRetryBtnPressed(_ sender: UIButton) {
        self.view.endEditing(true)
        
        self.ShowGlobalPopUpForRetryTopSpeaker()
        
    }
    
    func ShowGlobalPopUpForRetryTopSpeaker() {
        
        let popUpVC = self.storyboard?.instantiateViewController(withIdentifier: "GlobalSkipPopUpVC") as! GlobalSkipPopUpVC
        
        popUpVC.strTitle = "Are you sure you want to restart?"
        popUpVC.strMessage = ""
        popUpVC.strBtnYesTitle = "Yes"
        popUpVC.strBtnNoTitle = "No"
        popUpVC.strBtnRetryTitle = ""
        popUpVC.isShowThirdBtn = false
        
        popUpVC.userConsent = { btnTag in
            switch btnTag {
            case 1:
                
                self.topBtnRetrySpeaker.isUserInteractionEnabled = true
                
                self.playSoundFromTopSpeaker()
                
            case 2:
                
                break
                
            default:
                
                break
            }
        }
        
        popUpVC.modalPresentationStyle = .overFullScreen
        self.present(popUpVC, animated: false) { }
        
    }
    
    @IBAction func bottomSpeakerStartBtnPressed(_ sender: UIButton) {
        self.view.endEditing(true)
        
        if sender.titleLabel?.text == self.getLocalizatioStringValue(key: "Start") {
            
            self.bottomBtnStartSpeaker.isUserInteractionEnabled = true
            
            self.playSoundFromBottomSpeaker()
            
        }
        else {
            
            guard !(self.bottomTxtFieldSpeaker.text?.isEmpty ?? false) else {
                
                DispatchQueue.main.async() {
                    self.view.makeToast(self.getLocalizatioStringValue(key: "Please Enter Bottom Speaker Code"), duration: 2.0, position: .bottom)
                }
                
                return
            }
            
            if self.bottomTxtFieldSpeaker.text == String(self.num3) + String(self.num4) {
                
                self.isBottomSpeakerPass = true
                self.bottomTxtFieldSpeaker.text = ""
                
                self.bottomLoaderImgVW.image = UIImage(named: "rightGreen")
                
            }else {
                
                self.isBottomSpeakerPass = false
                self.bottomTxtFieldSpeaker.text = ""
                
            }
            
            
            if (self.isBottomSpeakerPass) {
                
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
                                                
                
                //self.resultJSON["Speakers"].int = 1
                //UserDefaults.standard.set(true, forKey: "Speakers")
                                
                
                if self.isComeForBottomAutoTest {
                    self.resultJSON["bottom speaker_auto"].int = 1
                    UserDefaults.standard.set(true, forKey: "bottom speaker_auto")
                }
                else {
                    self.resultJSON["bottom speaker"].int = 1
                    UserDefaults.standard.set(true, forKey: "bottom speaker")
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
                
                //self.resultJSON["Bottom Speakers"].int = 0
                //UserDefaults.standard.set(false, forKey: "Bottom Speakers")
                
                if self.isComeForBottomAutoTest {
                    self.resultJSON["bottom speaker_auto"].int = 0
                    UserDefaults.standard.set(false, forKey: "bottom speaker_auto")
                }
                else {
                    self.resultJSON["bottom speaker"].int = 0
                    UserDefaults.standard.set(false, forKey: "bottom speaker")
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
            }
            
            if self.isComingFromTestResult {
                self.navToSummaryPage()
            }
            else {
                self.dismissThisPage()
            }
            
        }
        
    }
    
    @IBAction func bottomSpeakerRetryBtnPressed(_ sender: UIButton) {
        self.view.endEditing(true)
        
        self.ShowGlobalPopUpForRetryBottomSpeaker()
    }
    
    func ShowGlobalPopUpForRetryBottomSpeaker() {
        
        let popUpVC = self.storyboard?.instantiateViewController(withIdentifier: "GlobalSkipPopUpVC") as! GlobalSkipPopUpVC
        
        popUpVC.strTitle = "Are you sure you want to restart?"
        popUpVC.strMessage = ""
        popUpVC.strBtnYesTitle = "Yes"
        popUpVC.strBtnNoTitle = "No"
        popUpVC.strBtnRetryTitle = ""
        popUpVC.isShowThirdBtn = false
        
        popUpVC.userConsent = { btnTag in
            switch btnTag {
            case 1:
                
                self.bottomBtnRetrySpeaker.isUserInteractionEnabled = true
                
                self.playSoundFromBottomSpeaker()
                
            case 2:
                
                break
                
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
    
    // Function to apply an equalizer for boosting loudness
        private func applyEqualizer(to player: AVAudioPlayer) {
            let audioEngine = AVAudioEngine()
            let playerNode = AVAudioPlayerNode()
            let eq = AVAudioUnitEQ(numberOfBands: 1)

            eq.bands[0].frequency = 500  // Mid-range frequency
            eq.bands[0].gain = 50.0        // Boost (adjust if needed)
            eq.bands[0].bypass = false

            audioEngine.attach(playerNode)
            audioEngine.attach(eq)
            
            audioEngine.connect(playerNode, to: eq, format: nil)
            audioEngine.connect(eq, to: audioEngine.outputNode, format: nil)

            try? audioEngine.start()
            playerNode.play()
        }
    
    func playSoundFromTopSpeaker() {
        
        // To play number from earpiece speaker (upper speaker)
        let randomSoundFile = Int(arc4random_uniform(UInt32(self.soundFiles.count)))
        print("randomSoundFile" , randomSoundFile)
        self.num1 = randomSoundFile
        
        guard let filePath = Bundle.main.path(forResource: self.soundFiles[randomSoundFile], ofType: "wav") else {
            return
        }
        
        // To play number from earpiece speaker (upper speaker)
        self.audioSession = AVAudioSession.sharedInstance()
        //print("Configuring audio session")
        
        do {
            //try self.audioSession?.setCategory(AVAudioSession.Category.playAndRecord)
            
            try self.audioSession?.setCategory(.playAndRecord, mode: .voiceChat, options: [.defaultToSpeaker, .allowBluetooth])
            
            try self.audioSession?.setActive(true)
            
            try self.audioSession?.overrideOutputAudioPort(AVAudioSession.PortOverride.none)
            
            //print("Successfully configured audio session (SPEAKER-Upper).", "\nCurrent audio route: ",self.audioSession?.currentRoute.outputs ?? 0)
            
        } catch let error as NSError {
            print("#configureAudioSessionToEarpieceSpeaker Error \(error.localizedDescription)")
        }
        
        
        do {
            self.audioPlayer = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: filePath))
            //self.audioPlayer.volume = .greatestFiniteMagnitude
            
            //self.audioPlayer.volume = 1.0
            // Apply an equalizer to boost mid frequencies (for louder effect without distortion)
            //self.applyEqualizer(to: self.audioPlayer!)
            
            self.audioPlayer.play()
            
        } catch let error {
            print(error.localizedDescription)
        }
        
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            
            let randomSoundFile = Int(arc4random_uniform(UInt32(self.soundFiles.count)))
            print("randomSoundFile" , randomSoundFile)
            self.num2 = randomSoundFile
            
            guard let filePath = Bundle.main.path(forResource: self.soundFiles[randomSoundFile], ofType: "wav") else {
                return
            }
            
            do {
                self.audioPlayer = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: filePath))
                //self.audioPlayer.volume = .greatestFiniteMagnitude
                self.audioPlayer.play()
                
                self.topBtnStartSpeaker.isUserInteractionEnabled = true
                self.topBtnStartSpeaker.setTitle(self.getLocalizatioStringValue(key: "Submit"), for: .normal)
                
                self.topTxtFieldSpeaker.isHidden = false
                self.topBtnRetrySpeaker.isHidden = false
                
            } catch let error {
                print(error.localizedDescription)
            }
            
        }
        
    }
    
    func playSoundFromBottomSpeaker() {
        
        let randomSoundFile = Int(arc4random_uniform(UInt32(soundFiles.count)))
        print(randomSoundFile)
        self.num3 = randomSoundFile
        
        guard let filePath = Bundle.main.path(forResource: self.soundFiles[randomSoundFile], ofType: "wav") else {
            return
        }
        
        // This is to audio output from bottom (main) speaker
        self.audioSession = AVAudioSession.sharedInstance()
        //print("Configuring audio session")
        
        do {
            
            try self.audioSession?.setCategory(AVAudioSession.Category.playAndRecord)
            try self.audioSession?.setActive(true)
            try self.audioSession?.overrideOutputAudioPort(AVAudioSession.PortOverride.speaker)
                        
            //print("AVAudio Session out options: ", self.audioSession?.currentRoute ?? "")
            //print("Successfully configured audio session (SPEAKER-Bottom).", "\nCurrent audio route: ",self.audioSession?.currentRoute.outputs ?? 0)
            
        } catch let error as NSError {
            print("#configureAudioSessionToSpeaker Error \(error.localizedDescription)")
        }
        
        
        do {
            self.audioPlayer = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: filePath))
            //self.audioPlayer.volume = .greatestFiniteMagnitude
            self.audioPlayer.play()
            
        } catch let error {
            print(error.localizedDescription)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            
            let randomSoundFile = Int(arc4random_uniform(UInt32(self.soundFiles.count)))
            print(randomSoundFile)
            self.num4 = randomSoundFile
            
            guard let filePath = Bundle.main.path(forResource: self.soundFiles[randomSoundFile], ofType: "wav") else {
                return
            }
            
            do {
                self.audioPlayer = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: filePath))
                //self.audioPlayer.volume = .greatestFiniteMagnitude
                self.audioPlayer.play()
                
                self.bottomBtnStartSpeaker.isUserInteractionEnabled = true
                self.bottomBtnStartSpeaker.setTitle(self.getLocalizatioStringValue(key: "Submit"), for: .normal)
                
                self.bottomTxtFieldSpeaker.isHidden = false
                self.bottomBtnRetrySpeaker.isHidden = false
                
            } catch let error {
                print(error.localizedDescription)
            }
            
        }
        
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
            guard let didFinishRetryDiagnosis = self.speakerRetryDiagnosis else { return }
            didFinishRetryDiagnosis(self.resultJSON)
        })
        
    }
    
}
