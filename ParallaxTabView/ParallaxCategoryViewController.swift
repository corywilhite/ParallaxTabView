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

struct ViewableCategory {
    let tabModel: ParallaxTabModel
    let viewables: [ViewableCategoryObjectType]
}

class ParallaxCategoryViewController: UIViewController {
    
    required init(categories: [ViewableCategory]) {
        super.init(nibName: nil, bundle: nil)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .whiteColor()
    }
}




