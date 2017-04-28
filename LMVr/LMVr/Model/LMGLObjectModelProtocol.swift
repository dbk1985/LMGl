//
//  LMGLObjectModelProtocol.swift
//  LMVr
//
//  Created by wzkj on 2017/4/17.
//  Copyright © 2017年 justbehere. All rights reserved.
//

import Foundation

@objc public protocol LMGLObjectModelProtocol{
    /** 代码生成对象模型 */
    @objc optional func generateModel()
    /** 提供一个生成数据模型的文件对象 eg： obj模型文件 */
    @objc optional func provideModelFilePath() -> String?
}
