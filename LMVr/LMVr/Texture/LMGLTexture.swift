//
//  LMGLTexture.swift
//  LMVr
//
//  Created by wzkj on 2017/4/17.
//  Copyright © 2017年 justbehere. All rights reserved.
//

import UIKit
import CoreGraphics

/**
 颜色混合模式：http://www.cppblog.com/wc250en007/archive/2012/07/18/184088.html
 GL_ZERO：     表示使用0.0作为因子，实际上相当于不使用这种颜色参与混合运算。
 GL_ONE：      表示使用1.0作为因子，实际上相当于完全的使用了这种颜色参与混合运算。
 GL_SRC_ALPHA：表示使用源颜色的alpha值来作为因子。
 GL_DST_ALPHA：表示使用目标颜色的alpha值来作为因子。
 GL_ONE_MINUS_SRC_ALPHA：表示用1.0减去源颜色的alpha值来作为因子。
 GL_ONE_MINUS_DST_ALPHA：表示用1.0减去目标颜色的alpha值来作为因子。
 */
enum LMGLBlendMode {
    case None;      // 不使用
    case Normal;    // GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA
    case Multiply;  // GL_DST_COLOR, GL_ONE_MINUS_SRC_ALPHA
    case Add;       // GL_SRC_ALPHA, GL_ONE
    case Screen; // GL_SRC_ALPHA, GL_ONE_MINUS_SRC_COLOR
}

@objc protocol LMGLTextureSource : NSObjectProtocol {
    var size:CGSize {get}
    var scale:Float {get}
    var textureSize:CGSize {get}
    var imageCost:Int {get}
    var premultipliedAlpha:Bool {get}
    var imageSource:UIImage? {get}
}

/** 贴图提供者 */
@objc protocol LMGLTextureProvider : NSObjectProtocol {
    @objc func onTextureProvider(textureCallBack:LMGLTextureCallback) -> Void;
}

/** 响应回调，贴图提供者需要通过贴图对象响应回调的方法将贴图资源传递个贴图对象 */
@objc protocol LMGLTextureCallback : NSObjectProtocol {
    @objc func textureWithImage(image:LMGLTextureSource)
}

/** 
 *  初始化时必须提供 EAGLContext(贴图绘制区域) glProgram着色器程序
 *  该类是贴图的基础类，不能实例化，必须通过子类来使用
 */
@objc class LMGLTexture: NSObject,LMGLDestory {
    internal var mGLProgram:LMGLProgram?
    internal var mEAGLContext:EAGLContext?
    public var mTextureId:GLuint = 0
    public var mBlendMode:LMGLBlendMode = .None
    
    /** 创建贴图对象，并通过代理还获取贴图，通过回调函数把图片传入
     *
     * - Parameters:
     * - mGLProgram: GL程序
     * - mEAGLContext: GL上下文
     */
    public func createTexture(mGLProgram:LMGLProgram,mEAGLContext:EAGLContext){
        self.mGLProgram = mGLProgram
        self.mEAGLContext = mEAGLContext
    }
    
    func willCreateTexture() -> Bool {
        if self.mEAGLContext != nil {
            if self.mEAGLContext != EAGLContext.current() {
                EAGLContext.setCurrent(self.mEAGLContext)
            }
            return true
        }
        return false
    }
    // 贴图已经创建
    func didCreateTexture() -> Void {
        
    }
    
    /** 混合 */
    func blendTexture() -> Void{
        guard self.mBlendMode == .None else {
            glEnable(GLenum(GL_TEXTURE_2D))
            glEnable(GLenum(GL_BLEND))
            
            var source:GLenum = 0, dest:GLenum = 0
            switch self.mBlendMode {
            case .Normal:
                source = GLenum(GL_SRC_ALPHA)
                dest = GLenum(GL_ONE_MINUS_SRC_ALPHA)
            case .Multiply:
                source = GLenum(GL_DST_COLOR)
                dest = GLenum(GL_ONE_MINUS_SRC_ALPHA)
                
            case .Add:
                source = GLenum(GL_SRC_ALPHA)
                dest = GLenum(GL_ONE)
            case .Screen:
                source = GLenum(GL_SRC_ALPHA)
                dest = GLenum(GL_ONE_MINUS_SRC_COLOR)
            default: break
            }
            
            if source == GLenum(GL_SRC_ALPHA) /*&& self.pre*/ {
                dest = GLenum(GL_ONE)
            }
            glBlendFunc(source, dest)
            return
        }
    }
    
