//
//  BottomSheetAnimator.swift
//  BottomSheet
//
//  Copyright © 2020 itomych. All rights reserved.
//

import UIKit

open class BottomSheetAnimator: NSObject {
    /// This enum described animatable view position
    public enum Position {
        case bottom
        case middle
        case top
        case custom(CGFloat)
        
        var value: CGFloat {
            switch self {
            case .bottom: return 0.2
            case .middle: return 0.5
            case .top: return 0.8
            /// available range: from 0 to 1
            /// min value = 0 - animatable view will be under super view / safe area
            /// max value = 1 - animatable view will be visible on full screen
            case .custom(let value): return value
            }
        }
    }
    
    public enum PanGestureDirection {
        case up
        case down
        
        init(_ value: CGFloat) {
            self = value.isLess(than: .zero) ? .up : .down
        }
    }
    
    /// View that contains animatable view. Don't add gesture recognizers on this view 'cause it animator does
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
    public var availablePositions: [Position] = [.bottom, .middle, .top]

    /// Animatable view current position
    public var currentPosition: Position = .bottom {
        didSet {
            setConstraint(height(for: currentPosition), animated: true)
        }
    }
    
    public var allowChangingPositionOnlyWhenScrollViewIsScrolledUp: Bool = false
    
    public var previousGesturePosition: CGPoint = .zero
    public var lastAnimatableScrollViewContentOffset: CGPoint = .zero
    
    /// This offset will be added for constraint
    /// Usage example: if screen embed in tab bar controller - you should set tab bar height to this property
    public var additionalOffset: CGFloat = .zero
    
    public var animationDuration: TimeInterval = CATransaction.animationDuration()
        
    /// If you have scroll view inside animatable view - you should handle scroll view delegate and call this method when view is scrolled
    open func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let contentOffset = scrollView.contentOffset
        
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
                guard !isAnimatableViewAtBottom else { return }
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
        case .began:
            return
        case .changed:
            let newValue = position.y - previousGesturePosition.y
            if needsToScrollInsteadChangingPosition(for: PanGestureDirection(newValue)) {
                let yContentOffset = animatableScrollView!.contentOffset.y - newValue
                animatableScrollView?.contentOffset.y = max(.zero, yContentOffset)
            } else {
                update(with: newValue, animated: false)
            }
        default:
            finishUpdate(with: position.y - previousGesturePosition.y)
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
    
    open func finishUpdate(with offset: CGFloat) {
        let newValue = animatableConstraint.constant + offset
        currentPosition = nearestPosition(for: newValue)
    }
    
    open func nearestPosition(for value: CGFloat) -> Position {
        var closestDistance: CGFloat = .greatestFiniteMagnitude
        var finalBoundaryPosition: Position = availablePositions.first ?? currentPosition
        availablePositions.forEach { position in
            let positionHeight = height(for: position)
            let diff = abs(positionHeight - value)
            if diff < closestDistance {
                closestDistance = diff
                finalBoundaryPosition = position
            }
        }
        return finalBoundaryPosition
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
    
    open func height(for position: Position) -> CGFloat {
        let height = gestureView.frame.size.height - gestureView.frame.size.height * position.value - additionalOffset
        return max(0, height)
    }
    
    open func setConstraint(_ constant: CGFloat, animated: Bool) {
        animatableConstraint.constant = constant
        guard animated else { return }
        UIView.animate(withDuration: animationDuration) {
            self.gestureView.layoutIfNeeded()
        }
    }
    
    open func needsToScrollInsteadChangingPosition(for direction: PanGestureDirection) -> Bool {
        guard allowChangingPositionOnlyWhenScrollViewIsScrolledUp, let scrollView = animatableScrollView, !scrollView.isDragging else { return false }
        guard let topPosition = availablePositions.last, animatableConstraint.constant == height(for: topPosition) else { return false }
        // If we scrolling up from top position - we should allow scrolling child scroll view
        // If we scrolling down from top position - we should allow scrolling only when content offset is greater than zero
        return scrollView.contentOffset.y > 0 || direction == .up
    }
    
    public var isAnimatableViewAtBottom: Bool {
        guard let minPosition = availablePositions.first else { return false }
        return animatableConstraint.constant == height(for: minPosition)
    }
}
