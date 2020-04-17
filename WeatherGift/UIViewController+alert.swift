//
//  UIViewController+alert.swift
//  ToDo List
//
//  Created by Cooper Schmitz on 3/9/20.
//  Copyright © 2020 Cooper Schmitz. All rights reserved.
//

import UIKit

extension UIViewController {
    func oneButtonAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        //create alert action
        let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        //add default action to alert controller
        alertController.addAction(defaultAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
}
