//
//  WorkshopTweak.swift
//  The Workshop - Native Swift Logic & Swizzling Helper
//

import Foundation
import UIKit

@objc(WorkshopTweakManager)
public class WorkshopTweakManager: NSObject {
    @objc public static let shared = WorkshopTweakManager()

    @objc public var isEnabled: Bool = true
    @objc public var activeTargetProcess: String = "SpringBoard"

    @objc public func logEvent(_ message: String) {
        print("[TheWorkshop Swift] \(message)")
        #if DEBUG
        NSLog("[TheWorkshop Swift Debug] %@", message)
        #endif
    }

    @objc public func presentNativeAlert(title: String, message: String, from viewController: UIViewController) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            viewController.present(alert, animated: true, completion: nil)
        }
    }
}
