//
//  RoundButton.swift
//  ImpattoAcustico
//
//  Created by Alberto on 20/08/2018.
//  Copyright © 2018 Alberto. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable

class RoundButton: UIButton {
    
    @IBInspectable var cornerRadius: CGFloat = 0 {
        didSet {
            self.layer.cornerRadius = cornerRadius
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

