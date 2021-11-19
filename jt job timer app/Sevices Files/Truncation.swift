//
//  Truncation.swift
//  trasmPad
//
//  Created by Alberto on 28/08/2018.
//  Copyright © 2018 Alberto. All rights reserved.
//

import Foundation

extension Double
{
    func truncate(places : Int)-> Double
    {
        return Double(floor(pow(10.0, Double(places)) * self)/pow(10.0, Double(places)))
    }
}
