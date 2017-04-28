//
//  LMGLSphereProjection.swift
//  LMVr
//
//  Created by wzkj on 2017/4/17.
//  Copyright © 2017年 justbehere. All rights reserved.
//

import Foundation

/** 球形投影 */
public class  LMGLSphereProjection : NSObject,LMGLProjectionProtocol{
    public var objectModel: LMGLObjectModelProtocol?
    
    public func projectDidLoad() {
        // 加载模型
        self.objectModel = LMGLSphereModel()
    }
    
    public func createDirector(index: Int) -> LMGLDirector {
        let director : LMGLDirector =  LMGLDirector()
        if 1 == index {
            
        }
        return director
    }
}
