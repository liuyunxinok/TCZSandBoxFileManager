//
//  TCZFileManager.swift
//  TCZSandBoxFileManager
//
//  Created by liuyunxin on 2017/8/17.
//  Copyright © 2017年 liuyunxin. All rights reserved.
//

import UIKit

public enum FileType {
    case text
    case image
    case word
    case excel
    case pdf
    case html
    case wav
    case zip
    case ppt
    case mp3
    case mp4
    case error
}

let file_manger = FileManager.default

class TCZFileManager {
    
    //1，获取home目录路径
    let homeDir: String = NSHomeDirectory()
    //2，获取Documents目录路径
    let documentsPaths: [String] = NSSearchPathForDirectoriesInDomains(.documentDirectory, .allDomainsMask, true)
    //3.获取Library
    let libraryPaths: [String] = NSSearchPathForDirectoriesInDomains(.allLibrariesDirectory, .allDomainsMask, true)
    //5，获取Caches目录路经
    let cachesPaths: [String] = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .allDomainsMask, true)
    //5,获取prefrence目录
    let prefrencePaths: [String] = NSSearchPathForDirectoriesInDomains(.preferencePanesDirectory, .allDomainsMask, true)
    //6，获取tmp目录路径
    let tmpDirPath: String = NSTemporaryDirectory()
    
    //文件类型
    var fileType:FileType?
    
    //是否是自己随便玩(可以添加和删除文件)
    var isDug:Bool = true
    
    //单例
    static let shared = TCZFileManager()
    private init(){}
    
    
    
    
    /// 根据路径获取文件目录下所有文件路径
    ///
    /// - Parameter path: 目录路径
    /// - Returns: 目录下的所有文件路径
    func getAllFilePath(_ dirPath: String) -> [String]? {
        var filePaths = [String]()
        
        do {
            let array = try file_manger.contentsOfDirectory(atPath: dirPath)
            
            for fileName in array {
                var isDir: ObjCBool = true
                
                let fullPath = "\(dirPath)/\(fileName)"
                
                if FileManager.default.fileExists(atPath: fullPath, isDirectory: &isDir) {
                    //                    if !isDir.boolValue {
                    filePaths.append(fullPath)
                    //                    }
                }
            }
            
        } catch let error as NSError {
            print("get file path error: \(error)")
        }
        
        return filePaths;
    }
    
    
    
    /// 获取文件或者目录的大小
    ///
    /// - Parameter path: 文件路径
    /// - Returns: 文件size
    class func getFileSize(path: String) -> (UInt64,Bool)  {
        var size: UInt64 = 0
        var isDir: ObjCBool = false
        let isExists = file_manger.fileExists(atPath: path, isDirectory: &isDir)
        // 判断文件存在
        if isExists {
            // 是否为文件夹
            if isDir.boolValue {
                // 迭代器 存放文件夹下的所有文件名
                let enumerator = file_manger.enumerator(atPath: path)
                for subPath in enumerator! {
                    // 获得全路径
                    let fullPath = path.appending("/\(subPath)")
                    do {
                        let attr = try file_manger.attributesOfItem(atPath: fullPath)
                        size += attr[FileAttributeKey.size] as! UInt64
                    } catch  {
                        print("error :\(error)")
                    }
                }
            } else {    // 单文件
                do {
                    let attr = try file_manger.attributesOfItem(atPath: path)
                    size += attr[FileAttributeKey.size] as! UInt64
                    
                } catch  {
                    print("error :\(error)")
                }
            }
        }
        return (size,isDir.boolValue)
    }
    
    
    
    /// 读取文件
    ///
    /// - Parameter filePath: 文件路径
    /// - Returns: 文件数据
    class func readFileContent(filePath: String) -> Data? {
        return file_manger.contents(atPath:filePath)
    }
    
    
    /// 获取文件属性
    ///
    /// - Parameter filePath: 文件路径
    /// - Returns: 文件属性结果数组
    class func fileAttributes(filePath: String) -> [[String:Any]] {
        var fileAttributes: [FileAttributeKey:Any] = [:]
        do {
            fileAttributes = try file_manger.attributesOfItem(atPath: filePath)
        }
        catch{
            print(error.localizedDescription)
        }
        var resultArray: [[String:Any]] = []
        for key in fileAttributes.keys {
            var dic: [String:Any] = [:]
            let value = fileAttributes[key]
            dic.updateValue(value ?? "", forKey: key.rawValue)
            resultArray.append(dic)
        }
        return resultArray
    }
    
    
    /// 创建文件夹/目录(返回创建结果)
    ///
    /// - Parameter dirName: 文件夹名称
    /// - Returns: 创建结果
    func creatDir(dirName: String, currentPath: String) {
        let path = String.init(format: "%@/%@", currentPath,dirName)
        var isDir: ObjCBool = false
        if !file_manger.fileExists(atPath: path, isDirectory: &isDir) {
            do{
                try file_manger.createDirectory(at: URL(fileURLWithPath: path), withIntermediateDirectories: true, attributes: nil)
                print("文件夹创建成功")
            }
            catch{
                print("文件夹创建失败error:%@",error.localizedDescription)
            }
        }else{
            print("创建文件夹:已存在")
        }
    }
    
    /// 创建文件返回结果
    ///
    /// - Parameters:
    ///   - path: 要创建的文件所在的上级目录
    ///   - fileName: 文件名称
    ///   - fileData: 文件数据 可选
    /// - Returns: 创建结果
    func createFile(path: String, fileName: String, fileData: Data?) {
        let filePath = String(format: "%@/%@", path,fileName)
        if file_manger.fileExists(atPath: filePath) {
            print("文件已存在")
            return
        }
        guard (fileData != nil) else {
            print("创建文件:",file_manger.createFile(atPath: filePath, contents: nil, attributes: nil) ? "成功" : "失败")
            return
        }
        print("创建文件:", file_manger.createFile(atPath: filePath, contents: fileData, attributes: nil) ? "success" : "faild")
    }
    
    //删除文件
    func deleteFile(filePath: String) -> Bool {
        
        if file_manger.fileExists(atPath: filePath) {
            if file_manger.isDeletableFile(atPath: filePath) {
                do {
                    try file_manger.removeItem(atPath: filePath)
                    print("%@---移除成功",TCZFileManager.getFileNameByPath(filePath: filePath))
                    return true
                }
                catch {
                    print("移除失败:%@",error.localizedDescription)
                    return false
                }
            }else{
                print("没有权限")
                return false
            }
        }else{
            print("文件不存在")
            return false
        }
    }
    
    
    
    /// 写入数据到文件
    ///
    /// - Parameters:
    ///   - path: 文件路径
    ///   - data: 数据
    func writeFile(path: String, data: Data) {
        do{
            try data.write(to: URL(fileURLWithPath: path))
        }
        catch{
            print("写入失败---%@",error.localizedDescription)
        }
    }
    
    /// 根据文件路径获取文件名称
    ///
    /// - Parameter filePath: 文件路径
    /// - Returns: 文件名称
    class func getFileNameByPath(filePath: String) -> String {
        
        let array = filePath.components(separatedBy: "/")
        guard array.count == 0 else {
            return array.last ?? ""
        }
        return filePath
    }
    
    
    /// 获取路径下的文件夹名称和文件夹大小
    ///
    /// - Parameter path: 文件夹路径
    /// - Returns: 数组结果
    func getDirNameAndSize(path: String) -> [TCZFileModel] {
        let filePaths = self.getAllFilePath(path)
        var result:[TCZFileModel] = []
        guard let aFilePaths = filePaths else {
            return result
        }
        for aPath in aFilePaths {
            let fileModel = TCZFileModel()
            let fileName = TCZFileManager.getFileNameByPath(filePath: aPath)
            let fileSizeAndIsDir = TCZFileManager.getFileSize(path: aPath)
            fileModel.name = fileName
            fileModel.size = self.convertFileSizeToKBMB(fileSize: fileSizeAndIsDir.0)
            fileModel.isDir = fileSizeAndIsDir.1.description
            fileModel.path = aPath
            if let fileData = TCZFileManager.readFileContent(filePath: aPath) {
                fileModel.type = self.getFileType(fileData:fileData, filePath: aPath)
            }else{
                fileModel.type = .error
            }
            result.append(fileModel)
        }
        return result
    }
    
    /// 根据文件名获取资源文件路径
    ///
    /// - Parameter fileName: 文件名称
    /// - Returns: 文件资源路径
    class func getResourcesFilePath(fileName: String) -> String? {
        return Bundle.main.path(forResource: fileName, ofType: nil)
    }
    
    
    /// 根据文件名获取文件路径
    ///
    /// - Parameter fileName: 文件名称
    /// - Returns: 在Documents下的路径
    func getLocalFilePath(fileName: String,currentPath: String) -> String? {
        if file_manger.fileExists(atPath: currentPath){
            return String(format: "%@/%@", currentPath,fileName)
        }else{
            print("curentPath不存在,在Document中创建文件")
            return String(format: "%@/%@", self.documentsPaths.first ?? "",fileName)
        }
    }
    
    
    //保存图片
    func saveImageDocuments(image: UIImage, saveName: String) -> Void {
        //设置存储路径
        let savePath = self.documentsPaths.first?.appending("/\(saveName)")
        do {
            try UIImagePNGRepresentation(image)?.write(to: URL(fileURLWithPath: savePath ?? ""))
        }
        catch{
            print("保存图片失败:%@",error.localizedDescription)
        }
    }
    
}

