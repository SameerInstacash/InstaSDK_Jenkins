//
//  MicroPhoneVC.swift
//  InstaCash_Diagnostics
//
//  Created by Sameer Khan on 23/07/24.
//

import UIKit
import SwiftyJSON
import AVFoundation
import CoreAudio

import os

class MicroPhoneVC: UIViewController, RecorderDelegate {        
    
    @IBOutlet weak var lblTestTitle: UILabel!
    @IBOutlet weak var lblTestDesc: UILabel!
    @IBOutlet weak var btnStartRecording: UIButton!
    @IBOutlet weak var lblCounter: UILabel!
    @IBOutlet weak var loaderImgVW: UIImageView!
    
    var resultJSON = JSON()
        
    var recordingSession: AVAudioSession?
    var recording: Recording!
    var recordDuration = 0
    var isBitRate = false
    var micTimer: Timer?
    var micCount = 0
    
    var isBottomCheck = false
    var isTopCheck = false
    
    var isBottomPass = false
    var isTopPass = false
    
    var retryIndex = -1
    var isComingFromTestResult = false
    var micRetryDiagnosis: ((_ testJSON: JSON) -> Void)?        
    
    var isComeForTopMic = false
    var isComeForBottomMic = false

    override func viewDidLoad() {
        super.viewDidLoad()

        self.setStatusBarColor(themeColor: GlobalUtility().AppThemeColor)

        self.loaderImgVW.loadGif(name: "ring_loader")                
        
        self.checkMicPermission()
    }        
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        appDelegate_Obj.orientationLock = .portrait
        
        self.setCustomNavigationBar()
        
        self.changeLanguageOfUI()
        
        /*
        print("All inputs before: ",self.recordingSession?.availableInputs ?? "No input avail")
        print("All inputs before: ",self.recordingSession?.availableInputs?[0].dataSources ?? ["No input found"])
        
        let port : AVAudioSessionPortDescription = self.recordingSession?.availableInputs?[0] ?? AVAudioSessionPortDescription()
        for source in port.dataSources ?? [] {
            if (source.dataSourceName == "Front") {
                do {
                    try port.setPreferredDataSource(source)
                }
                catch {
                    print(error)
                }
                
            }
        }
        
        print("All inputs after: ",self.recordingSession?.availableInputs ?? "No input avail")
        print("All inputs after: ",self.recordingSession?.availableInputs?[0].dataSources ?? ["No input found"])
        */
        
    }
    
    func changeLanguageOfUI() {
        
        if self.isComeForTopMic {
            self.lblTestTitle.text = self.getLocalizatioStringValue(key: "Top Mic")
            self.lblTestDesc.text = self.getLocalizatioStringValue(key: "Speak into top mic")
        }
        else {
            self.lblTestTitle.text = self.getLocalizatioStringValue(key: "Bottom Mic")
            self.lblTestDesc.text = self.getLocalizatioStringValue(key: "Speak into bottom mic")
            
            
            let port : AVAudioSessionPortDescription = self.recordingSession?.availableInputs?[0] ?? AVAudioSessionPortDescription()
            for source in port.dataSources ?? [] {
                if (source.dataSourceName == "Front") {
                    
                    do {
                        try port.setPreferredDataSource(source)
                    }
                    catch {
                        print(error)
                    }
                    
                }
            }
            
        }
        
        self.btnStartRecording.setTitle(self.getLocalizatioStringValue(key: "Start Recording"), for: .normal)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        
    }
    
    // MARK: IBActions
    @IBAction func backButtonPressed(_ sender: UIButton) {
        self.dismiss(animated: true, completion: {
            self.micTimer?.invalidate()
            
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
            self.micTimer?.invalidate()
            
            performDiagnostics = nil
        })
    }
    
    @IBAction func startRecordingButtonPressed(_ sender: UIButton) {
        
        guard recording != nil else {
            
            DispatchQueue.main.async() {
                self.view.makeToast(self.getLocalizatioStringValue(key: "Please give microphone permission"), duration: 2.0, position: .bottom)
            }
            
            return
        }
        
        sender.isHidden = true
        self.lblCounter.text = "4"
        self.lblCounter.isHidden = false
        self.loaderImgVW.isHidden = false
        
        //Run Timer for 4 Seconds to record the audio
        self.micTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.runTimerForReverseCounter), userInfo: nil, repeats: true)
        
        
        let audioFilename = getDocumentsDirectory().appendingPathComponent("recording.m4a")
        self.startRecording(url: audioFilename)
        
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }

}

extension MicroPhoneVC {
    
