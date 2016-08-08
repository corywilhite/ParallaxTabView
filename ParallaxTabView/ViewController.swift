//
//  ViewController.swift
//  parallax-tab-view
//
//  Created by Cory Wilhite on 8/2/16.
//  Copyright © 2016 Cory Wilhite. All rights reserved.
//

import UIKit

class ViewController: UIViewController, ParallaxScrollViewDelegate {
    
    var castView: ParallaxScrollView!
    
    let headerView = UIView(frame: .zero)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        headerView.backgroundColor = .greenColor()
        let header = ParallaxHeaderController.with(
            customView: headerView,
            height: 150,
            minimumHeight: 50
        )
        
        castView = ParallaxScrollView(
            frame: view.frame,
            parallaxHeader: header,
            delegate: self
        )
        
        view.addSubview(castView)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        castView.frame = view.frame
        castView.contentSize = CGSize(width: view.bounds.width, height: 1000)
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        
        
        
        
    }
}