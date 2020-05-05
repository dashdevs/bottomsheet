//
//  ViewController.swift
//  BottomSheet
//
//  Copyright © 2020 itomych. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    @IBAction func embedInPlainViewController() {
        guard let vc = UIStoryboard(name: "Plain", bundle: nil).instantiateInitialViewController() else { return }
        present(vc, animated: true)
    }
    
    @IBAction func embedInNavigationViewController() {
        guard let vc = UIStoryboard(name: "Navigation", bundle: nil).instantiateInitialViewController() else { return }
        present(vc, animated: true)
    }
    
    @IBAction func embedInTabBarViewController() {
        guard let vc = UIStoryboard(name: "TabBar", bundle: nil).instantiateInitialViewController() else { return }
        present(vc, animated: true)
    }
}

extension UIViewController {
    @IBAction func dismiss() {
        dismiss(animated: true)
    }
}