    //MARK: Custom Microphone Methods
    func checkMicPermission() {
        
        // Recording audio requires a user's permission to stop malicious apps doing malicious things, so we need to request recording permission from the user.
        
        self.recordingSession = AVAudioSession.sharedInstance()
        
        do {
            //try self.recordingSession?.setCategory(.playAndRecord, mode: .default, options: .defaultToSpeaker)
            
            try self.recordingSession?.setCategory(AVAudioSession.Category.playAndRecord)
            try self.recordingSession?.setActive(true)
            
            self.recordingSession?.requestRecordPermission() { [weak self] allowed in
                
                if allowed {
                    //self.loadRecordingUI()
                    
                    DispatchQueue.main.async {
                        self?.createRecorder()
                    }
                    
                } else {
                    
                    // failed to record!
                    DispatchQueue.main.async() {
                        self?.view.makeToast(self?.getLocalizatioStringValue(key: "failed to record!"), duration: 2.0, position: .bottom)
                    }
                    
                }
                
            }
        } catch {
            // failed to record!
            DispatchQueue.main.async() {
                self.view.makeToast(self.getLocalizatioStringValue(key: "failed to record!"), duration: 2.0, position: .bottom)
            }
            
        }
        
    }
    
    public func createRecorder() {
        self.recording = Recording(to: "recording.m4a")
        self.recording.delegate = self
        
        // Optionally, you can prepare the recording in the background to
        // make it start recording faster when you hit `record()`.
        
        DispatchQueue.global().async {
            // Background thread
            do {
                try self.recording.prepare()
            } catch {
                
            }
        }
    }
    
    public func startRecording(url: URL) {
        recordDuration = 0
        do {
            Timer.scheduledTimer(timeInterval: 4,
                                 target: self,
                                 selector: #selector(self.stopRecording),
                                 userInfo: nil,
                                 repeats: false)
            
            try recording.record()
            //self.playUsingAVAudioPlayer(url: url)
            
        } catch {
            
        }
    }
    
