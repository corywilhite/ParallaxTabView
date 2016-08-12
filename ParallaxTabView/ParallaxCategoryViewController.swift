//
//  ParallaxTabViewController.swift
//  ParallaxTabView
//
//  Created by Cory Wilhite on 8/8/16.
//  Copyright © 2016 Cory Wilhite. All rights reserved.
//

import UIKit

protocol ViewableCategoryObjectType {
    var title: String { get }
    var imageURL: String { get }
    var placeholderImage: UIImage? { get }
    var gradientImage: UIImage? { get }
    var sortKey: String { get }
}

struct ViewableCategoryObject: ViewableCategoryObjectType {
    let title: String
    let imageURL: String
    let placeholderImage: UIImage?
    let gradientImage: UIImage?
    let sortKey: String
}

struct ViewableCategory {
    let title: String
    let viewables: [ViewableCategoryObjectType]
    func tabModel(normalAttributes normalAttributes: [String: AnyObject], selectedAttributes: [String: AnyObject]) -> ParallaxTabModel {
        return ParallaxTabModel(
            title: title,
            normalAttributes: normalAttributes,
            selectedAttributes: selectedAttributes
        )
    }
}

class ParallaxHeaderView: UIView {
    
    @IBOutlet weak var tabCollectionView: ParallaxTabCollectionView! {
        didSet {
            tabCollectionView.delegate = delegate
            tabCollectionView.dataSource = dataSource
        }
    }
    @IBOutlet weak var navigationBarContainerView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var logoImageView: UIImageView!
    
    weak var delegate: protocol<UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>? {
        didSet {
            tabCollectionView.delegate = delegate
        }
    }
    
    weak var dataSource: UICollectionViewDataSource? {
        didSet {
            tabCollectionView.dataSource = dataSource
        }
    }
    
    func update(withVerticalProgress progress: CGFloat) {
        logoImageView.alpha = progress
        backgroundImageView.alpha = progress
    }
    
}

typealias ParallaxTabDelegate = protocol<UICollectionViewDelegateFlowLayout, UICollectionViewDataSource>

class ParallaxCategoryScrollView: ParallaxScrollView {
    
    var tabCollectionController: ParallaxTabCollectionController?
    
    lazy var parallaxHeaderView: ParallaxHeaderView = ParallaxCategoryScrollView.createParallaxHeaderView()
    static func createParallaxHeaderView() -> ParallaxHeaderView {
        let v = NSBundle(forClass: ParallaxHeaderView.self).loadNibNamed(
            String(ParallaxHeaderView),
            owner: self,
            options: nil
        ).first as! ParallaxHeaderView
        
        v.backgroundColor = .greenColor()
        
        return v
    }
    
    lazy var horizontalScrollView: UIScrollView = self.configureHorizontalScrollView()
    func configureHorizontalScrollView() -> UIScrollView {
        let sv = UIScrollView(frame: .zero)
        sv.pagingEnabled = true
        sv.bounces = false
        sv.delegate = self
        sv.backgroundColor = .clearColor()
        
        return sv
    }
    
    var categories: [ViewableCategory] = [] {
        didSet {
            configure(with: categories)
        }
    }
    
    class func with(categories categories: [ViewableCategory], delegate: ParallaxScrollViewDelegate, tabDelegate: ParallaxTabCollectionControllerDelegate) -> ParallaxCategoryScrollView {
        
        let normalAttributes: [String: AnyObject] = [:]
        let selectedAttributes: [String: AnyObject] = [:]
        
        let tabModels = categories.map {
            $0.tabModel(
                normalAttributes: normalAttributes,
                selectedAttributes: selectedAttributes
            )
        }
        
        let ptc = ParallaxTabCollectionController(titles: tabModels)
        ptc.delegate = tabDelegate
        
        let headerView = ParallaxCategoryScrollView.createParallaxHeaderView()
        headerView.delegate = ptc
        headerView.dataSource = ptc
        let header = ParallaxHeaderController.with(
            customView: headerView,
            height: 200,
            minimumHeight: 64
        )
        
        let sv = ParallaxCategoryScrollView(frame: .zero, parallaxHeader: header, delegate: delegate)
        sv.parallaxHeaderView = headerView
        sv.categories = categories
        sv.tabCollectionController = ptc
        sv.addSubview(sv.horizontalScrollView)
        
