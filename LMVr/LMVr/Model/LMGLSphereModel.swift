//
//  LMGLSphereModel.swift
//  LMVr
//
//  Created by wzkj on 2017/4/17.
//  Copyright © 2017年 justbehere. All rights reserved.
//

import Foundation

class LMGLSphereModel: LMGLObjectModel,LMGLObjectModelProtocol{
    /** 生成对象模型 */
    public func generateModel() {
        generateSphere(radius: 18, numSlices: 128)
    }
    
    let ES_PI:Float = 3.14159265
    /**
     球型模型
     
     - parameter radius:    半径
     - parameter numSlices: 垂直切片数量
     
     - returns: 切片数量
     */
    private func generateSphere (radius:Float, numSlices:Int) -> Void {
        // 平行线数量
        let numParallels:Int = numSlices / 2
        let numVertices:Int = ( numParallels + 1 ) * ( numSlices + 1 )
        let numIndices:Int = numParallels * numSlices * 6
        let angleStep:Float = (2.0 * ES_PI) / Float(numSlices)
        
        let vertices:UnsafeMutableRawPointer? = malloc (MemoryLayout<Float>.size * 3 * numVertices)
        let texCoords:UnsafeMutableRawPointer? = malloc (MemoryLayout<Float>.size * 2 * numVertices)
        let indices:UnsafeMutableRawPointer? = malloc (MemoryLayout<CShort>.size * numIndices)
        
        for i:Int in 0...Int(numParallels) {
            for j:Int in 0...Int(numSlices){
                let vertex:Int = (i * (numSlices + 1) + j ) * 3;
                
                if vertices != nil {
                    vertices?.storeBytes(of: -radius * sinf(angleStep * Float(i)) * sinf(angleStep * Float(j)), toByteOffset:vertex * MemoryLayout<Float>.size, as: Float.self)
                    vertices?.storeBytes(of: radius * sinf(ES_PI/2 + angleStep * Float(i)), toByteOffset: (vertex + 1) * MemoryLayout<Float>.size, as: Float.self)
                    vertices?.storeBytes(of: radius * sinf(angleStep * Float(i)) * cosf(angleStep * Float(j)), toByteOffset: (vertex + 2) * MemoryLayout<Float>.size, as: Float.self)
                }
                
                if texCoords != nil {
                    let texIndex:Int = (i * (numSlices + 1) + j) * 2;
                    texCoords?.storeBytes(of: Float(j)/Float(numSlices), toByteOffset: texIndex * MemoryLayout<Float>.size, as: Float.self)
                    texCoords?.storeBytes(of: (Float(i)/Float(numParallels)), toByteOffset: (texIndex + 1) * MemoryLayout<Float>.size, as: Float.self)
                }
            }
        }
        
        // Generate the indices
        if  indices != nil {
            let indexBuf:UnsafeMutableRawPointer = indices!;
            for i in 0...numParallels-1 {
                for j in 0...numSlices-1 {
                    indexBuf.storeBytes(of: CShort(i * (numSlices + 1 ) + j), toByteOffset:(i*numParallels + j) * MemoryLayout<CShort>.size, as: CShort.self)   //a
                    indexBuf.storeBytes(of: CShort(), toByteOffset:(i*numParallels + j + 1) * MemoryLayout<CShort>.size, as: CShort.self)   //b
                }
            }
        }
        
        
        free(indices);
        free(texCoords);
        free(vertices);
    }
}