    @objc func stopRecording() {
                        
        self.micTimer?.invalidate()
        
        self.recordDuration = 0
        self.recording.stop()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            
            
            if self.isBitRate {
                self.finishRecording(success: self.isBitRate)
            }else {
                self.finishRecording(success: self.isBitRate)
            }
        
            
          
            
            /* To split both tests - 21/10/24
            if !self.isBottomCheck {
                
                self.lblCounter.isHidden = true
                
                self.isBottomCheck = true
                self.isTopCheck = false
                
                if self.isBitRate {
                    self.isBottomPass = true
                }else {
                    self.isBottomPass = false
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    
                    let port : AVAudioSessionPortDescription = self.recordingSession?.availableInputs?[0] ?? AVAudioSessionPortDescription()
                    for source in port.dataSources ?? [] {
                        if (source.dataSourceName == "Front") {
                            
                            do {
                                try port.setPreferredDataSource(source)
                                
                                self.lblTestTitle.text = self.getLocalizatioStringValue(key: "Top Mic")
                                self.lblTestDesc.text = self.getLocalizatioStringValue(key: "Speak into top mic")
                                
                                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                                    
                                    self.isBitRate = false
                                    
                                    self.micCount = 0
                                    self.lblCounter.text = "4"
                                    self.lblCounter.isHidden = false
                                    self.loaderImgVW.isHidden = false
                                    
                                    //Run Timer for 4 Seconds to record the audio
                                    self.micTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.runTimerForReverseCounter), userInfo: nil, repeats: true)
                                    
                                    let audioFilename = self.getDocumentsDirectory().appendingPathComponent("recording.m4a")
                                    self.startRecording(url: audioFilename)
                                }
                                
                            }
                            catch {
                                print(error)
                            }
                            
                        }
                    }
                    
                }
                
            }
            else {
                
                self.isTopCheck = true
                
                if self.isBitRate {
                    self.isTopPass = true
                }else {
                    self.isTopPass = false
                }
                
                self.finishRecording(success: (self.isBottomPass && self.isTopPass))
                
            }
            */
            
        }
        
    }
    
    func audioMeterDidUpdate(_ db: Float) {
        
        self.recording.recorder?.updateMeters()
        
        let ALPHA = 0.05
        let peakPower = pow(10, (ALPHA * Double((self.recording.recorder?.peakPower(forChannel: 0))!)))
        var rate: Double = 0.0
        
        if (peakPower <= 0.2) {
            rate = 0.2
        //} else if (peakPower > 0.9) {
        } else if (peakPower > 0.7) {
            rate = 1.0
            self.isBitRate = true
        } else {
            rate = peakPower
        }
        
        print("rate is:",rate)
        print("peakPower is:",peakPower)
        
        self.recordDuration += 1
    }
    
    @objc func runTimerForReverseCounter() {
        self.micCount += 1
        
        if self.micCount <= 4 {
            self.lblCounter.isHidden = false
            self.lblCounter.text = "\(4 - self.micCount)"
        }else {
            
        }
        
    }
    
    func finishRecording(success: Bool) {
        
        self.micTimer?.invalidate()
        self.recording.recorder?.deleteRecording()

        if success {
            
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
            
            //self.resultJSON["MIC"].int = 1
            //UserDefaults.standard.set(true, forKey: "mic")
            
            if self.isComeForTopMic {
                self.resultJSON["top microphone"].int = 1
                UserDefaults.standard.set(true, forKey: "top microphone")
            }
            else {
                self.resultJSON["bottom microphone"].int = 1
                UserDefaults.standard.set(true, forKey: "bottom microphone")
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
                
            if self.isComingFromTestResult {
                self.navToSummaryPage()
            }
            else {
                self.dismissThisPage()
            }
            
        } else {
            
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
            
            //self.resultJSON["MIC"].int = 0
            //UserDefaults.standard.set(false, forKey: "mic")
            
            if self.isComeForTopMic {
                self.resultJSON["top microphone"].int = 0
                UserDefaults.standard.set(false, forKey: "top microphone")
            }
            else {
                self.resultJSON["bottom microphone"].int = 0
                UserDefaults.standard.set(false, forKey: "bottom microphone")
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
            
            if self.isComingFromTestResult {
                self.navToSummaryPage()
            }
            else {
                self.dismissThisPage()
            }
            
        }
        
    }
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    func dismissThisPage() {
        
        self.micTimer?.invalidate()
        self.micCount = 0
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.0, execute: {
            
            self.dismiss(animated: false, completion: {
                guard let didFinishTestDiagnosis = performDiagnostics else { return }
                didFinishTestDiagnosis(self.resultJSON)
            })
            
        })
        
    }
    
    func navToSummaryPage() {
        
        self.dismiss(animated: false, completion: {
            guard let didFinishRetryDiagnosis = self.micRetryDiagnosis else { return }
            didFinishRetryDiagnosis(self.resultJSON)
        })
        
    }
    
    /*
    //MARK: Custom Methods
    func makeAnAudioSession() {
        
        //make an AudioSession, set it to PlayAndRecord and make it active
        let audioSession:AVAudioSession = AVAudioSession.sharedInstance()
        
        do {
            try? audioSession.setCategory(.playAndRecord)
            try? audioSession.setActive(true)
            
            //set up the URL for the audio file
            let documents = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
            let str = documents.appending("recordTest.caf")
            let url = URL.init(fileURLWithPath: str)
            
            // make a dictionary to hold the recording settings so we can instantiate our AVAudioRecorder
            let recordSettings = [AVFormatIDKey : kAudioFormatAppleIMA4,
                                AVSampleRateKey : 44100.0,
                          AVNumberOfChannelsKey : 2,
                            AVEncoderBitRateKey : 12800,
                         AVLinearPCMBitDepthKey : 16,
                       AVEncoderAudioQualityKey : AVAudioQuality.max.rawValue
            ] as [String : Any]
            
            //declare a variable to store the returned error if we have a problem instantiating our AVAudioRecorder
            //var error: NSError?
            
            //If there's an error, print that shit - otherwise, run prepareToRecord and meteringEnabled to turn on metering (must be run in that order)
            
            
            //Instantiate an AVAudioRecorder
            
            self.recorder = try AVAudioRecorder.init(url: url, settings: recordSettings)
            self.recorder.prepareToRecord()
            self.recorder.isMeteringEnabled = true
                
            //start recording
            self.recorder.record()
            
            //instantiate a timer to be called with whatever frequency we want to grab metering values
            self.levelTimer = Timer.scheduledTimer(timeInterval: 0.02, target: self, selector: #selector(self.levelTimerCallback), userInfo: nil, repeats: true)
                                        
            
        }
        catch {
            // failed to record!
            DispatchQueue.main.async() {
                self.view.makeToast("failed to record!", duration: 2.0, position: .bottom)
            }
        }
        
    }
    
    //This selector/function is called every time our timer (levelTime) fires
    @objc func levelTimerCallback_old() {
        //we have to update meters before we can get the metering values
        recorder.updateMeters()
        
        print(recorder.averagePower(forChannel: 0))

        //print to the console if we are beyond a threshold value. Here I've used -7
        if recorder.averagePower(forChannel: 0) > -7 {
            print("Dis be da level I'm hearin' you in dat mic ")
            print(recorder.averagePower(forChannel: 0))
            print("Do the thing I want, mofo")
        }
        
    }
    */
    
}
