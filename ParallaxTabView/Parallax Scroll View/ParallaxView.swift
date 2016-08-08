//
//  ParallaxView.swift
//  ParallaxTabView
//
//  Created by Cory Wilhite on 8/8/16.
//  Copyright © 2016 Cory Wilhite. All rights reserved.
//

import UIKit

class ParallaxView: UIView {
    weak var parent: ParallaxHeaderController?
    
    override func willMoveToSuperview(newSuperview: UIView?) {
        guard let parent = parent else { return debugPrint("nil parent header") }
        superview?.removeObserver(
            parent,
            forKeyPath: "contentOffset",
            context: ParallaxHeaderController.context
        )
    }
    
    override func didMoveToSuperview() {
        guard let parent = parent else { return debugPrint("nil parent header") }
        
        superview?.addObserver(
            parent,
            forKeyPath: "contentOffset",
            options: .New,
            context: ParallaxHeaderController.context
        )
    }
}