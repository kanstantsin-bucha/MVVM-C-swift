//
//  Utils.swift
//  doroga
//
//  Created by Bucha Kanstantsin on 7/3/16.
//  Copyright © 2016 Bucha Kanstantsin. All rights reserved.
//

import UIKit

typealias Completion = () -> Void
typealias ErrorCompletion<ErrorType> = (_ error : ErrorType?) -> ()
typealias DataCompletion<ErrorType, DataType> = (_ error: ErrorType?,
                                                 _ data: DataType) -> ()


class Utils: NSObject {

    /**
     Method returns an instance of the storyboard defined by the storyboardName String parameter
     
     - parameter storyboardName: UString
     
     - returns: UIStoryboard
     */
    class func storyboardBoardWithName(_ storyboardName: String) -> UIStoryboard {
        let storyboard = UIStoryboard(name: storyboardName, bundle: Bundle.main)
        return storyboard
    }

    /**
     Method returns an instance of the view controller defined by the vcName paramter from the storyboard defined by the storyboardName parameter
     
     - parameter vcName:         String
     - parameter storyboardName: String
     
     - returns: UIViewController?
     */
    class func vcWithNameFromStoryboardWithName(_ vcName: String, storyboardName: String) -> UIViewController {
        let storyboard = storyboardBoardWithName(storyboardName)
        let viewController = storyboard.instantiateViewController(withIdentifier: vcName)
        return viewController
    }

    /**
     Method gets a key from a plist, both specified in parameters
     
     - parameter plist: String
     - parameter key:   String
     
     - returns: String?
     */
    class func getKeyFromPlist(_ plist: String, key: String) -> String? {
        if let path: String = Bundle.main.path(forResource: plist, ofType: "plist"),
           let keyList = NSDictionary(contentsOfFile: path),
           let key = keyList[key] as? String {
            return key
        }
        return nil
    }
    
    /**
     Method gets a key from a plist, both specified in parameters
     
     - parameter plist: String
     - parameter key:   String
     
     - returns: Bool?
     */
    class func getBoolValueWithKeyFromPlist(_ plist: String, key: String) -> Bool? {
        if let path: String = Bundle.main.path(forResource: plist, ofType: "plist"),
           let keyList = NSDictionary(contentsOfFile: path),
           let key = keyList[key] as? Bool {
            return key
        }
        return nil
    }
    
    /**
     Method gets a key from a plist, both specified in parameters
     
     - parameter plist: String
     - parameter key:   String
     
     - returns: String
     */
    class func getStringValueWithKeyFromPlist(_ plist: String, key: String) -> String? {
        if let path: String = Bundle.main.path(forResource: plist, ofType: "plist"),
           let keyList = NSDictionary(contentsOfFile: path),
           let key = keyList[key] as? String {
            return key
        }
        return nil
    }
}
