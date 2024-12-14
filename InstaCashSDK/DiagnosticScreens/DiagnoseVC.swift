//
//  DiagnoseVC.swift
//  InstaCash_Diagnostics
//
//  Created by Sameer Khan on 23/07/24.
//

import UIKit
import SwiftyJSON
import Foundation

import os

open class DiagnoseVC: UIViewController {
    
    @IBOutlet weak var startBtn: UIButton!
    @IBOutlet weak var lblVersionNum: UILabel!
    
    open var diagnoseFinish: ((_ resultString: String, _ metadata: JSON) -> Void)?
    open var fontFamilyName : String?
    open var fontFamilyType : String?
    open var AppGlobalColorHex : String?
    
    var arrFontType = ["Regular","Medium","Bold"]
    var resultJSON = JSON()
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setStatusBarColor(themeColor: GlobalUtility().AppThemeColor)
        
        let bundle = Bundle.init(identifier: "in.instaWarehouse") ?? Bundle.main
        //print("bundle",bundle.bundleIdentifier ?? "bundle.bundleIdentifier")
        //print(bundle.bundlePath, bundle.bundleURL, bundle.isLoaded)
        
        if let strHex = self.AppGlobalColorHex {
            AppThemeColorHexString = strHex
        }
        
        if let globalFontName = self.fontFamilyName {
            AppFontFamilyName = globalFontName
        }
        
        //print("AppFontFamilyName is -", AppFontFamilyName ?? "font nahi mila")
        //AppFontFamilyName = self.fontFamilyName
        
        for font in arrFontType {
            let fontName = (self.fontFamilyName ?? "Roboto") + "-" + font
            //print("fontname is : ", fontName)
            
            self.registerFont(fontName, extension: fontFamilyType ?? "ttf", in: bundle)
        }
        
        //self.registerFont("Roboto-Regular", extension: "ttf", in: bundle)
        //self.registerFont("Roboto-Medium", extension: "ttf", in: bundle)
        //self.registerFont("Roboto-Bold", extension: "ttf", in: bundle)
          
        
        let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
        lblVersionNum.text = appVersion
        
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //AppOrientationUtility.lockOrientation(.portrait)
        appDelegate_Obj.orientationLock = .portrait
        
        self.setUIElementsProperties()
        
        self.changeLanguageOfUI()
    }
    
    // MARK: Custom Methods
    func changeLanguageOfUI() {
        
        //self.startBtn.setTitle(self.getLocalizatioStringValue(key: "Open SDK").uppercased(), for: .normal)
        self.startBtn.setTitle(self.getLocalizatioStringValue(key: "Start Diagnostics"), for: .normal)
        
    }
    
    func setUIElementsProperties() {
        
        self.startBtn.backgroundColor = AppThemeColor
        self.startBtn.layer.cornerRadius = AppBtnCornerRadius
        self.startBtn.setTitleColor(AppBtnTitleColor, for: .normal)
        self.startBtn.setTitle(self.getLocalizatioStringValue(key: "Start Diagnostics"), for: .normal)
        self.startBtn.titleLabel?.font = UIFont.init(name: AppFontMedium, size: self.startBtn.titleLabel?.font.pointSize ?? 18.0)
    }
    
    func registerFont(_ fontName: String, extension: String, in bundle: Bundle) {
        guard let fontURL = bundle.url(forResource: fontName, withExtension: `extension`) else { return }
        CTFontManagerRegisterFontsForURL(fontURL as CFURL, CTFontManagerScope.process, nil)
    }
    
    // MARK: IBActions
    @IBAction func startButtonPressed(_ sender: UIButton) {
        
        //NSLog("723263045@warehouse: ", "WiFi")
        //NSLog("%@%@", "Warehouse", "WiFi = 1")
        
        //let bundle = Bundle.init(identifier: "in.instaWarehouse")
        //let storyboard = UIStoryboard(name: "InstaCash", bundle: bundle)
        
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "HomeVC") as! HomeVC
        self.navigationController?.pushViewController(vc, animated: true)
    
        
        //vc.modalPresentationStyle = .overFullScreen
        //vc.modalTransitionStyle = .flipHorizontal
        //self.present(vc, animated: true, completion: nil)
        
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    open override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    
}
