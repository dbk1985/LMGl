//
//  LMGLImage.swift
//  LMVr
//
//  Created by wzkj on 2017/4/27.
//  Copyright © 2017年 justbehere. All rights reserved.
//

import UIKit

@objc class LMGLImage: NSObject,LMGLTextureSource {
    private(set) var size:CGSize?
    private(set) var scal:Float?
    private(set) var textureSize:CGSize?
    
    
    
    //    public static func imageWithNamed(nameOrPath name:String) -> LMGLImage{
    //        
    //    }
    
    init(contentsOfFile nameOrPath:String) {
        
    }
    
    init(image:UIImage) {
        
    }
    
    /**
     实例化一个LMGLImage对象
     
     - parameter size:         大小
     - parameter scale:        缩放比例
     - parameter drawingBlock: 绘制完图片回调
     
     - returns: 
     */
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
