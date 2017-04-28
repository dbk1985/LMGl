//
//  LMGLProgramRGBA.swift
//  LMVr
//
//  Created by wzkj on 2017/4/24.
//  Copyright © 2017年 justbehere. All rights reserved.
//

import UIKit

class LMGLProgramRGBA: LMGLProgram{
    private let bundle : Bundle = {
        let bundlePath: String = (Bundle(for: LMGLProgramRGBA.self).resourcePath! as NSString).appendingPathComponent("vrlibraw.bundle")
        return Bundle(path:bundlePath)!
    }()
    
    
    private var vShaderPath:String {
        get{
            let vShaderPath : String = self.bundle.path(forResource: "per_pixel_vertex_shader", ofType: "glsl")!
            return vShaderPath
        }
    }
    private var vShaderContent: String {
        get{
            return readRawText(filePath: self.vShaderPath)
        }
    }
    
    private var fragShaderPath:String {
        get{
            let fragShaderPath: String = self.bundle.path(forResource: "per_pixel_fragment_shader_bitmap", ofType: "glsl")!
            return fragShaderPath
        }
    }
    private var fragShaderContent: String{
        get{ return readRawText(filePath: self.fragShaderPath) }
    }
    
    override func build() {
        super.build()
        // 编译着色器
        if !compileShader(shader: &self.vertexShader, type: GLenum(GL_VERTEX_SHADER), source: self.vShaderContent) {
            print("顶点着色器编译失败\n")
        }
        
        if !compileShader(shader: &self.fragmentShader, type: GLenum(GL_FRAGMENT_SHADER), source: self.fragShaderContent) {
            print("片段着色器编译失败\n")
        }
        
        let attrs:Array = Array(arrayLiteral: "a_Position","a_TexCoordinate")
        self.mGLProgram = createAndLinkProgram(vShader: self.vertexShader, fragShader: self.fragmentShader, attrs: attrs)
        
        self.mMVMatrix = glGetUniformLocation(self.mGLProgram, "u_MVMatrix")
        self.mMVPMatrix = glGetUniformLocation(self.mGLProgram, "u_MVPMatrix")
        self.mTextureUniform?.storeBytes(of: glGetUniformLocation(self.mGLProgram, "u_Texture"), as: Int32.self)
        
        self.mGLPositon = GLuint(glGetAttribLocation(self.mGLProgram, "a_Position"))
        self.mGLTextureCoordinate = GLuint(glGetAttribLocation(self.mGLProgram, "a_TexCoordinate"))
    }
    
    override func textureUniformSize() -> Int {
        return 1
    }
}
