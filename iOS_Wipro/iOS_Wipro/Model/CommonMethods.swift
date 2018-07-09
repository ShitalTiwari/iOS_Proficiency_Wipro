//
//  CommonMethods.swift
//  iOS_Wipro
//
//  Created by SierraVista Technologies Pvt Ltd on 09/07/18.
//  Copyright © 2018 Shital. All rights reserved.
//

import UIKit

class CommonMethods: NSObject {

    static func getCellHeight(text: String, width: CGFloat, font: UIFont) -> CGFloat {
        var cellHeight = 60.0 as CGFloat
        
        let sampleLabel = UILabel(frame: CGRect(x: 0, y: 0, width: width, height: CGFloat.greatestFiniteMagnitude))
        sampleLabel.numberOfLines = 0
        sampleLabel.lineBreakMode = .byWordWrapping
        sampleLabel.font = UIFont.systemFont(ofSize: 17.0)
        sampleLabel.text = text
        sampleLabel.sizeToFit()
        
        if sampleLabel.bounds.height > cellHeight {
            cellHeight = sampleLabel.bounds.height
        }
        
        return cellHeight
    }
    
}
