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

class ParallaxTabCollectionController: NSObject, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    let titles: [ParallaxTabModel]
    weak var delegate: ParallaxTabCollectionControllerDelegate?
    
    var minimumHorizontalTabSpacing: CGFloat = 10
    
    lazy var collectionView: UICollectionView = self.createCollectionView()
    func createCollectionView() -> UICollectionView {
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .Horizontal
        
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.dataSource = self
        cv.delegate = self
        cv.scrollEnabled = false
        cv.allowsMultipleSelection = false
        cv.backgroundColor = .clearColor()
        
        cv.registerNib(
            ParallaxTabCollectionViewCell.nib,
            forCellWithReuseIdentifier: ParallaxTabCollectionViewCell.identifier
        )
        
        return cv
    }
    
    init(titles: [ParallaxTabModel], delegate: ParallaxTabCollectionControllerDelegate?) {
        self.titles = titles
        self.delegate = delegate
    }
    
    private func xOffsetFromCenterForTabAtIndex(index: CGFloat) -> CGFloat {
        let indexPath = NSIndexPath(forItem: Int(index), inSection: 0)
        guard let attributes = collectionView.collectionViewLayout.layoutAttributesForItemAtIndexPath(indexPath) else { return 0 }
        
        let midX = attributes.frame.midX
        let offset = midX - collectionView.frame.midX
        
        return offset
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
    
    // MARK: - + UICollectionViewDelegate
    
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
    
    // MARK: - + UICollectionViewDelegateFlowLayout
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
        return minimumHorizontalTabSpacing
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        
        let model = titles[indexPath.item]
        let normalAttributedTitle = model.normalAttributedTitle()
        let selectedAttributedTitle = model.selectedAttributedTitle()
        
        
        let normalBoundingRect = normalAttributedTitle.boundingRectWithSize(
            CGSize(width: CGFloat.max, height: collectionView.frame.height),
            options: NSStringDrawingOptions(rawValue: 0),
            context: nil
        )
        
        let selectedBoundingRect = selectedAttributedTitle.boundingRectWithSize(
            CGSize(width: CGFloat.max, height: collectionView.frame.height),
            options: NSStringDrawingOptions(rawValue: 0),
            context: nil
        )
        
        let dynamicWidth = max(normalBoundingRect.width, selectedBoundingRect.width)
        
        return CGSize(width: dynamicWidth, height: collectionView.frame.height)
    }
    
}