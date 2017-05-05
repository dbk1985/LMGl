//
//  LMGLImage.swift
//  LMVr
//
//  Created by wzkj on 2017/4/27.
//  Copyright © 2017年 justbehere. All rights reserved.
//

import UIKit

@objc class LMGLImage: NSObject,LMGLTextureSource {
    private(set) var size:CGSize
    private(set) var scale:Float
    private(set) var textureSize:CGSize
    private(set) var imageCost:Int = 0
    private(set) var premultipliedAlpha:Bool = false
    private(set) var imageSource:UIImage?
    
    static var imageCache:NSCache
    
    override class func initialize(){
        imageCache = NSCache()
        // 收到内存警告时 调用NSCache的removeAllObjects方法清除缓存的图片
        NotificationCenter.default.addObserver(imageCache!, selector: NSSelectorFromString("removeAllObjects"), name: NSNotification.Name.UIApplicationDidReceiveMemoryWarning, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(LMGLImage.imageCache!)
    }
    
    public static func imageWithNamed(nameOrPath name:String) -> LMGLImage{
        let path:String? = name.lm_normalizedPathWithDefalutExtension(ext: "png")
        var image:LMGLImage?
        if path != nil {
            image = imageCache?.object(forKey:path as AnyObject)
            if image == nil {
                image = LMGLImage(contentsOfFile: path)
                if image != nil {
                    imageCache?.setObject(image, forKey:path, cost:image!.imageCost)
                }
            }
        }
        return image
    }
    
    convenience init(contentsOfFile nameOrPath:String) {
        let path:String = nameOrPath.lm_normalizedPathWithDefalutExtension(ext: "png")
        if path != nil {
            let data:NSData = NSData(contentsOfFile: path)
            let scale:Float = path.lm_screenScaleFromFileSuffix()
            self.init(data: data, scale: scale)
        }
    }
    
    convenience init(image:UIImage) {
        self.imageSource = image
        self.init(size: image.size, scale: image.scale)
    }
    
    /**
     实例化一个LMGLImage对象
     
     - parameter size:         大小
     - parameter scale:        缩放比例
     
     - returns: 
     */
    convenience init(size:CGSize, scale:Float) {
        //dimensions and scale
        self.scale = scale
        self.size = size
        let textureWidth:Float = pow(2.0, ceil(log2(Float(size.width) * scale)))
        let textureHeight:Float = pow(2.0, ceil(log2(Float(size.height) * scale)))
        
        self.textureSize = CGSize(width:CGFloat(textureWidth), height:CGFloat(textureHeight))
        
        //alpha
        self.premultipliedAlpha = true;
        
        //get texture size
        let width:Int = Int(self.textureSize.width)
        let height:Int = Int(self.textureSize.height)
        /**
         图片占用内存计算
         图像占用内存的公式是：numBytes = width * height * bitsPerPixel / 8
         
         OpenGL ES  纹理的宽和高都要是2次幂数, 以刚才的例子来说, 假如 start.png 本身是 480x320, 但在载入内存後, 它其实会被变成一张 512x512 的纹理, 而start.png 则由 101x131 变成 128x256, 默认情况下面，当你在cocos2d里面加载一张图片的时候，对于每一个像素点使用４个byte来表示--１个byte（８位）代表red，另外３个byte分别代表green、blue和alpha透明通道。这个就简称RGBA8888
         图像宽度（width）×图像高度（height）×每一个像素的位数（bytes　per　pixel）　=　内存大小
         　　此时，如果你有一张５１２×５１２的图片，那么当你使用默认的像素格式去加载它的话，那么将耗费
         　　５１２×５１２×４=１MB
         1MB = 1024 KB= 1024*1024 B
         
         PVRTC4: Compressed format, 4 bits per pixel, ok image quality
         PVRTC2: Compressed format, 2 bits per pixel, poor image quality
         一般pvr格式文件的图像格式有：
         RGBA8888: 32-bit texture with alpha channel, best image quality
         RGBA4444: 16-bit texture with alpha channel, good image quality
         RGB565: 16-bit texture without alpha channel, good image quality but no alpha (transparency)
         */
        self.imageCost = width * height * 4;
    }
    
}
