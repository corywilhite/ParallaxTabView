//
//  ParallaxCategoryCollectionViewCell.swift
//  ParallaxTabView
//
//  Created by Cory Wilhite on 8/8/16.
//  Copyright © 2016 Cory Wilhite. All rights reserved.
//

import UIKit

struct HighlightConfiguration {
    enum State {
        case highlight
        case unhighlight
    }
    
    typealias AnimationAction = () -> Void
    
    private var highlightAction: AnimationAction = {}
    private var unhighlightAction: AnimationAction = {}
    
    func on(state: State, action: AnimationAction) -> HighlightConfiguration {
        var temp = self
        
        switch state {
        case .highlight:
            temp.highlightAction = action
        case .unhighlight:
            temp.unhighlightAction = action
        }
        
        return temp
    }
}

protocol Highlightable {
    func highlightActions() -> HighlightConfiguration
}

extension Highlightable {
    func highlight() {
        highlightActions().highlightAction()
    }
    
    func unhighlight() {
        highlightActions().unhighlightAction()
    }
}

class ParallaxCategoryCollectionViewCell: UICollectionViewCell, Identifiable, NibProvidable, Highlightable {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var highlightBackgroundView: UIView!
    @IBOutlet weak var gradientImageView: UIImageView!
    
    static var bundle: NSBundle {
        return NSBundle(forClass: ParallaxCategoryCollectionViewCell.self)
    }
    
    func highlightActions() -> HighlightConfiguration {
        return  HighlightConfiguration()
                .on(.highlight) {
                    UIView.animateWithDuration(0.2) { [unowned self] in
                        self.titleLabel.alpha = 0
                        self.gradientImageView.alpha = 0
                        self.highlightBackgroundView.alpha = 0.2
                    }
                }
                .on(.unhighlight) {
                    UIView.animateWithDuration(0.2) { [unowned self] in
                        self.titleLabel.alpha = 1
                        self.gradientImageView.alpha = 1
                        self.highlightBackgroundView.alpha = 0
                    }
                }
    }
}