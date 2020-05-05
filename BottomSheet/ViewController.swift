//
//  ViewController.swift
//  BottomSheet
//
//  Copyright © 2020 itomych. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    @IBAction func plainViewController() {
        guard let vc = UIStoryboard(name: "Plain", bundle: nil).instantiateInitialViewController() else { return }
        present(vc, animated: true)
    }
}

extension UIViewController {
    @IBAction func dismiss() {
        dismiss(animated: true)
    }
}
