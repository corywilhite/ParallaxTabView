//
//  ParallaxTabCollectionViewCell.swift
//  ParallaxTabView
//
//  Created by Cory Wilhite on 8/8/16.
//  Copyright © 2016 Cory Wilhite. All rights reserved.
//

import UIKit

protocol NibProvidable {
    static var nib: UINib { get }
    static var bundle: NSBundle { get }
}

protocol Identifiable {
    static var identifier: String { get }
}

extension Identifiable {
    static var identifier: String {
        return String(self)
    }
}

extension NibProvidable where Self: Identifiable {
    static var bundle: NSBundle {
        return .mainBundle()
    }
    static var nib: UINib {
        return UINib(nibName: Self.identifier, bundle: Self.bundle)
    }
}

class ParallaxTabCollectionViewCell: UICollectionViewCell, Identifiable, NibProvidable {
    @IBOutlet var titleLabel: UILabel!
    
    static var bundle: NSBundle {
        return NSBundle(forClass: ParallaxTabCollectionViewCell.self)
    }
}