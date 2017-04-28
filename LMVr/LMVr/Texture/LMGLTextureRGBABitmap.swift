//
//  LMGLTextureRGBABitmap.swift
//  LMVr
//
//  Created by wzkj on 2017/4/25.
//  Copyright © 2017年 justbehere. All rights reserved.
//

import UIKit

@objc class LMGLTextureRGBABitmap: LMGLTexture,LMGLTextureCallback {
    /** 贴图提供者 */
    weak public var texturePorvider:LMGLTextureProvider?
    
    override func createTexture(mGLProgram: LMGLProgram, mEAGLContext: EAGLContext) {
        super.createTexture(mGLProgram: mGLProgram, mEAGLContext: mEAGLContext)
        self.mTextureId = createTextureId()
        
        // 提供图片
        if self.texturePorvider != nil && (self.texturePorvider?.responds(to: #selector(LMGLTextureProvider.onTextureProvider)))! {
            self.texturePorvider?.onTextureProvider(textureCallBack: self)
        }
    }
    
    fileprivate func createTextureId() -> GLuint{
        var textureId:GLuint = 0
        glActiveTexture(GLenum(GL_TEXTURE0))
        glGenTextures(1, &textureId)
        return textureId
    }
    
    /** 执行贴图回调,混合贴图 */
    func textureWithImage(image: LMGLTextureSource) {
        DispatchQueue.global().async {
            DispatchQueue.main.async {
                if self.willCreateTexture() && image.isKind(of: NSClassFromString("LMGLImage")!) {
                    self.blendTexture()
                    
                    // Bind to the texture in OpenGL
                    glActiveTexture(GLenum(GL_TEXTURE0));
                    glBindTexture(GLenum(GL_TEXTURE_2D), self.mTextureId);
                    
                    // Set filtering
                    glTexParameteri(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_MIN_FILTER), GL_NEAREST);
                    glTexParameteri(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_MAG_FILTER), GL_NEAREST);
                    
                    // for not mipmap
                    glTexParameteri(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_WRAP_S), GL_CLAMP_TO_EDGE);
                    glTexParameteri(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_WRAP_T), GL_CLAMP_TO_EDGE);
                    
                    // Load the bitmap into the bound texture.
                    //[GLUtil texImage2D:image];
                    
                    //glUniform1i(self.mGLProgram?.mTextureUniform, 0);
                    
                    //GLuint width = (GLuint)CGImageGetWidth(image.CGImage);
                    //GLuint height = (GLuint)CGImageGetHeight(image.CGImage);
                    //[self.sizeContext updateTextureWidth:width height:height];
                    
                    self.didCreateTexture()
                }
            }
        }
    }
    
}
