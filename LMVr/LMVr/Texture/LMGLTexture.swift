//
//  LMGLTexture.swift
//  LMVr
//
//  Created by wzkj on 2017/4/17.
//  Copyright © 2017年 justbehere. All rights reserved.
//

import UIKit

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
    
    func destory() {}
}
