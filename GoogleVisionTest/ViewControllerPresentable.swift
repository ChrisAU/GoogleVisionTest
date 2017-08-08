//
//  ViewControllerPresentable.swift
//  GoogleVisionTest
//
//  Created by Chris Nevin on 08/08/2017.
//  Copyright © 2017 CJNevin. All rights reserved.
//

import Foundation
import UIKit

protocol ViewControllerPresentable: class {
    func present(_ viewController: UIViewController)
    func dismiss(_ viewController: UIViewController)
}

extension UIViewController: ViewControllerPresentable {
    func present(_ viewController: UIViewController) {
        present(viewController, animated: true, completion: nil)
    }
    
    func dismiss(_ viewController: UIViewController) {
        viewController.dismiss(animated: true, completion: nil)
    }
}
