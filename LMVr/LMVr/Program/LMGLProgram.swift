//
//  LMGLProgram.swift
//  LMVr
//
//  Created by wzkj on 2017/4/13.
//  Copyright © 2017年 justbehere. All rights reserved.
//

import UIKit

/// Gl程序  包含顶点着色器、片段着色器的创建 编译 链接等操作
class LMGLProgram: NSObject,LMGLDestory {
    /** 顶点着色器 */
    internal var vertexShader:GLuint = 0
    /** 片段着色器 */
    internal var fragmentShader:GLuint = 0
    /** OpenGL程序 */
    internal var mGLProgram: GLuint = 0
    internal var mGLPositon: GLuint = 0
    internal var mGLTextureCoordinate: GLuint = 0
    
    internal var mMVPMatrix: Int32 = 0
    internal var mMVMatrix:Int32 = 0
    internal var mContentType:Int32 = 0
    internal var mColorConversion:Int32 = 0
    internal var mTextureUniform:UnsafeMutableRawPointer?
    
    // 创建GL程序
    public func build() -> Void {
        self.mTextureUniform = malloc(MemoryLayout<Int32>.size * self.textureUniformSize())
    }
    
    public func use() -> Void {
        if self.mGLProgram != 0 {
            glUseProgram(self.mGLProgram)
        }
    }
    
    internal func destory() {
        if vertexShader != 0 {
            glDeleteShader(vertexShader)
            vertexShader = 0
        }
        
        if fragmentShader != 0 {
            glDeleteShader(fragmentShader)
            fragmentShader = 0
        }
        
        if self.mGLProgram != 0 {
            glDeleteProgram(mGLProgram)
            mGLProgram = 0
        }
        
        if self.mTextureUniform != nil {
            free(self.mTextureUniform)
            self.mTextureUniform = nil
        }
    }
    
    internal func textureUniformSize() -> Int {
        return 0
    }
    
    /**
     通过指定的shader的文件路径编译shader
     
     - parameter shader:     shader引用
     - parameter type:       要创建的shader的类型
     - parameter sourcePath: 程序源文件路径
     
     - returns: 返回编译后状态
     */
    internal func compileShader( shader: inout GLuint,type:GLenum, sourcePath:String) -> Bool{
        // http://www.jianshu.com/p/4a92da54fba6
        do {
            let sourceData:NSData = try NSData(contentsOfFile: sourcePath)
            //获取长度
            var dataSize: GLint = GLint(sourceData.length)
            //创建Byte数组和各项指针
            let dataBytes = UnsafeMutableRawPointer.allocate(bytes: Int(dataSize), alignedTo: 0)
            var sourcePtr = unsafeBitCast(dataBytes, to: UnsafePointer<GLchar>.self)
            var sourcePtrPtr: UnsafePointer<UnsafePointer<GLchar>?>!
            withUnsafePointer(to: &sourcePtr, { ptr in
                sourcePtrPtr = unsafeBitCast(ptr, to: UnsafePointer<UnsafePointer<GLchar>?>.self)
            })
            //填充
            sourceData.getBytes(dataBytes, range: NSRange.init(location: 0, length: Int(dataSize)))
            shader = glCreateShader(type)
            glShaderSource(shader, GLsizei(1), sourcePtrPtr, dataSize.pointer)
            free(dataBytes)
            
            glCompileShader(shader)
        } catch let error as NSError {
            print("compile error: \(error)")
        }
        
        return obtainShaderStatus(shader: shader) == GL_TRUE
    }
    
    /**
     通过shander的内容来编译shader程序
     
     - parameter shader: shader句柄引用
     - parameter type:   类型
     - parameter source: shader源文件内容
     
     - returns: shader编译状态
     */
    internal func compileShader( shader: inout GLuint,type:GLenum, source:String) -> Bool{
        var cStringSource = (source as NSString).utf8String
        shader = glCreateShader(type)
        
        glShaderSource(shader, GLsizei(1), &cStringSource, nil)
        
        glCompileShader(shader)
        
        return obtainShaderStatus(shader: shader) == GL_TRUE
    }
    
    private func obtainShaderStatus(shader:GLuint) -> GLint{
        var status: GLint = 0
        glGetShaderiv(shader, GLenum(GL_COMPILE_STATUS), &status)
        
        if status == 0 {
            var infolen: GLsizei = 0
            let stringLen: GLsizei = 1024
            glGetShaderiv(shader, GLenum(GL_INFO_LOG_LENGTH), &infolen)
            
            let info: [GLchar] = Array(repeating: GLchar(0), count: Int(stringLen))
            var lenActual: GLsizei = 0
            
            glGetShaderInfoLog(shader, stringLen, &lenActual, UnsafeMutablePointer(mutating: info))
            print("info ====> \(String(describing: info))")
        }
        return status
    }
    
    internal func createAndLinkProgram(vShader:GLuint, fragShader:GLuint, attrs:Array<String>?) -> GLuint{
        var program:GLuint = glCreateProgram()
        if program != 0 {
            glAttachShader(program, vShader)
            glAttachShader(program, fragShader)
            if attrs != nil {
                let count:Int = (attrs?.count)!
                for i in 0..<count {
                    let cAttr = NSString(string: (attrs?[i])!).utf8String
                    glBindAttribLocation(program, GLuint(i), UnsafePointer(cAttr))
                }
                
                var status:GLint = 0
                glLinkProgram(program)
                // glValidateProgram(program)
                glGetProgramiv(program, GLenum(GL_LINK_STATUS), &status)
                if status == GL_FALSE {
                    if vShader != 0 {
                        glDeleteShader(vShader)
                    }
                    
                    if fragShader != 0 {
                        glDeleteShader(fragShader)
                    }
                    program = 0
                }
            }
        }
        assert(program != 0)
        return program
    }
}


extension GLint {
    var pointer: UnsafeMutablePointer<GLint> {
        mutating get {
            var pointer: UnsafeMutablePointer<GLint>!
            withUnsafeMutablePointer(to: &self, { ptr in
                pointer = ptr
            })
            return pointer
        }
    }
}
