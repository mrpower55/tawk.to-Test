//
//  GeneralFunctions.swift
//  tawk.to Test
//
//  Created by Mahmoud Shurrab on 12/03/2021.
//

import Foundation
import UIKit

class GeneralFunctions {
    static let shared = GeneralFunctions()
    
    private init() {}
    
    public func showPopUpDialog(_ title: String, _ message: String) {
        let alert = UIAlertController(style: .alert, title: title, message: message)
        alert.setTitle(font: .boldSystemFont(ofSize: 18), color: .black)
        alert.addAction(image: nil, title: NSLocalizedString("OK", comment: ""), color: .black, style: .default, isEnabled: true) { (UIAlertAction) in
            alert.dismiss(animated: true, completion: nil)
        }
        
        alert.show(animated: true, vibrate: true)
    }
}