        snapEdges(of: sv.horizontalScrollView, to: sv)
        
        return sv
    }
    
    
    
    func configure(with categories: [ViewableCategory]) {
        
    }
    
}

func snapEdges(of view: UIView, to parentView: UIView) {
    
    parentView.translatesAutoresizingMaskIntoConstraints = false
    view.translatesAutoresizingMaskIntoConstraints = false
    
    let leading = NSLayoutConstraint(
        item: view,
        attribute: .Leading,
        relatedBy: .Equal,
        toItem: parentView,
        attribute: .Leading,
        multiplier: 1.0,
        constant: 0
    )
    
    let trailing = NSLayoutConstraint(
        item: view,
        attribute: .Trailing,
        relatedBy: .Equal,
        toItem: parentView,
        attribute: .Trailing,
        multiplier: 1.0,
        constant: 0
    )
    
    let top = NSLayoutConstraint(
        item: view,
        attribute: .Top,
        relatedBy: .Equal,
        toItem: parentView,
        attribute: .Top,
        multiplier: 1.0,
        constant: 0
    )
    
    let bottom = NSLayoutConstraint(
        item: view,
        attribute: .Bottom,
        relatedBy: .Equal,
        toItem: parentView,
        attribute: .Bottom,
        multiplier: 1.0,
        constant: 0
    )
    
    parentView.addConstraints([leading, trailing, top, bottom])
}


class ParallaxCategoryViewController: UIViewController, ParallaxScrollViewDelegate, ParallaxTabCollectionControllerDelegate {
    
    // MARK: - Embedded Types
    
    struct Range {
        let low: CGFloat
        let high: CGFloat
    }
    
    // MARK: - Variables
    
    let categories: [ViewableCategory]
    let backgroundImage = UIImageView(image: nil)
    let maxHeaderHeight: CGFloat = 250
    let minHeaderHeight: CGFloat = 118
    
    // MARK: - Initialization
    
    required init(categories: [ViewableCategory]) {
        self.categories = categories
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("\(#function) has not been implemented")
    }
    
    // MARK: - Lazy Load variables
    
    lazy var collectionControllers: [ParallaxCategoryCollectionController] = self.createControllers(with: self.categories)
    
    func createControllers(with categories: [ViewableCategory]) -> [ParallaxCategoryCollectionController] {
        return categories.map { ParallaxCategoryCollectionController(category: $0) }
    }
    
    
    
    lazy var horizontalScrollView: UIScrollView = self.configureHorizontalScrollView()
    
    func configureHorizontalScrollView() -> UIScrollView {
        let sv = UIScrollView(frame: .zero)
        sv.pagingEnabled = true
        sv.bounces = false
        sv.delegate = self
        sv.backgroundColor = .clearColor()
        
        return sv
    }
    
    
    
    lazy var parallaxHeaderView: ParallaxHeaderView = self.createParallaxHeaderView()
    
    func createParallaxHeaderView() -> ParallaxHeaderView {
        let v = NSBundle(forClass: ParallaxHeaderView.self).loadNibNamed(
            String(ParallaxHeaderView),
            owner: self,
            options: nil
        ).first as! ParallaxHeaderView
        
        v.delegate = self.tabController
        v.dataSource = self.tabController
        
        v.backgroundColor = .blueColor()
        
        return v
    }
    
    
    
    lazy var tabController: ParallaxTabCollectionController = self.createTabController(with: self.categories)
    
    func createTabController(with categories: [ViewableCategory]) -> ParallaxTabCollectionController {
        
        let normalAttributes: [String: AnyObject] = [
            NSFontAttributeName: UIFont.systemFontOfSize(16)
        ]
        let selectedAttributes: [String: AnyObject] = [
            NSFontAttributeName: UIFont.systemFontOfSize(16)
        ]
        
        let tabModels = categories.map {
            return $0.tabModel(
                normalAttributes: normalAttributes,
                selectedAttributes: selectedAttributes
            )
        }
        
        let controller = ParallaxTabCollectionController(titles: tabModels)
        controller.delegate = self
        
        return controller
    }
    
    
    
    lazy var parallaxHeaderController: ParallaxHeaderController = self.createParallaxHeaderController(with: self.parallaxHeaderView)
    
    func createParallaxHeaderController(with headerView: UIView) -> ParallaxHeaderController {
        let controller = ParallaxHeaderController.with(
            customView: headerView,
            height: maxHeaderHeight,
            minimumHeight: minHeaderHeight
        )
        
        return controller
    }
    
    
    
