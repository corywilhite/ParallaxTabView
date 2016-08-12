//
//  ParallaxTabCollectionController.swift
//  ParallaxTabView
//
//  Created by Cory Wilhite on 8/8/16.
//  Copyright © 2016 Cory Wilhite. All rights reserved.
//

import UIKit

protocol ParallaxTabCollectionControllerDelegate: class {
    func tabController(tabController: ParallaxTabCollectionController, didSelectTabAtIndex index: Int)
}

struct ParallaxTabModel {
    let title: String
    let normalAttributes: [String: AnyObject]
    let selectedAttributes: [String: AnyObject]
    
    func normalAttributedTitle() -> NSAttributedString {
        return NSAttributedString(string: title, attributes: normalAttributes)
    }
    
    func selectedAttributedTitle() -> NSAttributedString {
        return NSAttributedString(string: title, attributes: selectedAttributes)
    }
}

class ParallaxTabCollectionView: UICollectionView {
    
    required convenience init() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .Horizontal
        self.init(frame: .zero, collectionViewLayout: layout)
    }
    
    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)
        initialize()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
    }
    
    func initialize() {
        (collectionViewLayout as? UICollectionViewFlowLayout)?.scrollDirection = .Horizontal
        scrollEnabled = false
        allowsMultipleSelection = false
        backgroundColor = .clearColor()
        registerNib(
            ParallaxTabCollectionViewCell.nib,
            forCellWithReuseIdentifier: ParallaxTabCollectionViewCell.identifier
        )
    }
    
    override func intrinsicContentSize() -> CGSize {
        let contentSize = collectionViewLayout.collectionViewContentSize()
        
        return CGSize(width: contentSize.width, height: 50)
    }
    
    func xOffsetFromCenterForTabAtIndex(index: CGFloat) -> CGFloat {
        // prevents index out of bounds errors
        if index < 0 { return 0 }
        
        let indexPath = NSIndexPath(forItem: Int(index), inSection: 0)
        guard let attributes = collectionViewLayout.layoutAttributesForItemAtIndexPath(indexPath) else { return 0 }
        
        let midX = attributes.frame.midX
        let offset = midX - frame.midX
        
        return offset
    }
}


class ParallaxTabCollectionController: NSObject, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    // MARK: - Properties
    
    let titles: [ParallaxTabModel]
    weak var delegate: ParallaxTabCollectionControllerDelegate?
    var minimumHorizontalTabSpacing: CGFloat = 10
    
    // MARK: - Initialization
    
    init(titles: [ParallaxTabModel]) {
        self.titles = titles
    }
    
    // MARK: - + UICollectionViewDataSource
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return titles.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCellWithReuseIdentifier(ParallaxTabCollectionViewCell.identifier, forIndexPath: indexPath) as? ParallaxTabCollectionViewCell else { fatalError() }
        
        cell.backgroundColor = .clearColor()
        cell.titleLabel.textColor = .whiteColor()
        cell.titleLabel.textAlignment = .Center
        
        cell.titleLabel.attributedText = cell.selected ?
            titles[indexPath.item].selectedAttributedTitle() :
            titles[indexPath.item].normalAttributedTitle()
        
        return cell
    }
    
    // MARK: - + UICollectionViewDelegateFlowLayout (delegate)
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let cell = collectionView.cellForItemAtIndexPath(indexPath) as! ParallaxTabCollectionViewCell
        cell.titleLabel.attributedText = titles[indexPath.item].selectedAttributedTitle()
        delegate?.tabController(self, didSelectTabAtIndex: indexPath.item)
    }
    
    func collectionView(collectionView: UICollectionView, didDeselectItemAtIndexPath indexPath: NSIndexPath) {
        let cell = collectionView.cellForItemAtIndexPath(indexPath) as! ParallaxTabCollectionViewCell
        cell.titleLabel.attributedText = titles[indexPath.item].normalAttributedTitle()
    }
    
    func collectionView(collectionView: UICollectionView, didHighlightItemAtIndexPath indexPath: NSIndexPath) {
        let cell = collectionView.cellForItemAtIndexPath(indexPath) as! ParallaxTabCollectionViewCell
        cell.titleLabel.attributedText = titles[indexPath.item].selectedAttributedTitle()
    }
    
    func collectionView(collectionView: UICollectionView, didUnhighlightItemAtIndexPath indexPath: NSIndexPath) {
        let cell = collectionView.cellForItemAtIndexPath(indexPath) as! ParallaxTabCollectionViewCell
        cell.titleLabel.attributedText = titles[indexPath.item].normalAttributedTitle()
    }
    
    // MARK: - + UICollectionViewDelegateFlowLayout (layout)
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
        return minimumHorizontalTabSpacing
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        
        let model = titles[indexPath.item]
        let normalAttributedTitle = model.normalAttributedTitle()
        let selectedAttributedTitle = model.selectedAttributedTitle()
        
        let drawingOption = NSStringDrawingOptions(rawValue: 0)
        
        let normalBoundingRect = normalAttributedTitle.boundingRectWithSize(
            CGSize(width: CGFloat.max, height: collectionView.frame.height),
            options: drawingOption,
            context: nil
        )
        
        let selectedBoundingRect = selectedAttributedTitle.boundingRectWithSize(
            CGSize(width: CGFloat.max, height: collectionView.frame.height),
            options: drawingOption,
            context: nil
        )
        
        let dynamicWidth = max(normalBoundingRect.width, selectedBoundingRect.width)
        
        return CGSize(width: dynamicWidth, height: collectionView.frame.height)
    }
    
}