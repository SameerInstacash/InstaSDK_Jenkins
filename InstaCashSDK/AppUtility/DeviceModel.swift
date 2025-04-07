//
//  DeviceModel.swift
//  InstaCashSDK
//
//  Created by Sameer Khan on 06/07/21.
//

import UIKit

public extension UIDevice {
    
    var currentModelName: String {
        
        var systemInfo = utsname()
        uname(&systemInfo)
        
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        
        
        switch identifier {
            
            //MARK: iPhone
        case "iPhone1,1":                               return "iPhone"
        case "iPhone1,2":                               return "iPhone 3G"
        case "iPhone2,1":                               return "iPhone 3GS"
            
        case "iPhone3,1", "iPhone3,2", "iPhone3,3":     return "iPhone 4"
        case "iPhone4,1":                               return "iPhone 4s"
            
        case "iPhone5,1", "iPhone5,2":                  return "iPhone 5"
        case "iPhone5,3", "iPhone5,4":                  return "iPhone 5c"
        case "iPhone6,1", "iPhone6,2":                  return "iPhone 5s"
            
        case "iPhone7,2":                               return "iPhone 6"
        case "iPhone7,1":                               return "iPhone 6 Plus"
        case "iPhone8,1":                               return "iPhone 6s"
        case "iPhone8,2":                               return "iPhone 6s Plus"
            
        case "iPhone8,4":                               return "iPhone SE"
            
        case "iPhone9,1", "iPhone9,3":                  return "iPhone 7"
        case "iPhone9,2", "iPhone9,4":                  return "iPhone 7 Plus"
            
        case "iPhone10,1", "iPhone10,4":                return "iPhone 8"
        case "iPhone10,2", "iPhone10,5":                return "iPhone 8 Plus"
            
        case "iPhone10,3", "iPhone10,6":                return "iPhone X"
        case "iPhone11,2":                              return "iPhone XS"
        case "iPhone11,4", "iPhone11,6":                return "iPhone XS Max"
        case "iPhone11,8":                              return "iPhone XR"
            
        case "iPhone12,1":                              return "iPhone 11"
        case "iPhone12,3":                              return "iPhone 11 Pro"
        case "iPhone12,5":                              return "iPhone 11 Pro Max"
        case "iPhone12,8":                              return "iPhone SE (2nd generation)"
            
        case "iPhone13,1":                              return "iPhone 12 mini"
        case "iPhone13,2":                              return "iPhone 12"
        case "iPhone13,3":                              return "iPhone 12 Pro"
        case "iPhone13,4":                              return "iPhone 12 Pro Max"
            
        case "iPhone14,4":                              return "iPhone 13 Mini"
        case "iPhone14,5":                              return "iPhone 13"
        case "iPhone14,2":                              return "iPhone 13 Pro"
        case "iPhone14,3":                              return "iPhone 13 Pro Max"
            
        case "iPhone14,6":                              return "iPhone SE 3rd Gen"
            
        case "iPhone14,7":                              return "iPhone 14"
        case "iPhone14,8":                              return "iPhone 14 Plus"
        case "iPhone15,2":                              return "iPhone 14 Pro"
        case "iPhone15,3":                              return "iPhone 14 Pro Max"
            
        case "iPhone15,4":                              return "iPhone 15"
        case "iPhone15,5":                              return "iPhone 15 Plus"
        case "iPhone16,1":                              return "iPhone 15 Pro"
        case "iPhone16,2":                              return "iPhone 15 Pro Max"
            
        case "iPhone17,1":                              return "iPhone 16 Pro"
        case "iPhone17,2":                              return "iPhone 16 Pro Max"
        case "iPhone17,3":                              return "iPhone 16"
        case "iPhone17,4":                              return "iPhone 16 Plus"
        case "iPhone17,5":                              return "iPhone 16e"
            
            //MARK: iPod
        case "iPod1,1" :                                return "1st Gen iPod"
        case "iPod2,1" :                                return "2nd Gen iPod"
        case "iPod3,1" :                                return "3rd Gen iPod"
        case "iPod4,1" :                                return "4th Gen iPod"
        case "iPod5,1":                                 return "iPod touch (5th generation)"
        case "iPod7,1":                                 return "iPod touch (6th generation)"
        case "iPod9,1":                                 return "iPod touch (7th generation)"
            
            
            //MARK: iPad
        case "iPad1,1", "iPad1,2":                      return "iPad (1st generation)"
            
            //case "iPad2,1", "iPad2,2", "iPad2,3", "iPad2,4":return "iPad (2nd generation)"
        case "iPad2,1" :                                return "2nd Gen iPad"
        case "iPad2,2" :                                return "2nd Gen iPad GSM"
        case "iPad2,3" :                                return "2nd Gen iPad CDMA"
        case "iPad2,4" :                                return "2nd Gen iPad New Revision"
            
            //case "iPad3,1", "iPad3,2", "iPad3,3":         return "iPad (3rd generation)"
        case "iPad3,1" :                                return "3rd Gen iPad"
        case "iPad3,2" :                                return "3rd Gen iPad CDMA"
        case "iPad3,3" :                                return "3rd Gen iPad GSM"
            
            //case "iPad3,4", "iPad3,5", "iPad3,6":         return "iPad (4th generation)"
        case "iPad3,4" :                                return "4th Gen iPad"
        case "iPad3,5" :                                return "4th Gen iPad GSM+LTE"
        case "iPad3,6" :                                return "4th Gen iPad CDMA+LTE"
            
            //case "iPad6,11", "iPad6,12":                  return "iPad (5th generation)"
        case "iPad6,11" :                               return "iPad (2017) (5th generation)"
        case "iPad6,12" :                               return "iPad (2017) (5th generation)"
            
            //case "iPad7,5", "iPad7,6":                    return "iPad (6th generation)"
        case "iPad7,5" :                                return "iPad 6th Gen (WiFi)"
        case "iPad7,6" :                                return "iPad 6th Gen (WiFi+Cellular)"
            
            //case "iPad7,11", "iPad7,12":                  return "iPad (7th generation)"
        case "iPad7,11" :                               return "iPad 7th Gen (10.2-inch) (WiFi)"
        case "iPad7,12" :                               return "iPad 7th Gen (10.2-inch) (WiFi+Cellular)"
            
            //case "iPad11,6", "iPad11,7":                  return "iPad (8th generation)"
        case "iPad11,6" :                               return "iPad 8th Gen (WiFi)"
        case "iPad11,7" :                               return "iPad 8th Gen (WiFi+Cellular)"
            
            //MARK: iPad Air
            //case "iPad4,1", "iPad4,2", "iPad4,3":         return "iPad Air (1st generation)"
        case "iPad4,1" :                                return "1st Gen iPad Air (WiFi)"
        case "iPad4,2" :                                return "1st Gen iPad Air (GSM+CDMA)"
        case "iPad4,3" :                                return "1st Gen iPad Air (China)"
            
            //case "iPad5,3", "iPad5,4":                    return "iPad Air (2nd generation)"
        case "iPad5,3" :                                return "iPad Air 2 (WiFi) (2nd generation)"
        case "iPad5,4" :                                return "iPad Air 2 (Cellular) (2nd generation)"
            
            //case "iPad11,3", "iPad11,4":                  return "iPad Air (3rd generation)"
        case "iPad11,3" :                               return "iPad Air 3rd Gen (WiFi)"
        case "iPad11,4" :                               return "iPad Air 3rd Gen"
            
            //MARK: iPad Mini
            //case "iPad2,5", "iPad2,6", "iPad2,7":         return "iPad mini (1st generation)"
        case "iPad2,5" :                                return  "iPad mini (1st generation)"
        case "iPad2,6" :                                return  "iPad mini GSM+LTE (1st generation)"
        case "iPad2,7" :                                return  "iPad mini CDMA+LTE (1st generation)"
            
            //case "iPad4,4", "iPad4,5", "iPad4,6":         return "iPad mini (2nd generation)"
        case "iPad4,4" :                                return "iPad mini Retina (WiFi) (2nd generation)"
        case "iPad4,5" :                                return "iPad mini Retina (GSM+CDMA) (2nd generation)"
        case "iPad4,6" :                                return "iPad mini Retina (China) (2nd generation)"
            
            //case "iPad4,7", "iPad4,8", "iPad4,9":         return "iPad mini (3rd generation)"
        case "iPad4,7" :                                return "iPad mini 3 (WiFi) (3rd generation)"
        case "iPad4,8" :                                return "iPad mini 3 (GSM+CDMA) (3rd generation)"
        case "iPad4,9" :                                return "iPad Mini 3 (China) (3rd generation)"
            
            //case "iPad5,1", "iPad5,2":                    return "iPad mini (4th generation)"
        case "iPad5,1" :                                return "iPad mini 4 (WiFi) (4th generation)"
        case "iPad5,2" :                                return "4th Gen iPad mini (WiFi+Cellular) (4th generation)"
            
            //case "iPad11,1", "iPad11,2":                  return "iPad mini (5th generation)"
        case "iPad11,1" :                               return "iPad mini 5th Gen (WiFi)"
        case "iPad11,2" :                               return "iPad mini 5th Gen"
            
            //MARK: iPad Pro
            //case "iPad6,3", "iPad6,4":                    return "iPad Pro (9.7-inch)"
        case "iPad6,3" :                                return "iPad Pro (9.7 inch, WiFi)"
        case "iPad6,4" :                                return "iPad Pro (9.7 inch, WiFi+LTE)"
            
            //case "iPad7,3", "iPad7,4":                    return "iPad Pro (10.5-inch)"
        case "iPad7,3" :                                return "iPad Pro (10.5-inch) 2nd Gen"
        case "iPad7,4" :                                return "iPad Pro (10.5-inch) 2nd Gen"
            
            //case "iPad8,1", "iPad8,2", "iPad8,3", "iPad8,4":return "iPad Pro (11-inch) (1st generation)"
        case "iPad8,1" :                                return "iPad Pro (11-inch) 3rd Gen (WiFi)"
        case "iPad8,2" :                                return "iPad Pro (11-inch) 3rd Gen (1TB, WiFi)"
        case "iPad8,3" :                                return "iPad Pro (11-inch) 3rd Gen (WiFi+Cellular)"
        case "iPad8,4" :                                return "iPad Pro (11-inch) 3rd Gen (1TB, WiFi+Cellular)"
            
            //case "iPad8,9", "iPad8,10":                   return "iPad Pro (11-inch) (2nd generation)"
        case "iPad8,9" :                                return "iPad Pro (11-inch) 4th Gen (WiFi)"
        case "iPad8,10" :                               return "iPad Pro (11-inch) 4th Gen (WiFi+Cellular)"
            
            //case "iPad6,7", "iPad6,8":                    return "iPad Pro (12.9-inch) (1st generation)"
        case "iPad6,7" :                                return "iPad Pro (12.9-inch), WiFi) (1st generation)"
        case "iPad6,8" :                                return "iPad Pro (12.9-inch), WiFi+LTE) (1st generation)"
            
            //case "iPad7,1", "iPad7,2":                    return "iPad Pro (12.9-inch) (2nd generation)"
        case "iPad7,1" :                                return "iPad Pro (12.9-inch) 2nd Gen (WiFi)"
        case "iPad7,2" :                                return "iPad Pro (12.9-inch) 2nd Gen (WiFi+Cellular)"
            
            //case "iPad8,5", "iPad8,6", "iPad8,7", "iPad8,8":return "iPad Pro (12.9-inch) (3rd generation)"
        case "iPad8,5" :                                return "iPad Pro (12.9-inch) 3rd Gen (WiFi)"
        case "iPad8,6" :                                return "iPad Pro (12.9-inch) 3rd Gen (1TB, WiFi)"
        case "iPad8,7" :                                return "iPad Pro (12.9-inch) 3rd Gen (WiFi+Cellular)"
        case "iPad8,8" :                                return "iPad Pro (12.9-inch) 3rd Gen (1TB, WiFi+Cellular)"
            
            //case "iPad8,11", "iPad8,12":                  return "iPad Pro (12.9-inch) (4th generation)"
        case "iPad8,11" :                               return "iPad Pro (12.9-inch) 4th Gen (WiFi)"
        case "iPad8,12" :                               return "iPad Pro (12.9-inch) 4th Gen (WiFi+Cellular)"
            
            //MARK: New iPads add on 6/10/22
        case "iPad12,1":                                return "iPad 9th Gen (WiFi)"
        case "iPad12,2":                                return "iPad 9th Gen (WiFi+Cellular)"
            
        case "iPad14,1":                                return "iPad mini 6th Gen (WiFi)"
        case "iPad14,2":                                return "iPad mini 6th Gen (WiFi+Cellular)"
            
            //case "iPad13,1", "iPad13,2":                  return "iPad Air (4th generation)"
        case "iPad13,1":                                return "iPad Air 4th Gen (WiFi)"
        case "iPad13,2":                                return "iPad Air 4th Gen (WiFi+Cellular)"
            
        case "iPad13,4":                                return "iPad Pro (11-inch) 5th Gen"
        case "iPad13,5":                                return "iPad Pro (11-inch) 5th Gen"
            
        case "iPad13,6":                                return "iPad Pro (11-inch) 5th Gen"
        case "iPad13,7":                                return "iPad Pro (11-inch) 5th Gen"
            
        case "iPad13,8":                                return "iPad Pro (12.9-inch) 5th Gen"
        case "iPad13,9":                                return "iPad Pro (12.9-inch) 5th Gen"
            
        case "iPad13,10":                               return "iPad Pro (12.9-inch) 5th Gen"
        case "iPad13,11":                               return "iPad Pro (12.9-inch) 5th Gen"
            
        case "iPad13,16":                               return "iPad Air 5th Gen (WiFi)"
        case "iPad13,17":                               return "iPad Air 5th Gen (WiFi+Cellular)"
            
        case "iPad13,18" :                              return "iPad 10th Gen"
        case "iPad13,19" :                              return "iPad 10th Gen"
            
        case "iPad14,3" :                               return "iPad Pro (11-inch) 4th Gen"
        case "iPad14,4" :                               return "iPad Pro (11-inch) 4th Gen"
        case "iPad14,5" :                               return "iPad Pro (12.9-inch) 6th Gen"
        case "iPad14,6" :                               return "iPad Pro (12.9-inch) 6th Gen"
            
        case "iPad14,8" :                               return "iPad Air 11 inch 6th Gen (WiFi)"
        case "iPad14,9" :                               return "iPad Air 11 inch 6th Gen (WiFi+Cellular)"
        case "iPad14,10" :                              return "iPad Air 13 inch 6th Gen (WiFi)"
        case "iPad14,11" :                              return "iPad Air 13 inch 6th Gen (WiFi+Cellular)"
            
        case "iPad15,3" :                               return "iPad Air 11-inch 7th Gen (WiFi)"
        case "iPad15,4" :                               return "iPad Air 11-inch 7th Gen (WiFi+Cellular)"
        case "iPad15,5" :                               return "iPad Air 13-inch 7th Gen (WiFi)"
        case "iPad15,6" :                               return "iPad Air 13-inch 7th Gen (WiFi+Cellular)"
        case "iPad15,7" :                               return "iPad 11th Gen (WiFi)"
        case "iPad15,8" :                               return "iPad 11th Gen (WiFi+Cellular)"
            
        case "iPad16,1" :                               return "iPad mini 7th Gen (WiFi)"
        case "iPad16,2" :                               return "iPad mini 7th Gen (WiFi+Cellular)"
        case "iPad16,3" :                               return "iPad Pro 11 inch 5th Gen"
        case "iPad16,4" :                               return "iPad Pro 11 inch 5th Gen"
        case "iPad16,5" :                               return "iPad Pro 12.9 inch 7th Gen"
        case "iPad16,6" :                               return "iPad Pro 12.9 inch 7th Gen"
            
        case "i386", "x86_64", "arm64":                 return identifier
        default:                                        return identifier
            
        }
        
        
        /*
         
         switch identifier {
         
         case "iPhone3,1", "iPhone3,2":                  return "A1332,iPhone 4"
         case "iPhone3,3":                               return "A1349,iPhone 4"
         case "iPhone4,1":                               return "A1387,A1431,iPhone 4s"
         
         case "iPhone5,1":                               return "A1428,iPhone 5"
         case "iPhone5,2":                               return "A1429,iPhone 5"
         case "iPhone5,3":                               return "A1456,A1507,A1516,iPhone 5c"
         case "iPhone5,4":                               return "A1453,A1532,iPhone 5c"
         
         case "iPhone6,1":                               return "A1453,A1533,iPhone 5s"
         case "iPhone6,2":                               return "A1457,A1518,A1528,A1530,iPhone 5s"
         
         case "iPhone7,2":                               return "A1549,A1586,A1589,iPhone 6"
         case "iPhone7,1":                               return "A1522,A1524,A1593,iPhone 6 Plus"
         case "iPhone8,1":                               return "A1633,A1688,A1700,iPhone 6s"
         case "iPhone8,2":                               return "A1634,A1687,A1699,iPhone 6s Plus"
         
         case "iPhone8,4":                               return "A1662,A1723,A1724,iPhone SE"
         case "iPhone9,1":                               return "A1660,A1779,A1780,iPhone 7"
         case "iPhone9,3":                               return "A1778,iPhone 7"
         case "iPhone9,2":                               return "A1661,A1785,A1786,iPhone 7 Plus"
         case "iPhone9,4":                               return "A1784,iPhone 7 Plus"
         
         case "iPhone10,1":                              return "A1863,A1906,A1907,iPhone 8"
         case "iPhone10,4":                              return "A1905,iPhone 8"
         case "iPhone10,2":                              return "A1864,A1898,A1899,iPhone 8 Plus"
         case "iPhone10,5":                              return "A1897,iPhone 8 Plus"
         
         case "iPhone10,3":                              return "A1865,A1902,iPhone X"
         case "iPhone10,6":                              return "A1901,iPhone X"
         case "iPhone11,2":                              return "A1920,A2097,A2098,A2100,iPhone XS"
         case "iPhone11,4":                              return "A1921,A2103,iPhone XS Max"
         case "iPhone11,6":                              return "A2101,A2102,iPhone XS Max"
         case "iPhone11,8":                              return "A1984,A2105,A2106,A2108,iPhone XR"
         
         case "iPhone12,1":                              return "A2111,A2221,A2223,iPhone 11"
         case "iPhone12,3":                              return "A2160,A2215,A2217,iPhone 11 Pro"
         case "iPhone12,5":                              return "A2161,A2220,A2218,iPhone 11 Pro Max"
         case "iPhone12,8":                              return "A2275,A2296,A2298,iPhone SE (2nd generation)"
         
         case "iPhone13,1":                              return "A2176,A2398,A2400,iPhone 12 mini"
         case "iPhone13,2":                              return "A2172,A2402,A2404,iPhone 12"
         case "iPhone13,3":                              return "A2341,A2406,A2408,iPhone 12 Pro"
         case "iPhone13,4":                              return "A2342,A2410,A2412,iPhone 12 Pro Max"
         
         case "iPhone14,4":                              return "A2481,A2626,A2629,A2630,iPhone 13 Mini"
         case "iPhone14,5":                              return "A2482,A2631,A2634,A2635,iPhone 13"
         case "iPhone14,2":                              return "A2483,A2636,A2639,A2640,iPhone 13 Pro"
         case "iPhone14,3":                              return "A2484,A2641,A2644,A2645,iPhone 13 Pro Max"
         
         case "iPhone14,6":                              return "A2595,A2783,A2785,iPhone SE 3rd Gen"
         
         case "iPhone14,7":                              return "A2649,A2881,A2884,iPhone 14"
         case "iPhone14,8":                              return "A2632,A2882,A2885,iPhone 14 Plus"
         case "iPhone15,2":                              return "A2650,A2889,A2892,iPhone 14 Pro"
         case "iPhone15,3":                              return "A2651,A2890,A2893,iPhone 14 Pro Max"
         
         case "iPhone15,4":                              return "A3090,A3089,A3092,iPhone 15"
         case "iPhone15,5":                              return "A3094,A3093,A3096,iPhone 15 Plus"
         case "iPhone16,1":                              return "A3101,A3102,A3104,iPhone 15 Pro"
         case "iPhone16,2":                              return "A3105,A3106,A3108,iPhone 15 Pro Max"
         
         case "iPhone17,1":                              return "A3083,A3292,A3293,A3294,iPhone 16 Pro"
         case "iPhone17,2":                              return "A3084,A3295,A3296,A3297,iPhone 16 Pro Max"
         case "iPhone17,3":                              return "A3081,A3286,A3287,A3288,iPhone 16"
         case "iPhone17,4":                              return "A3082,A3289,A3290,A3291,iPhone 16 Plus"
         
         //eSIM-only
         //case "iPhone14,7":                              return "A2649, iPhone 14"
         //case "iPhone14,8":                              return "A2632, iPhone 14 Plus"
         //case "iPhone15,2":                              return "A2650, iPhone 14 Pro"
         //case "iPhone15,3":                              return "A2651, iPhone 14 Pro Max"
         
         //case "iPhone15,4":                              return "A3090, iPhone 15"
         //case "iPhone15,5":                              return "A3094, iPhone 15 Plus"
         //case "iPhone16,1":                              return "A3101, iPhone 15 Pro"
         //case "iPhone16,2":                              return "A3105, iPhone 15 Pro Max"
         
         //case "iPhone17,1":                              return "A3083, iPhone 16 Pro"
         //case "iPhone17,2":                              return "A3084, iPhone 16 Pro Max"
         //case "iPhone17,3":                              return "A3081, iPhone 16"
         //case "iPhone17,4":                              return "A3082, iPhone 16 Plus"
         
         
         //MARK: iPod
         case "iPod1,1" :                                return "1st Gen iPod"
         case "iPod2,1" :                                return "2nd Gen iPod"
         case "iPod3,1" :                                return "3rd Gen iPod"
         case "iPod4,1" :                                return "4th Gen iPod"
         case "iPod5,1":                                 return "iPod touch (5th generation)"
         case "iPod7,1":                                 return "iPod touch (6th generation)"
         case "iPod9,1":                                 return "iPod touch (7th generation)"
         
         //MARK: iPad
         case "iPad1,1", "iPad1,2":                      return "iPad (1st generation)"
         
         //case "iPad2,1", "iPad2,2", "iPad2,3", "iPad2,4":return "iPad (2nd generation)"
         case "iPad2,1" :                                return "2nd Gen iPad"
         case "iPad2,2" :                                return "2nd Gen iPad GSM"
         case "iPad2,3" :                                return "2nd Gen iPad CDMA"
         case "iPad2,4" :                                return "2nd Gen iPad New Revision"
         
         //case "iPad3,1", "iPad3,2", "iPad3,3":         return "iPad (3rd generation)"
         case "iPad3,1" :                                return "3rd Gen iPad"
         case "iPad3,2" :                                return "3rd Gen iPad CDMA"
         case "iPad3,3" :                                return "3rd Gen iPad GSM"
         
         //case "iPad3,4", "iPad3,5", "iPad3,6":         return "iPad (4th generation)"
         case "iPad3,4" :                                return "4th Gen iPad"
         case "iPad3,5" :                                return "4th Gen iPad GSM+LTE"
         case "iPad3,6" :                                return "4th Gen iPad CDMA+LTE"
         
         //case "iPad6,11", "iPad6,12":                  return "iPad (5th generation)"
         case "iPad6,11" :                               return "iPad (2017) (5th generation)"
         case "iPad6,12" :                               return "iPad (2017) (5th generation)"
         
         //case "iPad7,5", "iPad7,6":                    return "iPad (6th generation)"
         case "iPad7,5" :                                return "iPad 6th Gen (WiFi)"
         case "iPad7,6" :                                return "iPad 6th Gen (WiFi+Cellular)"
         
         //case "iPad7,11", "iPad7,12":                  return "iPad (7th generation)"
         case "iPad7,11" :                               return "iPad 7th Gen (10.2-inch) (WiFi)"
         case "iPad7,12" :                               return "iPad 7th Gen (10.2-inch) (WiFi+Cellular)"
         
         //case "iPad11,6", "iPad11,7":                  return "iPad (8th generation)"
         case "iPad11,6" :                               return "iPad 8th Gen (WiFi)"
         case "iPad11,7" :                               return "iPad 8th Gen (WiFi+Cellular)"
         
         //MARK: iPad Air
         //case "iPad4,1", "iPad4,2", "iPad4,3":         return "iPad Air (1st generation)"
         case "iPad4,1" :                                return "1st Gen iPad Air (WiFi)"
         case "iPad4,2" :                                return "1st Gen iPad Air (GSM+CDMA)"
         case "iPad4,3" :                                return "1st Gen iPad Air (China)"
         
         //case "iPad5,3", "iPad5,4":                    return "iPad Air (2nd generation)"
         case "iPad5,3" :                                return "iPad Air 2 (WiFi) (2nd generation)"
         case "iPad5,4" :                                return "iPad Air 2 (Cellular) (2nd generation)"
         
         //case "iPad11,3", "iPad11,4":                  return "iPad Air (3rd generation)"
         case "iPad11,3" :                               return "iPad Air 3rd Gen (WiFi)"
         case "iPad11,4" :                               return "iPad Air 3rd Gen"
         
         //MARK: iPad Mini
         //case "iPad2,5", "iPad2,6", "iPad2,7":         return "iPad mini (1st generation)"
         case "iPad2,5" :                                return  "iPad mini (1st generation)"
         case "iPad2,6" :                                return  "iPad mini GSM+LTE (1st generation)"
         case "iPad2,7" :                                return  "iPad mini CDMA+LTE (1st generation)"
         
         //case "iPad4,4", "iPad4,5", "iPad4,6":         return "iPad mini (2nd generation)"
         case "iPad4,4" :                                return "iPad mini Retina (WiFi) (2nd generation)"
         case "iPad4,5" :                                return "iPad mini Retina (GSM+CDMA) (2nd generation)"
         case "iPad4,6" :                                return "iPad mini Retina (China) (2nd generation)"
         
         //case "iPad4,7", "iPad4,8", "iPad4,9":         return "iPad mini (3rd generation)"
         case "iPad4,7" :                                return "iPad mini 3 (WiFi) (3rd generation)"
         case "iPad4,8" :                                return "iPad mini 3 (GSM+CDMA) (3rd generation)"
         case "iPad4,9" :                                return "iPad Mini 3 (China) (3rd generation)"
         
         //case "iPad5,1", "iPad5,2":                    return "iPad mini (4th generation)"
         case "iPad5,1" :                                return "iPad mini 4 (WiFi) (4th generation)"
         case "iPad5,2" :                                return "4th Gen iPad mini (WiFi+Cellular) (4th generation)"
         
         //case "iPad11,1", "iPad11,2":                  return "iPad mini (5th generation)"
         case "iPad11,1" :                               return "iPad mini 5th Gen (WiFi)"
         case "iPad11,2" :                               return "iPad mini 5th Gen"
         
         //MARK: iPad Pro
         //case "iPad6,3", "iPad6,4":                    return "iPad Pro (9.7-inch)"
         case "iPad6,3" :                                return "iPad Pro (9.7 inch, WiFi)"
         case "iPad6,4" :                                return "iPad Pro (9.7 inch, WiFi+LTE)"
         
         //case "iPad7,3", "iPad7,4":                    return "iPad Pro (10.5-inch)"
         case "iPad7,3" :                                return "iPad Pro (10.5-inch) 2nd Gen"
         case "iPad7,4" :                                return "iPad Pro (10.5-inch) 2nd Gen"
         
         //case "iPad8,1", "iPad8,2", "iPad8,3", "iPad8,4":return "iPad Pro (11-inch) (1st generation)"
         case "iPad8,1" :                                return "iPad Pro (11-inch) 3rd Gen (WiFi)"
         case "iPad8,2" :                                return "iPad Pro (11-inch) 3rd Gen (1TB, WiFi)"
         case "iPad8,3" :                                return "iPad Pro (11-inch) 3rd Gen (WiFi+Cellular)"
         case "iPad8,4" :                                return "iPad Pro (11-inch) 3rd Gen (1TB, WiFi+Cellular)"
         
         //case "iPad8,9", "iPad8,10":                   return "iPad Pro (11-inch) (2nd generation)"
         case "iPad8,9" :                                return "iPad Pro (11-inch) 4th Gen (WiFi)"
         case "iPad8,10" :                               return "iPad Pro (11-inch) 4th Gen (WiFi+Cellular)"
         
         //case "iPad6,7", "iPad6,8":                    return "iPad Pro (12.9-inch) (1st generation)"
         case "iPad6,7" :                                return "iPad Pro (12.9-inch), WiFi) (1st generation)"
         case "iPad6,8" :                                return "iPad Pro (12.9-inch), WiFi+LTE) (1st generation)"
         
         //case "iPad7,1", "iPad7,2":                    return "iPad Pro (12.9-inch) (2nd generation)"
         case "iPad7,1" :                                return "iPad Pro (12.9-inch) 2nd Gen (WiFi)"
         case "iPad7,2" :                                return "iPad Pro (12.9-inch) 2nd Gen (WiFi+Cellular)"
         
         //case "iPad8,5", "iPad8,6", "iPad8,7", "iPad8,8":return "iPad Pro (12.9-inch) (3rd generation)"
         case "iPad8,5" :                                return "iPad Pro (12.9-inch) 3rd Gen (WiFi)"
         case "iPad8,6" :                                return "iPad Pro (12.9-inch) 3rd Gen (1TB, WiFi)"
         case "iPad8,7" :                                return "iPad Pro (12.9-inch) 3rd Gen (WiFi+Cellular)"
         case "iPad8,8" :                                return "iPad Pro (12.9-inch) 3rd Gen (1TB, WiFi+Cellular)"
         
         //case "iPad8,11", "iPad8,12":                  return "iPad Pro (12.9-inch) (4th generation)"
         case "iPad8,11" :                               return "iPad Pro (12.9-inch) 4th Gen (WiFi)"
         case "iPad8,12" :                               return "iPad Pro (12.9-inch) 4th Gen (WiFi+Cellular)"
         
         //MARK: New iPads add on 6/10/22
         case "iPad12,1":                                return "iPad 9th Gen (WiFi)"
         case "iPad12,2":                                return "iPad 9th Gen (WiFi+Cellular)"
         
         case "iPad14,1":                                return "iPad mini 6th Gen (WiFi)"
         case "iPad14,2":                                return "iPad mini 6th Gen (WiFi+Cellular)"
         
         //case "iPad13,1", "iPad13,2":                  return "iPad Air (4th generation)"
         case "iPad13,1":                                return "iPad Air 4th Gen (WiFi)"
         case "iPad13,2":                                return "iPad Air 4th Gen (WiFi+Cellular)"
         
         case "iPad13,4":                                return "iPad Pro (11-inch) 5th Gen"
         case "iPad13,5":                                return "iPad Pro (11-inch) 5th Gen"
         
         case "iPad13,6":                                return "iPad Pro (11-inch) 5th Gen"
         case "iPad13,7":                                return "iPad Pro (11-inch) 5th Gen"
         
         case "iPad13,8":                                return "iPad Pro (12.9-inch) 5th Gen"
         case "iPad13,9":                                return "iPad Pro (12.9-inch) 5th Gen"
         
         case "iPad13,10":                               return "iPad Pro (12.9-inch) 5th Gen"
         case "iPad13,11":                               return "iPad Pro (12.9-inch) 5th Gen"
         
         case "iPad13,16":                               return "iPad Air 5th Gen (WiFi)"
         case "iPad13,17":                               return "iPad Air 5th Gen (WiFi+Cellular)"
         
         case "iPad13,18" :                              return "iPad 10th Gen"
         case "iPad13,19" :                              return "iPad 10th Gen"
         
         case "iPad14,3" :                               return "iPad Pro (11-inch) 4th Gen"
         case "iPad14,4" :                               return "iPad Pro (11-inch) 4th Gen"
         case "iPad14,5" :                               return "iPad Pro (12.9-inch) 6th Gen"
         case "iPad14,6" :                               return "iPad Pro (12.9-inch) 6th Gen"
         
         case "i386", "x86_64", "arm64":                 return identifier
         default:                                        return identifier
         
         }
         
         */
        
    }
    
    func totalDiskSpaceInBytes() -> Int64 {
        do {
            guard let totalDiskSpaceInBytes = try FileManager.default.attributesOfFileSystem(forPath: NSHomeDirectory())[FileAttributeKey.systemSize] as? Int64 else {
                return 0
            }
            return totalDiskSpaceInBytes
        } catch {
            return 0
        }
    }
    
    func totalDiskSpace() -> String {
        let diskSpaceInBytes = totalDiskSpaceInBytes()
        if diskSpaceInBytes > 0 {
            return ByteCountFormatter.string(fromByteCount: diskSpaceInBytes, countStyle: ByteCountFormatter.CountStyle.binary)
        }
        return "The total disk space on this device is unknown"
    }
    
    func deviceRemainingFreeSpaceInBytes() -> Int64? {
        let documentDirectory = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).last!
        guard
            let systemAttributes = try? FileManager.default.attributesOfFileSystem(forPath: documentDirectory),
            let freeSize = systemAttributes[.systemFreeSize] as? NSNumber
        else {
            // something failed
            return nil
        }
        
        return freeSize.int64Value
    }
    
}
