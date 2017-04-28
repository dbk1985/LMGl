//
//  LMVRRender.swift
//  LMVr
//
//  Created by wzkj on 2017/4/24.
//  Copyright © 2017年 justbehere. All rights reserved.
//

import UIKit

private class LMVRRender: NSObject {
    private var mGLProgram:LMGLProgram
    private var mGLTexture:LMGLTexture
    private var projectionManager:LMGLProjectionManager
    private var displayManager:LMGLDisplayManager
    
    init(mGLProgram:LMGLProgram,mGLTexture:LMGLTexture,projectionManager:LMGLProjectionManager,displayManager:LMGLDisplayManager) {
        self.mGLProgram = mGLProgram
        self.mGLTexture = mGLTexture
        self.projectionManager = projectionManager
        self.displayManager = displayManager
        super.init()
    }
    
    /** 渲染前的准备工作 */
    func randerOnCreate(context:EAGLContext) -> Void {
        lmGLCheck(msg: "glEnable")
        
        self.mGLProgram.build()
        lmGLCheck(msg: "initProgram")
        
        // 创建贴图
        self.mGLTexture.createTexture(mGLProgram: self.mGLProgram, mEAGLContext: context)
        
        
    }
    
    
}
