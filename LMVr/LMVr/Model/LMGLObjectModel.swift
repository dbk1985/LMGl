//
//  LMGLObjectModel.swift
//  LMVr
//
//  Created by wzkj on 2017/4/10.
//  Copyright © 2017年 justbehere. All rights reserved.
//

import UIKit

/**
 *  模型对象，产生模型对象的顶点缓冲、贴图缓冲
 
 每一个 C 语言基本类型， Swift 都提供了与之对应的类型。在 Swift 中调用 C 方法的时候，会用到这些类型：
 C 类型                          Swift对应类型                    别名
 bool                           CBool                           Bool
 char,unsigned char             CChar, CUnsignedChar            Int8, UInt8
 short, unsigned short          CShort, CUnsignedShort          Int16, UInt16
 int, unsigned int              CInt, CUnsignedInt              Int32, UInt32
 long, unsigned long            CLong, CUnsignedLong            Int, UInt
 long long, unsigned long long	CLongLong, CUnsignedLongLong	Int64, UInt64
 wchar_t, char16_t, char32_t	CWideChar, CChar16, CChar32     UnicodeScalar, UInt16, UnicodeScalar
 float, double                  CFloat, CDouble                 Float, Double
 官方文档中对上面表格也有介绍，展示了 Swift 类型和对应的 C 别名。
 
 */
var sPositionDataSize:Int = 3

@objc class LMGLObjectModel: NSObject {
    /** 顶点数据是否已经改变 */
    internal var mVerticesChanged:Bool = false
    internal var mTexCoordinateChanged:Bool = false
    
    /** 顶点数量 */
    private var mVertexSize:CInt?
    /** 贴图数量 */
    private var mTextureSize:CInt?
    private var mVertexBuffer:UnsafeMutableRawPointer?
    private var mTextureBuffer:UnsafeMutableRawPointer?
    private var mIndicesBuffer:UnsafeMutableRawPointer?
    
    public var numIndices:CInt?{
        get{return self.numIndices}
        set{
            self.numIndices = newValue
        }
    }
    public var indices:UnsafeMutableRawPointer?{
        get{
            return mIndicesBuffer!
        }
    }
    
    public func setVertexBuffer(vertextBuffer:UnsafeMutableRawPointer, size:Int) -> Void{
        let size_t:Int = MemoryLayout<Float>.size * size;
        mVertexBuffer = malloc(size_t)
        memcpy(mVertexBuffer, vertextBuffer, size_t)
    }
    
    public func setTextureBuffer(textureBuffer:UnsafeMutableRawPointer, size:Int) -> Void {
        let size_t:Int = MemoryLayout<Float>.size * size;
        mTextureBuffer = malloc(size_t)
        memcpy(mTextureBuffer, textureBuffer, size_t)
    }
    
    public func setIndicesBufer(indicesBuffer:UnsafeMutableRawPointer,size:Int) -> Void {
        let size_t:Int = MemoryLayout<Float>.size * size
        mIndicesBuffer = malloc(size_t)
        assert((mIndicesBuffer != nil));
        memcpy(mIndicesBuffer, indicesBuffer, size_t);
    }
    
    public func getVertexBuffer(index:Int) -> UnsafeMutableRawPointer? {
        return self.mVertexBuffer!
    }
    
    public func getTextureBuffer(index:Int) -> UnsafeMutableRawPointer? {
        return self.mTextureBuffer!
    }
    
    /** 执行来加载模型对象 */
    final public func executeLoadModel(){
        if conforms(to: LMGLObjectModelProtocol.self) {
            if(responds(to: #selector(LMGLObjectModelProtocol.provideModelFilePath))){
                let objFilePath : String? = (self as! LMGLObjectModelProtocol).provideModelFilePath!()
                if objFilePath != nil {
                    loadObjectModelFromObjFilePath(objFilePath: objFilePath!)
                }
            }
            
            if responds(to: #selector(LMGLObjectModelProtocol.generateModel)) {
                (self as! LMGLObjectModelProtocol).generateModel!()
            }
        }
    }
    
    
    public func uploadVertexBufferIfNeeded(program:LMGLProgram,index:Int){
        let pointer:UnsafeMutableRawPointer? = getVertexBuffer(index: Int(index))
        if pointer == nil {
            glDisableVertexAttribArray(program.mGLPositon)
            return
        }
        
        if mVerticesChanged {
            glEnableVertexAttribArray(program.mGLPositon)
            glVertexAttribPointer(program.mGLPositon, GLint(sPositionDataSize), GLenum(GL_FLOAT), 0, 0, pointer)
            mVerticesChanged = false
        }
    }
    
    public func uploadTextureCoordinateBufferIfNeeded(program:LMGLProgram,index:Int){
        let pointer:UnsafeMutableRawPointer? = getTextureBuffer(index: Int(index))
        if pointer == nil {
            glDisableVertexAttribArray(program.mGLTextureCoordinate)
            return
        }
        
        if mTexCoordinateChanged {
            glEnableVertexAttribArray(program.mGLTextureCoordinate)
            glVertexAttribPointer(program.mGLTextureCoordinate, 2, GLenum(GL_FLOAT), 0, 0, pointer)
            mTexCoordinateChanged = false
        }
    }
    
    /** 渲染 */
    final public func onDraw(){
        if (self.indices != nil) {
            let count:GLsizei = self.numIndices!
            glDrawElements(GLenum(GL_TRIANGLE_STRIP), count, GLenum(GL_UNSIGNED_SHORT), self.indices)
            return
        }
        glDrawArrays(GLenum(GL_TRIANGLES), 0, self.numIndices!)
    }
    
    /**
     从模型对象文件加载模型数据
     
     - parameter objFilePath: 模型文件路径
     */
    private func loadObjectModelFromObjFilePath(objFilePath:String){
        
    }
    
    deinit {
        if mVertexBuffer != nil {
            free(mVertexBuffer)
        }
        if mTextureBuffer != nil {
            free(mTextureBuffer)
        }
        
        if mIndicesBuffer != nil {
            free(mIndicesBuffer)
        }
        
        mVertexBuffer = nil
        mTextureBuffer = nil
        mIndicesBuffer = nil
    }
    
    override var description: String{
        get{
            /*var vertexSB:NSMutableString = NSMutableString()
             for  i:CInt in 0...(self.numIndices! * 3) {
             }
             */
            return ""
        }
    }
    
}
