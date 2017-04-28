//
//  LMGLImage.swift
//  LMVr
//
//  Created by wzkj on 2017/4/27.
//  Copyright © 2017年 justbehere. All rights reserved.
//

import UIKit

@objc class LMGLImage: NSObject,LMGLTextureSource {
    private(set) var size:CGSize = CGSize.zero
    
    //    public static func imageWithNamed(nameOrPath name:String) -> LMGLImage{
    //        
    //    }
    
    init(contentsOfFile nameOrPath:String) {
        
    }
    
    init(image:UIImage) {
        
    }
    
    init(size:CGSize, scale:Float,drawingBlock:() -> Void) {
        drawingBlock()
    }
    
    init(data:NSData, scal:Float) {
        
    }
    
    init(premultipliedAlpha : Bool) {
        
    }
    init(blendMode:LMGLBlendMode) {
        
    }
    
    init(clipRect : CGRect) {
        
    }
    
    init(scale : Float) {
        
    }
    
    init(size : CGSize) {
        
    }
}
