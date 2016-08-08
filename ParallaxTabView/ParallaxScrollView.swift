//
//  ParallaxScrollView.swift
//  parallax-tab-view
//
//  Created by Cory Wilhite on 8/2/16.
//  Copyright © 2016 Cory Wilhite. All rights reserved.
//

import Foundation
import UIKit

// MARK: - Parallax Scroll View Delegate
@objc protocol ParallaxScrollViewDelegate: UIScrollViewDelegate {
    optional func scrollingView(scrollingView: ParallaxScrollView, shouldScrollWithSubview subView: UIScrollView) -> Bool
}

// MARK: - Parallax Scroll View

class ParallaxScrollView: UIScrollView, UIScrollViewDelegate, UIGestureRecognizerDelegate {
    
    private var _lock = false
    private var _isObserving = false
    
    lazy var parallaxHeader: ParallaxHeaderController? = self.createParallaxHeader()
    private func createParallaxHeader() -> ParallaxHeaderController {
        let header = ParallaxHeaderController()
        header.scrollView = self
        return header
    }
    
    private(set) var observedViews: [UIScrollView] = []
    
    private var delegateForwarder: ScrollViewDelegateForwarder = ScrollViewDelegateForwarder()
    
    override var delegate: UIScrollViewDelegate? {
        get {
            return delegateForwarder.delegate
        }
        
        set {
            self.delegateForwarder.delegate = newValue as? ParallaxScrollViewDelegate
            
            super.delegate = nil
            super.delegate = delegateForwarder
        }
    }
    
    // MARK: - Initialization
    
    convenience init() {
        self.init(frame: .zero)
    }
    
    convenience init(frame:CGRect, parallaxHeader: ParallaxHeaderController, delegate: ParallaxScrollViewDelegate) {
        self.init(frame: frame, parallaxHeader: parallaxHeader)
        self.delegate = delegate
    }
    
    convenience init(frame: CGRect, parallaxHeader: ParallaxHeaderController) {
        self.init(frame: frame)
        self.parallaxHeader = parallaxHeader
        self.parallaxHeader!.scrollView = self
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
    }
    
    private func initialize() {
        super.delegate = delegateForwarder
        showsVerticalScrollIndicator = false
        directionalLockEnabled = true
        bounces = true
        
        addObserver(
            self,
            forKeyPath: "contentOffset",
            options: [.New, .Old],
            context: ParallaxScrollView.context
        )
        
        _isObserving = true
    }
    
    // MARK: - + UIGestureRecognizerDelegate
    
    override func gestureRecognizerShouldBegin(gestureRecognizer: UIGestureRecognizer) -> Bool {
        if let panRecognizer = gestureRecognizer as? UIPanGestureRecognizer {
            let velocity = panRecognizer.velocityInView(self)
            
            if fabs(velocity.x) > fabs(velocity.y) { return false }
        }
        
        return true
    }
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        
        guard let scrollView = otherGestureRecognizer.view as? UIScrollView else { return false }
        
        var shouldScroll = scrollView != self
        
        if shouldScroll {
            if let delegate = delegate as? ParallaxScrollViewDelegate,
                let newShouldScroll = delegate.scrollingView?(self, shouldScrollWithSubview: scrollView) {
                
                shouldScroll = newShouldScroll
            }
            
        }
        
        if shouldScroll {
            addObservedView(scrollView)
        }
        
        return shouldScroll
    }
    
    // MARK: - + UIScrollViewDelegate & Helpers
    
    func scrollView(scrollView: UIScrollView, setContentOffset contentOffset: CGPoint) {
        _isObserving = false
        scrollView.contentOffset = contentOffset
        _isObserving = true
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        guard let parallaxHeader = parallaxHeader else { return }
        
        if contentOffset.y > -parallaxHeader.minimumHeight {
            let offset = CGPoint(x: contentOffset.x, y: -parallaxHeader.minimumHeight)
            self.scrollView(self, setContentOffset: offset)
        }
    }
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        _lock = false
        removeObservedViews()
    }
    
    // MARK: - Key-Value Observing
    
    static let context = UnsafeMutablePointer<Void>.alloc(1)
    
    func addObserverToView(scrollView: UIScrollView) {
        scrollView.addObserver(
            self,
            forKeyPath: "contentOffset",
            options: [.New, .Old],
            context: ParallaxScrollView.context
        )
        _lock = scrollView.contentOffset.y > -scrollView.contentInset.top
    }
    
    func removeObserverFromView(scrollView: UIScrollView) {
        scrollView.removeObserver(
            self,
            forKeyPath: "contentOffset",
            context: ParallaxScrollView.context
        )
    }
    
    func addObservedView(scrollView: UIScrollView) {
        if observedViews.contains(scrollView) == false {
            observedViews.append(scrollView)
            addObserverToView(scrollView)
        }
    }
    
    func removeObservedViews() {
        observedViews.forEach(removeObserverFromView)
        observedViews.removeAll()
    }
    
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        
        if context == ParallaxScrollView.context {
            
            guard let keyPath = keyPath where keyPath == "contentOffset" else { return }
            
            guard let new = change?[NSKeyValueChangeNewKey]?.CGPointValue(),
                let old = change?[NSKeyValueChangeOldKey]?.CGPointValue() else { return }
            
            let diff = old.y - new.y
            
            if diff == 0 || _isObserving == false { return }
            
            if let safeObject = object as? NSObject where safeObject == self {
                
                if diff > 0 && _lock == true {
                    scrollView(self, setContentOffset: old)
                } else if (contentOffset.y < -contentInset.top) && bounces == false {
                    
                    let offset = CGPoint(x: contentOffset.x, y: -contentInset.top)
                    
                    scrollView(self, setContentOffset: offset)
                }
                
            } else {
                guard let scrollView = object as? UIScrollView else { return }
                guard let parallaxHeader = parallaxHeader else { return }
                
                _lock = scrollView.contentOffset.y > -scrollView.contentInset.top
                
                if contentOffset.y < -parallaxHeader.minimumHeight && _lock && diff < 0 {
                    self.scrollView(scrollView, setContentOffset: old)
                }
                
                if _lock == false && ((contentOffset.y > -contentInset.top) || bounces == true) {
                    let offset = CGPoint(x: scrollView.contentOffset.x, y: -scrollView.contentInset.top)
                    self.scrollView(scrollView, setContentOffset: offset)
                }
                
            }
            
        } else {
            super.observeValueForKeyPath(
                keyPath,
                ofObject: object,
                change: change,
                context: context
            )
        }
    }
    
    deinit {
        removeObserver(self, forKeyPath: "contentOffset", context: ParallaxScrollView.context)
        removeObservedViews()
    }
}