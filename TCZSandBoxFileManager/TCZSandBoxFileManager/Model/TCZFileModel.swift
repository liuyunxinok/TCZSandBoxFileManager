//
//  TCZFileModel.swift
//  TCZSandBoxFileManager
//
//  Created by liuyunxin on 2017/8/18.
//  Copyright © 2017年 liuyunxin. All rights reserved.
//

import UIKit

class TCZFileModel {

    var path: String?
    var type: FileType = .error
    var size: String?
    var name: String?
    var isDir: String?
    var isSelect: Bool = false
    
    var cellImageName : String  {
        get{
            if Bool(self.isDir ?? "")! {
                return "large_file"
            }
            var imageName = ""

            switch self.type {
            case .html:
                imageName = "mc_link"
                break
            case .image:
                imageName = "large_pic"
                break
            case .pdf:
                imageName = "large_pdf"
                break
            case .ppt:
                imageName = "large_ppt"
                break
            case .text:
                imageName = "large_text"
                break
            case .wav:
                imageName = "large_music"
                break
            case .word:
                imageName = "large_word"
                break
            case .excel:
                imageName = "large_xls"
                break
            case .zip:
                imageName = "large_zip-rar"
                break
            case .mp3:
                imageName = "large_music"
                break
            case .mp4:
                imageName = "large_ai"
                break
            default:
                imageName = "large_unknown"
                break
            }
            
            return imageName
        }
    }
    
}
