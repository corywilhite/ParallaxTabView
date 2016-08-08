//
//  ScrollViewDelegateForwarder.swift
//  ParallaxTabView
//
//  Created by Cory Wilhite on 8/8/16.
//  Copyright © 2016 Cory Wilhite. All rights reserved.
//

import UIKit

class ScrollViewDelegateForwarder: NSObject, ParallaxScrollViewDelegate {
    weak var delegate: ParallaxScrollViewDelegate?
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        if let castView = scrollView as? ParallaxScrollView {
            castView.scrollViewDidScroll(scrollView)
        }
        
        delegate?.scrollViewDidScroll?(scrollView)
    }
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        if let castView = scrollView as? ParallaxScrollView {
            castView.scrollViewDidEndDecelerating(scrollView)
        }
        
        delegate?.scrollViewDidEndDecelerating?(scrollView)
    }
    
    override func respondsToSelector(aSelector: Selector) -> Bool {
        return delegate?.respondsToSelector(aSelector) ?? false || super.respondsToSelector(aSelector)
    }
    
    override func forwardingTargetForSelector(aSelector: Selector) -> AnyObject? {
        return self.delegate
    }
}