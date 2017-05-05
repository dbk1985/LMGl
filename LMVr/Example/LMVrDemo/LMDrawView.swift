//
//  LMDrawView.swift
//  LMVrDemo
//
//  Created by wzkj on 2017/5/5.
//  Copyright © 2017年 dzeep. All rights reserved.
//

import UIKit
import CoreGraphics

class LMDrawView: UIView {
    
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        
        let context:CGContext = UIGraphicsGetCurrentContext()!
        let image:UIImage = #imageLiteral(resourceName: "a.png")
        context.draw(image.cgImage!, in: CGRect(origin: CGPoint.zero, size: image.size))
    }
    
}