extension TCZFileManager {
    
    /*
     255044 PDF
     526563 EML
     D0CF11 PPT
     4D5AEE COM
     E93B03 COM
     4D5A90 EXE
     424D3E BMP
     49492A TIF
     384250 PSD
     C5D0D3 EPS
     0A0501 PCS
     89504E PNG
     060500 RAW
     000002 TGA
     60EA27 ARJ
     526172 RAR
     504B03 ZIP
     495363 CAB
     1F9D8C Z
     524946 WAV
     435753 SWF
     3026B2 WMV
     3026B2 WMA
     2E524D RM
     00000F MOV
     000077 MOV
     000001 MPA
     FFFB50 MP3
     234558 m3u
     3C2144 HTM
     FFFE3C XSL
     3C3F78 XML
     3C3F78 MSC
     4C0000 LNK
     495453 CHM
     805343 scm
     D0CF11 XLS
     31BE00 WRI
     00FFFF MDF
     4D4544 MDS
     5B436C CCD
     00FFFF IMG
     FFFFFF SUB
     17A150 PCB
     2A5052 ECO
     526563 PPC
     000100 DDB
     42494C LDB
     2A7665 SCH
     2A2420 LIB
     434841 FNT
     7B5C72 RTF
     7B5072 GTD
     234445 PRG
     000007 PJT
     202020 BAS
     000002 TAG
     4D5A90 dll
     4D5A90 OCX
     4D5A50 DPL
     3F5F03 HLP
     4D5A90 OLB
     4D5A90 IMM
     4D5A90 IME
     3F5F03 LHP
     C22020 NLS
     5B5769 CPX
     4D5A16 DRV
     5B4144 PBK
     24536F PLL
     4E4553 NES
     87F53E GBC
     00FFFF SMD
     584245 XBE
     005001 XMV
     000100 TTF
     484802 PDG
     000100 TST
     414331 dwg
     D0CF11 max
     
     另外还有一些重要的文件，没有固定的文件头，如下：
     TXT没固定文件头定义
     TMP没固定文件头定义
     INI没固定文件头定义
     BIN没固定文件头定义
     DBF没固定文件头定义
     C没没固定文件头定义
     CPP没固定文件头定义
     H没固定文件头定义
     BAT没固定文件头定义
     
     如果有些无法恢复的，很可能就是以上这些文件。
     还有一些不同的文件有相同的文件头，最典型的就是下面：
     4D5A90 EXE
     4D5A90 dll
     4D5A90 OCX
     4D5A90 OLB
     4D5A90 IMM
     4D5A90 IME
     */
    
    
    /// 获取文件类型
    ///
    /// - Parameter fileData: 文件数据
    /// - Returns: 文件类型
    func getFileType(fileData: Data,filePath: String) -> FileType {
        guard !fileData.isEmpty else {
            return .error
        }
        var resultType: FileType = .error
        
        let bytes = fileData.withUnsafeBytes {
            [UInt8](UnsafeBufferPointer(start: $0, count: 3))
        }
        
        let hexStr = self.hexStringFromBytes(bytes: bytes)
        
        print(hexStr)
        
        switch hexStr {
        case "ffd8ff":
            resultType = .image
            break
        case "89504e":
            resultType = .image
            break
        case "47494638":
            resultType = .image
            break
        case "7b5c727466":
            resultType = .text
            break
        case "d0cf11":
            let fileExtensionName = self.getFileExtensionName(filePath: filePath)
            if fileExtensionName == "docx" || fileExtensionName == "doc" {
                resultType = .word
            }else if fileExtensionName == "xls" || fileExtensionName == "xlsx" {
                resultType = .excel
            }
            break
        case "3c2144":
            resultType = .html
            break
        case "255044":
            resultType = .pdf
            break
        case "524946":
            resultType = .wav
            break
        case "504b03":
            resultType = .zip
            break
        case "d0cf11":
            resultType = .ppt
            break
        case "fffb50":
            resultType = .mp3
            break
        case "000000":
            resultType = .mp4
            break
        default:
            resultType = .error
            break
        }
        
        return resultType
    }
    
