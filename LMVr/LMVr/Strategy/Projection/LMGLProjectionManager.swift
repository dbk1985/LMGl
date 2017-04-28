//
//  LMGLProjectionManager.swift
//  LMVr
//
//  Created by wzkj on 2017/4/6.
//  Copyright © 2017年 justbehere. All rights reserved.
//

// public 库内可以访问，也可继承重写   库外要可以继承重写 得用open 不能用户public
// private 彻底私有，就算是文件内部也不能相互访问  文件内相互访问，文件外不能访问 使用fileprivate修饰
// final 只能被访问，不能被继承重写
// internal

import UIKit

public let MULTI_SCREEN_SIZE:Int = 2

enum LMGLProjectionStrategy {
    case Sphere
}


/** 
 投影变换策略管理工厂
 根据投影变换类型加载对应投影变换方案，投影变换方案结合自己类型指定或配置模型（投影模型创建）、导演（相机） 
 任务：
 1、初始化所有的投影方案
 2、根据指定的投影方案类型创建对应的投影方案
 3、创建导演对象
 */
@objc class LMGLProjectionManager : NSObject {
    /** 投影变换方案类型 */
    internal var projectionStrategy: LMGLProjectionStrategy{
        get{return self.projectionStrategy }
        set{
            if self.projectionStrategy != newValue {
                self.projectionStrategy = newValue
                createProjection()
                // 创建投影对应的模型
                if (self.projection?.responds(to: #selector(LMGLProjectionProtocol.projectDidLoad)))! {
                    self.projection?.projectDidLoad!()
                }
                
                // 创建导演
                self.directors.removeAll()
                if ((self.projection?.conforms(to: LMGLProjectionProtocol.self))! && (self.projection?.responds(to: #selector(LMGLProjectionProtocol.createDirector(index:))))!) {
                    for i in 0..<MULTI_SCREEN_SIZE {
                        let director : LMGLDirector = (self.projection?.createDirector!(index: i))!
                        self.directors.append(director)
                    }
                }
            }
        }
    }
    
    public var projection : LMGLProjectionProtocol?
    // 创建所有的投影方案
    private var strategyModes : [LMGLProjectionStrategy] = {
        let modes:[LMGLProjectionStrategy] = [.Sphere]
        return modes;
    }()
    
    /** module内可写，module外只读 */
    private(set) var directors:Array<LMGLDirector>
    /**
     构造函数
     - parameter mProjectionStrategy: 方案类型
     */
    required init(mProjectionStrategy : LMGLProjectionStrategy) {
        self.directors = Array()
        super.init()
        self.projectionStrategy = mProjectionStrategy
    }
    
    /// 创建投影方案
    private func createProjection(){
        switch self.projectionStrategy {
        case .Sphere:       //球形
            projection = LMGLSphereProjection()
            break
        }
    }
    
    
}