    lazy var parallaxScrollView: ParallaxScrollView = self.createParallaxScrollView(header: self.parallaxHeaderController)
    
    func createParallaxScrollView(header header: ParallaxHeaderController) -> ParallaxScrollView {
        let psv = ParallaxScrollView(
            frame: .zero,
            parallaxHeader: header,
            delegate: self
        )
        return psv
    }
    
    
    // MARK: - Helpers
    
    
    func addParallaxScrollView() {
        view.addSubview(parallaxScrollView)
        snapEdges(of: parallaxScrollView, to: view)
    }
    
    func configureMainView() {
        view.backgroundColor = .whiteColor()
        view.addSubview(backgroundImage)
        snapEdges(of: backgroundImage, to: view)
    }
    
    func add(controllers controllers: [ParallaxCategoryCollectionController], to view: UIView) {
        for controller in controllers {
            view.addSubview(controller.collectionView)
        }
    }
    
    func layout(collectionViews collectionViews: [UICollectionView], in frame: CGRect) {
        for index in 0..<collectionViews.count {
            let offsetFrame = CGRectOffset(frame, CGFloat(index) * frame.width, 0)
            collectionViews[index].frame = offsetFrame
        }
    }
    
    func allCollectionViews() -> [UICollectionView] {
        return collectionControllers.map { $0.collectionView }
    }
    
    func initialIndex() -> CGFloat {
        return collectionControllers.count <= 2 ? 0 : 1
    }
    
    func establishInitialLayout() {
        let initialOffset = parallaxHeaderView.tabCollectionView.xOffsetFromCenterForTabAtIndex(initialIndex())
        
        horizontalScrollView.contentOffset = CGPoint(x: initialIndex() * horizontalScrollView.bounds.width, y: 0)
        
        parallaxHeaderView.tabCollectionView.contentOffset = CGPoint(x: initialOffset, y: 0)
    }
    
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureMainView()
        addParallaxScrollView()
        
        parallaxScrollView.addSubview(horizontalScrollView)
        
        add(controllers: collectionControllers, to: horizontalScrollView)
        
        view.layoutIfNeeded()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        parallaxScrollView.contentSize = view.frame.size
        
        let newFrame = CGRect(
            x: view.frame.origin.x,
            y: view.frame.origin.y,
            width: view.frame.width,
            height: view.frame.height - minHeaderHeight
        )
        
        horizontalScrollView.frame = newFrame
        
        horizontalScrollView.contentSize = CGSize(
            width: newFrame.width * CGFloat(collectionControllers.count),
            height: newFrame.height
        )
        
        layout(collectionViews: allCollectionViews(), in: newFrame)
        
        if _isInitialLayout {
            establishInitialLayout()
        }
        
