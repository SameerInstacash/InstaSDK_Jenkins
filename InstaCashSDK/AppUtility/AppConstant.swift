//
//  AppConstant.swift
//  InstaCashApp
//
//  Created by Sameer Khan on 06/07/21.
//

import UIKit
import SwiftyJSON

//var AppdidFinishTestDiagnosis: (() -> Void)?
//var AppdidFinishRetryDiagnosis: (() -> Void)?

var performDiagnostics: ((_ testJSON: JSON) -> Void)?
var arrTestsInSDK = [String]()
var arrTestsResultJSONInSDK = [Int]()
var currentTestIndex = 0
var totalTestsCount = 0

let appDelegate_Obj = UIApplication.shared.delegate as! AppDelegate

var AppApiKey = UserDefaults.standard.string(forKey: "App_ApiKey") ?? "202cb962ac59075b964b07152d234b70"
var AppUserName = UserDefaults.standard.string(forKey: "App_UserName") ?? "whtest"

var AppHashCode = ""
var AppStoreName = ""
var AppStoreId = ""
var AppBaseUrl = "https://getinstacash.in/warehouse/v1/public/"

var AppCustomerID = ""
var AppProductID = ""
var AppProductImage = ""
var AppProductName = ""

var hardwareQuestionsCount = 0
var AppQuestionIndex = -1

var AppHardwareQuestionsData : CosmeticQuestions?
var arrAppHardwareQuestions: [Questions]?
var arrAppQuestionsAppCodes : [String]?
var arrAppQuestAnswr : [[String:Any]]?





var AppCurrentProductBrand = ""
var AppCurrentProductName = ""
var AppCurrentProductImage = ""

// ***** App Theme Color ***** //
var AppThemeColorHexString : String?
var AppThemeColor : UIColor = UIColor().HexToColor(hexString: AppThemeColorHexString ?? "#008F00", alpha: 1.0)

// ***** Font-Family ***** //
var AppFontFamilyName : String?
var AppFontRegular = "\(AppFontFamilyName ?? "Roboto")-Regular"
var AppFontMedium = "\(AppFontFamilyName ?? "Roboto")-Medium"
var AppFontBold = "\(AppFontFamilyName ?? "Roboto")-Bold"


// ***** Button Properties ***** //
var AppBtnCornerRadius : CGFloat = 10
var AppBtnTitleColorHexString : String?
var AppBtnTitleColor : UIColor = UIColor().HexToColor(hexString: AppBtnTitleColorHexString ?? "#FFFFFF", alpha: 1.0)

// ***** App Tests Performance ***** //
var holdAppTestsPerformArray = [String]()
var AppTestsPerformArray = [String]()
var AppTestIndex : Int = 0

let AppUserDefaults = UserDefaults.standard
var AppResultJSON = JSON()
var AppResultString = ""

var AppOrientationLock = UIInterfaceOrientationMask.all

