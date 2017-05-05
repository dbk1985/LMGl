//
//  LMFilePathUtil.swift
//  LMVr
//
//  Created by wzkj on 2017/5/2.
//  Copyright © 2017年 justbehere. All rights reserved.
//

import Foundation
import UIKit

// MARK: - 文件路径处理
extension String{
    /**
     获取文件扩展名
     
     - returns: 文件扩展名
     */
    open func lm_pathExtension() -> String {
        var pathExt:String = (self as NSString).pathExtension
        if (pathExt as NSString).isEqual(to: "gz") {
            pathExt = ((self as NSString).deletingPathExtension as NSString).pathExtension
            if (pathExt as NSString).length > 0 {
                return pathExt
            }
        }
        return pathExt
    }
    
    /**
     得到没有文件扩展名的路径
     
     - returns: 无扩展名的文件路
     */
    open func lm_stringByDeletingPathExtension() -> String {
        let pathExt:String = (self as NSString).pathExtension
        let path:String = (self as NSString).deletingPathExtension
        if (pathExt as NSString).isEqual(to: "gz") {
            return (path as NSString).deletingPathExtension
        }
        return path
    }
    
    /**
     通过文件的后缀得到屏幕缩放比例
     - returns: 缩放比例
     */
    open func lm_screenScaleFromFileSuffix() -> Float {
        /** 自定义一个属性，通过属性来得到屏幕缩放比例 */
        let selector:Selector = NSSelectorFromString("screenScaleFromFileSuffix")
        if (self as NSString).responds(to: selector) {
            return (self as NSString).value(forKey: "screenScaleFromFileSuffix")
        }
        
        var fileName:NSString = lm_stringByDeletingPathExtension() as NSString
        if fileName .hasSuffix("~ipad") {
            fileName = fileName.substring(to: fileName.length - 5)
        }
        
        if fileName.hasSuffix("~iphone") {
            fileName = fileName.substring(to: fileName.length - 7)
        }
        
        if fileName.hasSuffix("@3x") {
            return 3.0
        }
        
        if fileName.hasSuffix("@2x") {
            return 2.0
        }
        
        return 1.0
    }
    
    /**
     得到通用的路径，使用默认扩展名
     
     - parameter ext: 默认扩展名
     
     - returns: 路径
     */
    open func lm_normalizedPathWithDefalutExtension(ext:String) -> String {
        var path:NSString = self as NSString
        // 文件没有扩展名就添加上默认的扩展名
        if (path.pathExtension as NSString).length == 0 {
            path = path.appendingPathExtension(ext)
        }else{
            ext = lm_pathExtension()
        }
        //use StandardPaths if available
        let normalizedPathSelector : Selector = NSSelectorFromString("normalizedPathForFile:");
        let fileManager:FileManager = FileManager.default
        if fileManager.responds(to: normalizedPathSelector) {
            return fileManager.perform(normalizedPathSelector, with: path)
        }
        
        //convert to absolute path
        if !path.isAbsolutePath {
            path = (Bundle.main.resourcePath as NSString).appendingPathExtension(ext)
        }
        
        //check for Retina version
        if  UIScreen.main.scale == 3.0 {
            let retinaFilePath:NSString = (((path as String).lm_stringByDeletingPathExtension() as NSString).appending("@3x") as NSString).appendingPathExtension(ext)
            if fileManager.fileExists(atPath: retinaFilePath as String) {
                path = retinaFilePath
            }
        }else if UIScreen.main.scale == 2.0 {
            let retinaFilePath:NSString = (((path as String).lm_stringByDeletingPathExtension() as NSString).appending("@2x") as NSString).appendingPathExtension(ext)
            if fileManager.fileExists(atPath: retinaFilePath as String) {
                path = retinaFilePath
            }
        }
        
        //check for ~ipad or ~iphone version
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.pad){
            let retinaFilePath:NSString = (((path as String).lm_stringByDeletingPathExtension() as NSString).appending("~ipad") as NSString).appendingPathExtension(ext)
            if fileManager.fileExists(atPath: retinaFilePath as String) {
                path = retinaFilePath
            }
        }else{
            let retinaFilePath:NSString = (((path as String).lm_stringByDeletingPathExtension() as NSString).appending("~iphone") as NSString).appendingPathExtension(ext)
            if fileManager.fileExists(atPath: retinaFilePath as String) {
                path = retinaFilePath
            }
        }
        
        //default path
        return fileManager.fileExists(atPath: path as String) ? path as String : nil;
    }
}
