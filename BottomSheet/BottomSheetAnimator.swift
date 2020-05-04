//
//  BottomSheetAnimator.swift
//  BottomSheet
//
//  Copyright © 2020 itomych. All rights reserved.
//

import UIKit

open class BottomSheetAnimator: NSObject {
    /// View that contains animatable view. Don't add gesture recognizers on this view 'cause it does animator.
    @IBOutlet public weak var gestureView: UIView! {
        didSet {
            let panGesture = UIPanGestureRecognizer(target: self, action: #selector(panGestureValueChanged(_:)))
            panGesture.delegate = self
            gestureView.addGestureRecognizer(panGesture)
        }
    }
    
    @IBOutlet public weak var animatableView: UIView!
    
    /// If you have scroll view inside animatable view - you should set it to this property
    @IBOutlet public weak var animatableScrollView: UIScrollView?
    
    /// This should be bottom constraint from animatable view to super view / safe area
    @IBOutlet public weak var animatableConstraint: NSLayoutConstraint!
    
    /// This array should contains at least 2 values
    /// min value = 0 - animatable view will be under super view / safe area
    /// max value = 1 - animatable view will be visible on full screen
    public var availablePositions: [CGFloat] = [0.5, 1]

    /// Animatable view current position
    /// min value = 0 - animatable view will be under super view / safe area
    /// max value = 1 - animatable view will be visible on full screen
    public var currentPosition: CGFloat = .zero {
        didSet {
            setConstraint(height(for: currentPosition), animated: true)
        }
    }
    
    public var previousGesturePosition: CGPoint = .zero
    public var lastAnimatableScrollViewContentOffset: CGPoint = .zero
    
    /// This offset will be added for constraint
    /// Usage example: if screen embed in tab bar controller - you should set tab bar height to this property
    public var additionalOffset: CGFloat = .zero
    
    public var animationDuration: TimeInterval = CATransaction.animationDuration()
    
    /// This method used to set first available position to current position and update layout
    /// You should call this method after updating availablePositions
    open func updateCurrentPosition() {
        currentPosition = availablePositions.first ?? .zero
    }
        
    /// If you have scroll view inside animatable view - you should handle scroll view delegate and call this method when view is scrolled
    open func scrollViewDidScroll(_ scrollView: UIScrollView) {
        var contentOffset = scrollView.contentOffset
        
        if lastAnimatableScrollViewContentOffset.y < contentOffset.y {
            // Scrolling up
            if reachedTopPosition {
                lastAnimatableScrollViewContentOffset = contentOffset
            } else {
                scrollView.contentOffset = lastAnimatableScrollViewContentOffset
            }
        } else {
            // Scrolling down
            if lastAnimatableScrollViewContentOffset.y <= .zero {
                lastAnimatableScrollViewContentOffset = .zero
                scrollView.contentOffset = .zero
            } else {
                lastAnimatableScrollViewContentOffset = contentOffset
            }
        }
    }
}

extension BottomSheetAnimator: UIGestureRecognizerDelegate {
    @objc open func panGestureValueChanged(_ gesture: UIPanGestureRecognizer) {
        let position = gesture.translation(in: gestureView)
        defer { previousGesturePosition = position }
        switch gesture.state {
        case .changed:
            update(with: position.y - previousGesturePosition.y, animated: false)
        default:
            // TODO: Finish updating and scroll to nearest available position
            break
        }
    }
    
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

extension BottomSheetAnimator {
    open func update(with offset: CGFloat, animated: Bool) {
        guard isAvailableScroll(with: offset), let minPosition = availablePositions.first, let maxPosition = availablePositions.last else { return }
        var newValue = animatableConstraint.constant + offset
        
        let minPositionHeight = height(for: minPosition)
        let maxPositionHeight = height(for: maxPosition)
        
        // Min position shouldn't be less than zero
        // For zero min position we will have view.height min position height
        // In this case animatableView will be under screen as we work with bottom constraint
        // So min position height shouldn't be greater than view.height
        newValue = min(minPositionHeight, newValue)
        
        // Max position shouldn't be greater than gestureView.height
        // For gestureView.height max position we will have 0 max position height
        // In this case animatableView will be fully visible on screen as we work with bottom constraint
        // So max position height shouldn't be less than zero
        newValue = max(maxPositionHeight, newValue)
        
        setConstraint(newValue, animated: animated)
    }
}

extension BottomSheetAnimator {
    public var reachedTopPosition: Bool {
        guard let topPosition = availablePositions.last else { return false }
        let topPositionHeight = height(for: topPosition)
        
        // Top position shouldn't be greater than gestureView.height
        // For gestureView.height top position we will have 0 top position height
        // In this case animatableView will be fully visible on screen as we work with bottom constraint
        // So top position height shouldn't be less than zero
        return animatableConstraint.constant <= topPositionHeight
    }
    
    public var isActiveAnimatableScrollViewGesture: Bool {
        switch animatableScrollView?.panGestureRecognizer.state {
        case .began, .changed, .ended:
            return true
        default:
            return false
        }
    }
    
    open func isAvailableScroll(with offset: CGFloat) -> Bool {
        guard let scrollView = animatableScrollView, isActiveAnimatableScrollViewGesture else { return true }
        
        if offset < .zero {
            // Scrolling up
            return true
        } else {
            // Scrolling down
            return scrollView.contentOffset.y <= .zero
        }
    }
    
    open func height(for position: CGFloat) -> CGFloat {
        let height = gestureView.frame.size.height - gestureView.frame.size.height * position + additionalOffset
        return max(0, height)
    }
    
    open func setConstraint(_ constant: CGFloat, animated: Bool) {
        animatableConstraint.constant = constant
        guard animated else { return }
        UIView.animate(withDuration: animationDuration) {
            self.gestureView.layoutIfNeeded()
        }
    }
}
