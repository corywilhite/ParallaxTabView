//
//  ParallaxHeaderController.swift
//  ParallaxTabView
//
//  Created by Cory Wilhite on 8/8/16.
//  Copyright © 2016 Cory Wilhite. All rights reserved.
//

import UIKit

protocol ParallaxHeaderViewType {
    func parallaxHeaderDidScroll(controller: ParallaxHeaderController)
}

class ParallaxHeaderController: NSObject {
    
    // MARK: - Constructors
    
    class func with(customView customView: UIView, height: CGFloat, minimumHeight: CGFloat) -> ParallaxHeaderController {
        let header = ParallaxHeaderController()
        header.view = customView
        header.height = height
        header.minimumHeight = minimumHeight
        
        return header
    }
    
    class func with(nibName nibName: String, height: CGFloat, minimumHeight: CGFloat) -> ParallaxHeaderController {
        let header = ParallaxHeaderController()
        header.view = NSBundle.mainBundle().loadNibNamed(nibName, owner: self, options: nil).first as? UIView
        header.height = height
        header.minimumHeight = minimumHeight
        
        return header
    }
    
    // MARK: - Properties
    
    weak var scrollView: UIScrollView? {
        didSet {
            guard let scrollView = scrollView else { return }
            if scrollView == oldValue { return }
            
            set(contentInsetTop: scrollView.contentInset.top + height, of: scrollView)
            
            scrollView.addSubview(contentView)
            layoutContentView()
        }
    }
    
    private(set) lazy var contentView: UIView = self.createContentView()
    private func createContentView() -> UIView {
        let view = ParallaxView(frame: .zero)
        view.parent = self
        view.clipsToBounds = true
        return view
    }
    
    var view: UIView? {
        didSet {
            if oldValue == view { return }
            updateConstraints()
        }
    }
    
    var height: CGFloat = 0 {
        willSet {
            if newValue == height { return }
            let topInset = scrollView?.contentInset.top ?? 0
            set(contentInsetTop: topInset - height + newValue, of: scrollView)
        }
        didSet {
            if oldValue == height { return }
            updateConstraints()
            layoutContentView()
        }
    }
    
    var minimumHeight: CGFloat = 50 {
        didSet {
            layoutContentView()
        }
    }
    
    var progress: CGFloat {
        let x = height > 0 ? (1 / height) * contentView.frame.size.height - minimumHeight : 1
        return x - 1
    }
    
    // MARK: - Helpers
    
    private func set(contentInsetTop contentInsetTop: CGFloat, of scrollView: UIScrollView?) {
        guard let scrollView = scrollView else { return }
        
        var inset = scrollView.contentInset
        
        var offset = scrollView.contentOffset
        offset.y += inset.top - contentInsetTop
        scrollView.contentOffset = offset
        
        inset.top = contentInsetTop
        scrollView.contentInset = inset
    }
    
    private func updateConstraints() -> Void {
        
        guard let view = view else { return debugPrint("nil view") }
        
        view.removeFromSuperview()
        contentView.addSubview(view)
        view.translatesAutoresizingMaskIntoConstraints = false
        
        setFillConstraints(for: view, to: contentView)
    }
    
    private func setFillConstraints(for view: UIView, to contentView: UIView) {
        let binding = ["v": view]
        
        let layoutFormatOption = NSLayoutFormatOptions(rawValue: 0)
        
        let horizConstraints = NSLayoutConstraint.constraintsWithVisualFormat(
            "H:|[v]|",
            options: layoutFormatOption,
            metrics: nil,
            views: binding
        )
        
        let vertConstraints = NSLayoutConstraint.constraintsWithVisualFormat(
            "V:|[v]|",
            options: layoutFormatOption,
            metrics: nil,
            views: binding
        )
        
        contentView.addConstraints(horizConstraints + vertConstraints)
    }
    
    private func layoutContentView() -> Void {
        guard let scrollView = scrollView else { return }
        let minHeight = min(minimumHeight, height)
        let relativeYOffset = height - scrollView.contentOffset.y - scrollView.contentInset.top
        
        contentView.frame = CGRect(
            x: 0,
            y: -relativeYOffset,
            width: scrollView.frame.size.width,
            height: max(relativeYOffset, minHeight)
        )
    }
    
    // MARK: - KVO Observing
    
    static let context = UnsafeMutablePointer<Void>.alloc(1)
    
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        
        if context == ParallaxHeaderController.context {
            if let keyPath = keyPath where keyPath == "contentOffset" {
                layoutContentView()
                
                if let view = view as? ParallaxHeaderViewType {
                    view.parallaxHeaderDidScroll(self)
                }
            }
        } else {
            super.observeValueForKeyPath(keyPath, ofObject: object, change: change, context: context)
        }
        
    }
}