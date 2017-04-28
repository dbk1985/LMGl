//
//  LMGLProjectionProtocol.swift
//  LMVr
//
//  Created by wzkj on 2017/4/17.
//  Copyright © 2017年 justbehere. All rights reserved.
//

import Foundation

/** 投影对象必须实现该协议 */
@objc public protocol LMGLProjectionProtocol : NSObjectProtocol{
    /** 保存视图模型 */
    @objc optional var objectModel: LMGLObjectModelProtocol?{
        get
    }
    @objc optional func projectDidLoad()
    @objc optional func createDirector(index:Int) -> LMGLDirector
}
