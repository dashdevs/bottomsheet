//
//  BottomSheetAnimator.swift
//  BottomSheet
//
//  Copyright © 2020 itomych. All rights reserved.
//

import UIKit

open class BottomSheetAnimator: NSObject {
    /// View that contains animatable view. Don't add gesture recognizers on this view 'cause it does animator.
    @IBOutlet public weak var gestureView: UIView!
    
    @IBOutlet public weak var animatableView: UIView!
    
    /// This should be bottom constraint from animatable view to super view / safe area
    @IBOutlet public weak var animatableConstraint: NSLayoutConstraint!
    
    /// This array should contains at least 2 values
    /// min value = 0 - animatable view will be under super view / safe area
    /// max value = 1 - animatable view will be visible on full screen
    public var availablePositions: [CGFloat] = [0.5, 1]

    /// Animatable view current position
    /// min value = 0 - animatable view will be under super view / safe area
    /// max value = 1 - animatable view will be visible on full screen
    public var currentPosition: CGFloat = .zero
    
    /// This offset will be added for constraint
    /// Usage example: if screen embed in tab bar controller - you should set tab bar height to this property
    public var additionalOffset: CGFloat = .zero
    
    /// This method used to set first available position to current position and update layout
    /// You should call this method after updating availablePositions
    open func updateCurrentPosition() {
        currentPosition = availablePositions.first ?? .zero
        // TODO: Update layout
    }
    
    /// If you have scroll view inside animatable view - you should handle scroll view delegate and call this method when view is scrolled
    open func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
    }
}
