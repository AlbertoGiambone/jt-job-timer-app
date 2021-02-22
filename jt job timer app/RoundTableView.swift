//
//  RoundTableView.swift
//  jt job timer app
//
//  Created by Alberto Giambone on 23/12/20.
//

import Foundation
import UIKit

@IBDesignable

class RoundTableView: UITableView{
    
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
