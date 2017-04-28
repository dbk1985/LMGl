//
//  LMGlobal.swift
//  LMVr
//
//  Created by wzkj on 2017/4/14.
//  Copyright © 2017年 justbehere. All rights reserved.
//

import OpenGLES

public func lmGLCheck(msg:String) -> Void {
    var error:GLenum = glGetError()
    while error != GLenum(GL_NO_ERROR) {
        var desc:String? = nil
        switch error {
        case GLenum(GL_INVALID_OPERATION): desc = "INVALID_OPERATION"; break
        case GLenum(GL_INVALID_ENUM): desc = "INVALID_ENUM"; break
        case GLenum(GL_INVALID_VALUE): desc = "INVALID_VALUE"; break
        case GLenum(GL_OUT_OF_MEMORY): desc = "OUT_OF_MEMORY"; break
        case GLenum(GL_INVALID_FRAMEBUFFER_OPERATION): desc = "INVALID_FRAMEBUFFER_OPERATION"; break
        default:
            break
        }
        error = glGetError()
        print("************ glError:\(msg) *** \(desc)")
    }
}

public func readRawText(filePath:String) -> String{
    var content:String?;
    do {
        content = try String(contentsOfFile: filePath, encoding: String.Encoding.utf8)
    } catch {
        print("读取文件中的内容")
    }
    
    return content!;
}
