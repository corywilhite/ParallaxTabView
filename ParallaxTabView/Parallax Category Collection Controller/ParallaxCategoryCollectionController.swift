//
//  ParallaxCategoryCollectionController.swift
//  ParallaxTabView
//
//  Created by Cory Wilhite on 8/8/16.
//  Copyright © 2016 Cory Wilhite. All rights reserved.
//

import UIKit

protocol ParallaxCategoryCollectionControllerDelegate: class {
    func parallaxCategoryController(controller: ParallaxCategoryCollectionController, didSelectViewable viewable: ViewableCategoryObjectType)
}

class ParallaxCategoryCollectionController: NSObject, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    let category: ViewableCategory
    var standardPadding: CGFloat = 4
    weak var delegate: ParallaxCategoryCollectionControllerDelegate?
    lazy var collectionView: UICollectionView = self.createCollectionView()
    func createCollectionView() -> UICollectionView {
        let cv = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        cv.dataSource = self
        cv.delegate = self
        cv.backgroundColor = .clearColor()
        
        cv.registerNib(
            ParallaxCategoryCollectionViewCell.nib,
            forCellWithReuseIdentifier: ParallaxCategoryCollectionViewCell.identifier
        )
        
        return cv
    }
    
    init(category: ViewableCategory) {
        self.category = category
        super.init()
    }
    
    // MARK: - + UICollectioNViewDataSource
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return category.viewables.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(
            ParallaxCategoryCollectionViewCell.identifier,
            forIndexPath: indexPath
            ) as! ParallaxCategoryCollectionViewCell
        
        let model = category.viewables[indexPath.item]
        
        cell.backgroundColor = .whiteColor()
        cell.titleLabel.text = model.title
        cell.imageView.image = model.placeholderImage
        
        // make request to swap out image on cell
        
        // need to create a gradient image view class
        cell.gradientImageView.image = nil
        
        return cell
    }
    
    // MARK: - + UICollectionViewDelegate
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        delegate?.parallaxCategoryController(self, didSelectViewable: category.viewables[indexPath.item])
    }
    
    func collectionView(collectionView: UICollectionView, didHighlightItemAtIndexPath indexPath: NSIndexPath) {
        let cell = collectionView.cellForItemAtIndexPath(indexPath) as! ParallaxCategoryCollectionViewCell
        cell.highlight()
    }
    
    func collectionView(collectionView: UICollectionView, didUnhighlightItemAtIndexPath indexPath: NSIndexPath) {
        let cell = collectionView.cellForItemAtIndexPath(indexPath) as! ParallaxCategoryCollectionViewCell
        cell.unhighlight()
    }
    
    // MARK: - + UICollectionViewDelegateFlowLayout
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
        return standardPadding
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat {
        return standardPadding
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(
            top: standardPadding,
            left: standardPadding,
            bottom: standardPadding,
            right: standardPadding
        )
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        
        let sectionInsets = self.collectionView(
            collectionView,
            layout: collectionViewLayout,
            insetForSectionAtIndex: indexPath.section
        )
        
        let lineSpacing = self.collectionView(
            collectionView,
            layout: collectionViewLayout,
            minimumLineSpacingForSectionAtIndex: indexPath.section
        )
        
        let itemSpacing = self.collectionView(
            collectionView,
            layout: collectionViewLayout,
            minimumInteritemSpacingForSectionAtIndex: indexPath.section
        )
        
        let maxWidth = collectionView.frame.width - sectionInsets.left - sectionInsets.right
        
        let eightFiveWidth = ceil(5.0/8.0 * maxWidth)
        let landscapeSize = CGSize(width: maxWidth, height: eightFiveWidth)
        
        let normalWidth = (collectionView.frame.width - sectionInsets.left - sectionInsets.right - itemSpacing) / 2
        let normalHeight = (collectionView.frame.width - sectionInsets.top - sectionInsets.bottom - lineSpacing) / 2
        
        let normalSize = CGSize(width: normalWidth, height: normalHeight)
        
        if category.viewables.count < 5 {
            
            return landscapeSize
            
        } else {
            
            if category.viewables.count % 2 != 0 && indexPath.row == 0 {
                return landscapeSize
            } else {
                return normalSize
            }
            
        }
    }
}