    /// 获取十六进制字符串
    ///
    /// - Parameter bytes: fileData文件头
    /// - Returns: 字符串
    func hexStringFromBytes(bytes: [UInt8]) -> String {
        var hexStr: String = ""
        for byte in bytes {
            let newHexStr = String(format: "%x", byte&0xff)
            if newHexStr.lengthOfBytes(using: .utf8) == 1 {
                hexStr = String(format: "%@0%@", hexStr,newHexStr)
            }else{
                hexStr = String(format: "%@%@", hexStr,newHexStr)
            }
        }
        return hexStr
    }
    
    
    /// 获取文件的扩展名
    ///
    /// - Parameter filePath: 文件路径
    /// - Returns:文件扩展名
    func getFileExtensionName(filePath: String) -> String {
        return URL(fileURLWithPath: filePath).pathExtension
    }

    
    /// 把fileSize转换成KB,MB,GB
    ///
    /// - Parameter fileSize: 文件size
    /// - Returns: 结果String
    func convertFileSizeToKBMB(fileSize: UInt64) -> String {
        if fileSize == 0{
        return "0KB"
        }
        let KBSize = Double(fileSize) / 1024.0
        var MBSize: Double = 0.0,GBSize: Double = 0.0
        if KBSize >= 1024 {
            MBSize = KBSize / 1024.0
            if MBSize >= 1024.0 {
                GBSize = MBSize / 1024.0
                return String(format: "%.2fGB", GBSize)
            }else{
                return String(format: "%.2fMB", MBSize)
            }
        }else{
            return String(format: "%.2fKB", KBSize)
        }
    }
    
}

