//
//  UIFont+Helpers.swift
//  URLSessionMetrics
//
//  Created by Daniel Miedema on 7/1/17.
//  Copyright © 2017 dmiedema. All rights reserved.
//

import UIKit

extension UIFont {
    static var monospacedLabelFont: UIFont {
        guard let font = UIFont(name: "Menlo-Regular", size: UIFont.labelFontSize) else {
            fatalError("Unable to create font with 'Menlo-Regular'") }
        return font
    }
}
