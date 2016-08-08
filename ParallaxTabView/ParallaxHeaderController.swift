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
    
    class func with(customView customView: UIView, height: CGFloat, minimumHeight: CGFloat, mode: Mode = .fill) -> ParallaxHeaderController {
        let header = ParallaxHeaderController()
        header.view = customView
        header.height = height
        header.minimumHeight = minimumHeight
        header.mode = mode
        
        return header
    }
    
    class func with(nibName nibName: String, height: CGFloat, minimumHeight: CGFloat, mode: Mode = .fill) -> ParallaxHeaderController {
        let header = ParallaxHeaderController()
        header.view = NSBundle.mainBundle().loadNibNamed(nibName, owner: self, options: nil).first as? UIView
        header.height = height
        header.minimumHeight = minimumHeight
        header.mode = mode
        
        return header
    }
    
    enum Mode {
        case center
        case fill
        case top
        case bottom
    }
    
    weak var _scrollView: UIScrollView?
    weak var scrollView: UIScrollView? {
        get {
            return _scrollView
        }
        
        set {
            if _scrollView != newValue {
                _scrollView = newValue
                
                guard let scrollView = _scrollView else { return }
                
                setScrollViewContentTopInset(scrollView.contentInset.top + height)
                
                scrollView.addSubview(contentView)
                layoutContentView()
                _isObserving = true
            }
        }
    }
    
    
    var _contentView: UIView?
    var contentView: UIView {
        get {
            if _contentView == nil {
                let newView = ParallaxView(frame: .zero)
                newView.parent = self
                newView.clipsToBounds = true
                _contentView = newView
            }
            
            return _contentView!
        }
    }
    
    var _view: UIView?
    var view: UIView? {
        get {
            return _view
        }
        
        set {
            if newValue != _view {
                _view = newValue
                updateConstraints()
            }
        }
    }
    
    var _height: CGFloat = 0
    var height: CGFloat {
        get {
            return _height
        }
        set {
            if _height != newValue {
                
                // even though when setting the scroll view, we nil check
                // before setting the content inset top, we need the
                // content layout to take place here along with
                // the constraints
                let topInset = scrollView?.contentInset.top ?? 0
                
                setScrollViewContentTopInset(topInset - _height + newValue)
                
                _height = newValue
                updateConstraints()
                layoutContentView()
            }
        }
    }
    
    func setScrollViewContentTopInset(top: CGFloat) {
        guard let scrollView = scrollView else { return }
        
        var inset = scrollView.contentInset
        
        var offset = scrollView.contentOffset
        offset.y += inset.top - top
        scrollView.contentOffset = offset
        
        inset.top = top
        scrollView.contentInset = inset
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
    
    var mode: Mode = .fill {
        didSet {
            if mode != oldValue {
                updateConstraints()
            }
        }
    }
    
    var _isObserving = false
    
    func updateConstraints() -> Void {
        
        guard let view = view else { return debugPrint("nil view") }
        
        view.removeFromSuperview()
        contentView.addSubview(view)
        view.translatesAutoresizingMaskIntoConstraints = false
        
        switch mode {
        case .fill:
            setFillModeConstraints()
        case .top: break
        case .bottom: break
        case .center: break
        }
    }
    
    func setFillModeConstraints() -> Void {
        guard let view = view else { return }
        let binding = ["v": view]
        contentView.addConstraints(
            NSLayoutConstraint.constraintsWithVisualFormat("H:|[v]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: binding)
                + NSLayoutConstraint.constraintsWithVisualFormat("V:|[v]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: binding)
        )
        
    }
    
    
    func layoutContentView() -> Void {
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