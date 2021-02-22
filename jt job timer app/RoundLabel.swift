//
//  RoundLabel.swift
//  ImpattoAcustico
//
//  Created by Alberto on 20/08/2018.
//  Copyright © 2018 Alberto. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable

class RoundLabel: UILabel {
    
    @IBInspectable var cornerRadius: CGFloat = 0 {
        didSet {
            self.layer.cornerRadius = cornerRadius
            layer.masksToBounds = true
        }
    }
    @IBInspectable var borderWith: CGFloat = 0 {
        didSet {
            self.layer.borderWidth = borderWith
        }
    }
    @IBInspectable var borderColor: UIColor = UIColor.clear {
        didSet {
            self.layer.borderColor = borderColor.cgColor
        }
    }
}
