//
//  AppUtility.swift
//  DemoSigmaInteractive
//
//  Created by PhamHai on 04/04/2022.
//

import Foundation
import UIKit

struct AppUtility {
    static func lockOrientation(_ orientation: UIInterfaceOrientationMask) {
        if let delegate = UIApplication.shared.delegate as? AppDelegate {
            delegate.orientationLock = orientation
        }
    }
    /// OPTIONAL Added method to adjust lock and rotate to the desired orientation
    static func lockOrientation(_ orientation: UIInterfaceOrientationMask, andRotateTo rotateOrientation:UIInterfaceOrientation) {           self.lockOrientation(orientation);
        UIDevice.current.setValue(rotateOrientation.rawValue, forKey: "orientation");
        UINavigationController.attemptRotationToDeviceOrientation()
    }
}
