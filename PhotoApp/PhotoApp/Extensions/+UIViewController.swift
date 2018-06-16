//
//  +UIViewController.swift
//  PhotoApp
//
//  Created by 심 승민 on 2018. 6. 17..
//  Copyright © 2018년 심 승민. All rights reserved.
//

import UIKit

extension UIViewController {
    func showOKAlert(_ message: String, _ completion: (() -> (Void))?) {
        let alertController = UIAlertController(title: message, message: nil, preferredStyle: .alert)
        let okButton = UIAlertAction.init(title: "확인", style: .default, handler: nil)
        alertController.addAction(okButton)
        self.present(alertController, animated: true) {
            completion?()
        }
    }
}
