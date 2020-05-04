//
//  ViewController.swift
//  BottomSheet
//
//  Copyright © 2020 itomych. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var animator: BottomSheetAnimator!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        animator.availablePositions = [0.2, 0.5, 0.9]
        animator.currentPosition = 0.2
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.destination {
        case let viewController as TableViewController:
            animator.animatableScrollView = viewController.tableView
            viewController.onDidScroll = { [weak self] scrollView in
                self?.animator.scrollViewDidScroll(scrollView)
            }
        default:
            super.prepare(for: segue, sender: sender)
        }
    }
}