        _isInitialLayout = false
    }
    
    
    // MARK: - Private Scrolling State variables
    
    private var _isInitialLayout = true
    private var _lastSetIndex: CGFloat = 0
    private let SKIP_INDEX = CGFloat.max
    private var _shouldSelectIndexOnScroll = true
    
    // MARK: - Scrolling Helpers
    
    func normalize(value value: CGFloat, in inputRange: Range, to outputRange: Range) -> CGFloat {
        return ((value - inputRange.low) / (inputRange.high - inputRange.low)) * (outputRange.high - outputRange.low) + outputRange.low
    }
    
    func calculateVerticalThresholdProgress(for scrollView: UIScrollView, against headerView: ParallaxHeaderView) -> CGFloat {
        let minHeight = scrollView.contentOffset.y + minHeaderHeight
        let offsetRange = maxHeaderHeight - minHeaderHeight
        let vertProgress = fabs(minHeight) / offsetRange
        
        return min(1, vertProgress)
    }
    
    func horizontalOffsetInterval(from scrollView: UIScrollView) -> CGFloat {
        return scrollView.contentOffset.x / scrollView.frame.width
    }
    
    func validatePageInterval(from scrollView: UIScrollView, with calculatedInterval: CGFloat) -> CGFloat? {
        if fmod(calculatedInterval, 1) == 0 {
            return calculatedInterval
        } else {
            return nil
        }
    }
    
    
    // MARK: - + ParallaxScrollViewDelegate
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        let vertScrollingProgress = calculateVerticalThresholdProgress(
            for: parallaxScrollView,
            against: parallaxHeaderView
        )
        
        parallaxHeaderView.update(withVerticalProgress: vertScrollingProgress)
        
        // using the minimum header height as the threshold to trigger the title label
        // animating in and out
        let shouldAnimateAway = parallaxHeaderView.frame.height > minHeaderHeight
        let notAlreadyHidden = parallaxHeaderView.titleLabel.alpha != 0
        
        
        // checks to see if the alpha is not already at the desired value to essentially
        // dedupe the animation blocks
        
        if shouldAnimateAway && notAlreadyHidden {
            // animate away title label
            UIView.animateWithDuration(0.15) { [unowned self] in
                self.parallaxHeaderView.titleLabel.alpha = 0
            }
        }
        
        let notAlreadyShowing = parallaxHeaderView.titleLabel.alpha != 1
        
        if shouldAnimateAway == false && notAlreadyShowing {
            // animate in
            UIView.animateWithDuration(0.15) { [unowned self] in
                self.parallaxHeaderView.titleLabel.alpha = 1
            }
            
        }
        
        
        
        
        if scrollView == horizontalScrollView {
            let interval = horizontalOffsetInterval(from: horizontalScrollView)
            let firstIndex: CGFloat = 0
            let lastIndex = collectionControllers.count - 1
            
            let toIndex: CGFloat
            
            if horizontalScrollView.contentOffset.x > _lastSetIndex * horizontalScrollView.bounds.width {
                
                if interval > _lastSetIndex + 1 {
                    _lastSetIndex = min( ceil(interval), CGFloat(lastIndex) )
                    return
                }
                
                toIndex = _lastSetIndex + 1
            } else if horizontalScrollView.contentOffset.x < _lastSetIndex * horizontalScrollView.bounds.width && _lastSetIndex > firstIndex {
                
                if interval < _lastSetIndex - 1 {
                    _lastSetIndex = max( floor(interval), firstIndex)
                }
                toIndex = _lastSetIndex - 1
            } else {
                toIndex = SKIP_INDEX
            }
            
            if toIndex != SKIP_INDEX {
                
                let currentMainXOffset = horizontalScrollView.contentOffset.x
                let currentIndexTabXOffset = parallaxHeaderView.tabCollectionView.xOffsetFromCenterForTabAtIndex(_lastSetIndex)
                
                let toIndexMainXOffset = horizontalScrollView.bounds.width * toIndex
                let toIndexTabXOffset = parallaxHeaderView.tabCollectionView.xOffsetFromCenterForTabAtIndex(toIndex)
                
                let mainRange = Range(
                    low: _lastSetIndex * horizontalScrollView.bounds.width,
                    high: toIndexMainXOffset
                )
                
                let tabRange = Range(
                    low: currentIndexTabXOffset,
                    high: toIndexTabXOffset
                )
                
                let normalizedOffsetValue = normalize(
                    value: currentMainXOffset,
                    in: mainRange,
                    to: tabRange
                )
                
                parallaxHeaderView.tabCollectionView.contentOffset = CGPoint(x: normalizedOffsetValue, y: 0)
            }
            
            let page = validatePageInterval(from: horizontalScrollView, with: interval)
            
            if page != nil {
                _lastSetIndex = page!
            }
            
            if _shouldSelectIndexOnScroll {
                parallaxHeaderView.tabCollectionView.selectItemAtIndexPath(
                    NSIndexPath(forItem: Int(_lastSetIndex), inSection: 0),
                    animated: false,
                    scrollPosition: .None
                )
            } else {
                if page != nil {
                    _shouldSelectIndexOnScroll = true
                }
            }
        }
    }
    
    // MARK: - + ParallaxTabCollectionControllerDelegate
    
    func tabController(tabController: ParallaxTabCollectionController, didSelectTabAtIndex index: Int) {
        debugPrint("index selected: \(index)")
        _shouldSelectIndexOnScroll = false
        
        if CGFloat(index) == _lastSetIndex && collectionControllers[index].collectionView.contentOffset != .zero {
            debugPrint("same page")
            collectionControllers[index].collectionView.setContentOffset(.zero, animated: true)
            
        }
        
        horizontalScrollView.setContentOffset(CGPoint(x: horizontalScrollView.bounds.width * CGFloat(index), y: 0), animated: true)
    }
}




