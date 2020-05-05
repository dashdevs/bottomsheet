//
//  PlainViewController.swift
//  BottomSheet
//
//  Copyright © 2020 itomych. All rights reserved.
//

import UIKit

class PlainViewController: UIViewController {
    @IBOutlet weak var animator: BottomSheetAnimator!
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.destination {
        case let viewController as TableViewController:
            viewController.onDidScroll = { [weak self] scrollView in
                self?.animator.scrollViewDidScroll(scrollView)
            }
            viewController.onViewDidLoad = { [weak self] in
                guard let strongSelf = self else { return }
                strongSelf.animator.animatableScrollView = viewController.tableView
                strongSelf.animator.availablePositions = [.bottom, .middle, .custom(1)]
                strongSelf.animator.currentPosition = .bottom
            }
        default:
            super.prepare(for: segue, sender: sender)
        }
    }
}
