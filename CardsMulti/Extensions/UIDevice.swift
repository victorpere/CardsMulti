
import UIKit

public extension UIDevice {
    
    var identifier: String {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        return machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
    }
    
    var hasSquaredCorners: Bool {
        // https://gist.github.com/adamawolf/3048717
        switch self.identifier {
        case "iPhone10,1",  // 8
             "iPhone10,2",  // 8 plus
             "iPhone10,4",  // 8
             "iPhone10,5",  // 8 plus
             "iPhone12,8",  // SE 2nd gen
             "iPhone14,6":  // SE 3rd gen
            return true
        default:
            return false
        }
    }
    
    
    var backgroundFileName: String {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        
        switch identifier {
        case "iPhone4,1":                               return "iPhone4s"
        case "iPhone5,1",
             "iPhone5,2",
             "iPhone5,3",
             "iPhone5,4",
             "iPhone6,1",
             "iPhone6,2",
             "iPhone8,4",
             "iPod5,1",
             "iPod7,1":                                 return "iPhone5"
            
        case "iPhone7,2",
             "iPhone8,1",
             "iPhone9,1",
             "iPhone9,3":                               return "iPhone6"
            
        case "iPhone7,1",
             "iPhone8,2",
             "iPhone9,2",
             "iPhone9,4":                               return "iPhone6Plus"
            
            
        case "iPad2,1",
             "iPad2,2",
             "iPad2,3",
             "iPad2,4",
             "iPad2,5",
             "iPad2,6",
             "iPad2,7",
             "iPad3,1",
             "iPad3,2",
             "iPad3,3",
             "iPad3,4",
             "iPad3,5",
             "iPad3,6",
             "iPad4,1",
             "iPad4,2",
             "iPad4,3",
             "iPad5,3",
             "iPad5,4",
             "iPad4,4",
             "iPad4,5",
             "iPad4,6",
             "iPad4,7",
             "iPad4,8",
             "iPad4,9",
             "iPad5,1",
             "iPad5,2",
             "iPad6,3",
             "iPad6,4":                                 return "iPad"
            
        case "iPad6,7",
             "iPad6,8"                                  :return "iPadPro"
            
        default:
            //if identifier.substring(to: identifier.index(a.startIndex, offsetBy: 4)) == "iPad"
            return "iPadPro"
        }
    }
    
}