    /** 贴图 */
    final internal func textureImage2D(glImage:LMGLTextureSource) {
        assert(glImage != nil && glImage != nil, "图片对象不能为空")
        //get texture size
        let width:Int     = glImage.textureSize.width
        let height:Int    = glImage.textureSize.height
        let cgImage = glImage.imageSource?.cgImage
        var imageData:UnsafeMutableRawPointer<Int> = malloc(glImage.imageCost)
        
        let colorSpace= CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGBitmapInfo(rawValue: CGBitmapInfo.byteOrder32Big.rawValue | CGImageAlphaInfo.premultipliedLast.rawValue).rawValue
        let context:CGContext = CGContext(data:imageData, width:width, height:height, bitsPerComponent:8, bytesPerRow:width * 4, space:colorSpace, bitmapInfo:bitmapInfo)!
        
        context.translateBy(x: 0, y: glImage.textureSize.height)
        context.scaleBy(x: CGFloat(glImage.scale), y: CGFloat(-glImage.scale))
        UIGraphicsPushContext(context)
        context.clear(CGRect(origin:CGPoint.zero, size:glImage.textureSize))
        context.draw(glImage.imageSource!.cgImage!, in: CGRect(origin: CGPoint.zero, size: glImage.textureSize))
        UIGraphicsPopContext()
        
        glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, width, height, 0, GL_RGBA, GL_UNSIGNED_BYTE, imageData);
        lmGLCheck(msg: "texImage2D")
        
        free(imageData)
    }
    
    func destory() {}
    
    /**
     override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
     // 根据手指位置设置颜色
     let touch = touches.first
     let p = touch!.locationInView(imgView!)
     pointView!.center = p
     changeCurrentColor(p)
     }
     
     override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
     // 根据手指位置设置颜色
     let touch = touches.first
     let p = touch!.locationInView(imgView!)
     pointView!.center = p
     changeCurrentColor(p)
     }
     
     func  changeCurrentColor(point:CGPoint){
     
     // 获取图片大小
     let imgWidth = CGFloat(CGImageGetWidth(imgView!.image!.CGImage))
     let imgHeight = CGFloat(CGImageGetHeight(imgView!.image!.CGImage))
     
     // 当前点在图片中的相对位置
     let pInImage = CGPointMake(point.x * imgWidth / imgView!.bounds.size.width,
     point.y * imgHeight / imgView!.bounds.size.height)
     
     // 获取并设置颜色
     resultView!.backgroundColor = Demo1_ColorPicker.getColor(pInImage, image: imgView!.image!)
     }
     */
    /**
     参考: http://www.cocoachina.com/bbs/read.php?tid=109919
     */
    func getColor(point:CGPoint, image:UIImage) -> UIColor{
        
        // 获取图片信息
        let imgCGImage = image.CGImage
        let imgWidth = CGImageGetWidth(imgCGImage)
        let imgHeight = CGImageGetHeight(imgCGImage)
        
        // 位图的大小 ＝ 图片宽 ＊ 图片高 ＊ 图片中每点包含的信息量
        let bitmapByteCount = imgWidth * imgHeight * 4
        
        // 使用系统的颜色空间
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        
        // 根据位图大小，申请内存空间
        let bitmapData = malloc(bitmapByteCount)
        defer {free(bitmapData)}
        
        // 创建一个位图
        let context = CGBitmapContextCreate(bitmapData,
                                            imgWidth,
                                            imgHeight,
                                            8,
                                            imgWidth * 4,
                                            colorSpace,
                                            CGImageAlphaInfo.PremultipliedFirst.rawValue)
        
        // 图片的rect
        let rect = CGRectMake(0, 0, CGFloat(imgWidth), CGFloat(imgHeight))
        
        // 将图片画到位图中
        CGContextDrawImage(context, rect, imgCGImage)
        
        // 获取位图数据
        let data = CGBitmapContextGetData(context)
        
        /**
         强转指针类型
         参考:http://www.csdn.net/article/2015-01-20/2823635-swift-pointer
         http://c.biancheng.net/cpp/html/2282.html
         */
        let charData = unsafeBitCast(data, UnsafePointer<CUnsignedChar>.self)
        
        // 根据当前所选择的点计算出对应位图数据的index
        let offset = (Int(point.y) * imgWidth + Int(point.x)) * 4
        
        // 获取4种信息
        let alpha = (charData+offset).memory
        let red   = (charData+offset+1).memory
        let green = (charData+offset+2).memory
        let blue  = (charData+offset+3).memory
        
        // 得到颜色
        let color = UIColor(red: CGFloat(red)/255.0, green: CGFloat(green)/255.0, blue: CGFloat(blue)/255.0, alpha: CGFloat(alpha)/255.0)
        
        return color
    }
}
