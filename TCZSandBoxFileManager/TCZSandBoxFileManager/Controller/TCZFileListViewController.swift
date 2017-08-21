//
//  TCZFileListViewController.swift
//  TCZSandBoxFileManager
//
//  Created by liuyunxin on 2017/8/17.
//  Copyright © 2017年 liuyunxin. All rights reserved.
//

import UIKit

let WINDOW_WIDTH = UIScreen.main.bounds.width
let WINDOW_HEIGHT = UIScreen.main.bounds.height

class TCZFileListViewController: UIViewController {
    
    var dataSource: [TCZFileModel] = []
    
    var selectFile: [TCZFileModel] = []
    
    let fileManager = TCZFileManager.shared
    
    var filePath:String = TCZFileManager.shared.homeDir
    
    var isStartFileEditing: Bool = false
    
    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: WINDOW_WIDTH / 4, height: WINDOW_WIDTH / 4 + 6)
        layout.minimumLineSpacing = 5
        layout.minimumInteritemSpacing = 5
        let view = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        view.register(TCZFileListCell.classForCoder(), forCellWithReuseIdentifier: NSStringFromClass(TCZFileListCell.classForCoder()))
        view.delegate = self
        view.dataSource = self
        view.backgroundColor = .white
        return view
    }()
    
    lazy var addFileButton: UIButton = {
        let button = UIButton(frame: CGRect.zero)
        button.setBackgroundImage(UIImage(named:  "buttonBg"), for: .normal)
        button.setTitle("添加测试文件", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.addTarget(self, action: #selector(TCZFileListViewController.addTestFile), for: .touchUpInside)
        return button
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        self.addNavRightItem()
        self.view.addSubview(self.addFileButton)
        self.view.addSubview(self.collectionView)
        //是否可以编辑文件
        if self.fileManager.isDug {
            //隐藏添加和编辑按钮 因为没有权限操作此目录
            if self.filePath == self.fileManager.homeDir {
                self.addFileButton.frame = CGRect(x: 13, y: 13, width: WINDOW_WIDTH - 26, height: 0)
                self.collectionView.frame = CGRect(x: 0, y: 64 + 13, width: WINDOW_WIDTH, height: self.view.bounds.height - 64 - 13)
                self.navigationItem.rightBarButtonItem = nil
            }else{
                self.addFileButton.frame = CGRect(x: 13, y: 64 + 13, width: WINDOW_WIDTH - 26, height: 50)
                self.collectionView.frame = CGRect(x: 0, y: 64 + 76, width: WINDOW_WIDTH - 26, height: self.view.bounds.height - 64 - 76)
                self.addNavRightItem()
            }
        }else{
            self.addFileButton.frame = CGRect(x: 13, y: 13, width: WINDOW_WIDTH - 26, height: 0)
            self.collectionView.frame = CGRect(x: 0, y: 64 + 13, width: WINDOW_WIDTH, height: self.view.bounds.height - 64 - 13)
            self.navigationItem.rightBarButtonItem = nil
        }
        //加载bundle文件
        self.loadFileAttribute()
        
    }
    
    func addNavRightItem() -> Void {
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "编辑", style: .plain, target: self, action: #selector(TCZFileListViewController.editFile))
    }
    
    func loadFileAttribute() -> Void {
        self.dataSource = self.fileManager.getDirNameAndSize(path: self.filePath)
        self.collectionView.reloadData()
    }
    
    func editFile() -> Void {
        switch self.navigationItem.rightBarButtonItem?.title ?? "" {
        case "编辑":
            self.navigationItem.rightBarButtonItem?.title = "取消"
            self.isStartFileEditing = true
            break
        case "取消":
            self.selectFile.removeAll()
            for fileModel in self.dataSource {
                fileModel.isSelect = false
            }
            self.navigationItem.rightBarButtonItem?.title = "编辑"
            self.isStartFileEditing = false
            break
        default:
            //删除
            self.deleteMoreFile()
            
            break
        }
        self.collectionView.reloadData()
    }
    
    
}

extension TCZFileListViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.dataSource.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: TCZFileListCell = collectionView.dequeueReusableCell(withReuseIdentifier: NSStringFromClass(TCZFileListCell.classForCoder()), for: indexPath) as! TCZFileListCell
        cell.fileModel = self.dataSource[indexPath.item]
        cell.isEditing = self.isStartFileEditing
        cell.fileCellDelegate = self
        return cell
    }
}

extension TCZFileListViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if self.isStartFileEditing {
            let cell: TCZFileListCell = collectionView.cellForItem(at: indexPath) as! TCZFileListCell
            cell.fileModel?.isSelect = !(cell.fileModel?.isSelect)!
            self.collectionView.reloadItems(at: [indexPath])
            self.updateRightItemTitle()
            return
        }
        
        let fileModel = self.dataSource[indexPath.item]
        let filePath = fileModel.path
        let fileName = fileModel.name ?? ""
        switch fileName {
        case "Documents":
            self.jumpNextVC(filePath: self.fileManager.documentsPaths.first ?? "",title: fileName)
            break
        case "Library":
            self.jumpNextVC(filePath: self.fileManager.libraryPaths.first ?? "",title: fileName)
            break
        case "tmp":
            self.jumpNextVC(filePath: self.fileManager.tmpDirPath,title: fileName)
            break
        case "Caches":
            self.jumpNextVC(filePath: self.fileManager.cachesPaths.first ?? "", title: fileName)
            break
        case "Preferences":
            self.jumpNextVC(filePath: self.fileManager.prefrencePaths.first ?? "", title: fileName)
            break
        default:
            if Bool(fileModel.isDir ?? "")! {
                self.jumpNextVC(filePath: filePath ?? "", title: fileName)
            }else{
                //预览文件
                self.jumpFilePreviewVC(filePath: filePath ?? "")
            }
            break
        }
    }
    
    //展示下级文件列表
    func jumpNextVC(filePath: String,title: String) -> Void {
        let nextVC = TCZFileListViewController()
        nextVC.filePath = filePath
        nextVC.title = title
        nextVC.view.backgroundColor = .white
        self.navigationController?.pushViewController(nextVC, animated: true)
    }
    
    func jumpFilePreviewVC(filePath: String) -> Void {
        //跳转预览页面
        let filePreviewVC = TCZFilePreviewViewController()
        filePreviewVC.filePath = filePath
        self.navigationController?.pushViewController(filePreviewVC, animated: true)
    }
    
    func updateRightItemTitle() -> Void {
        self.selectFile.removeAll()
        for fileModel in self.dataSource {
            if fileModel.isSelect {
                self.selectFile.append(fileModel)
            }
        }
        if self.selectFile.count > 0 {
            self.navigationItem.rightBarButtonItem?.title = String(format: "删除(%d)", self.selectFile.count)
        }else{
            self.navigationItem.rightBarButtonItem?.title = String(format: "取消", self.selectFile.count)
        }
    }
    
    
}

extension TCZFileListViewController: TCZFileListCellDelegate {
    
    func fileListCellDidSelctButton(cell: TCZFileListCell) {
        cell.fileModel?.isSelect = cell.selectedButton.isSelected
        self.updateRightItemTitle()
    }
}


//MARK:添加测试文件和删除
extension TCZFileListViewController {
    
    func deleteFile(filePath: String) -> Bool {
      return self.fileManager.deleteFile(filePath: filePath)
    }
    func deleteMoreFile() -> Void {
        var tmpArray: [TCZFileModel] = []
        for fileModel in self.dataSource {
            if fileModel.isSelect {
              let isSuccess = self.deleteFile(filePath: fileModel.path ?? "")
                if !isSuccess {
                    tmpArray.append(fileModel)
                }
            }else{
                tmpArray.append(fileModel)
            }
        }
        self.dataSource = tmpArray
        self.collectionView.reloadData()
        self.updateRightItemTitle()
    }
    
    
    func addTestFile() -> Void {
        let dirFileName =  String(format:"test%@文件夹", self.getRandomDirName())
        self.fileManager.creatDir(dirName: dirFileName, currentPath: self.filePath)
        let testPath = self.fileManager.getLocalFilePath(fileName: dirFileName,currentPath: self.filePath) ?? ""
        //图片
        let data = UIImagePNGRepresentation(UIImage(named: "Alert")!)
        self.fileManager.createFile(path: testPath, fileName: "图片.png", fileData: data)
        //pdf
        let pdfData = FileManager.default.contents(atPath: Bundle.main.path(forResource: "Swift3.0中文版文档.pdf", ofType:nil) ?? "")
        self.fileManager.createFile(path: testPath, fileName: "PDF.pdf", fileData: pdfData)
        //zip
        let zipData = FileManager.default.contents(atPath: Bundle.main.path(forResource: "android翻译.zip", ofType:nil) ?? "")
        self.fileManager.createFile(path: testPath, fileName: "压缩.zip", fileData: zipData)
        //mp4
        let mp4Data = FileManager.default.contents(atPath: Bundle.main.path(forResource: "QQ20170810-152534-HD.mp4", ofType:nil) ?? "")
        self.fileManager.createFile(path: testPath, fileName: "视频.mp4", fileData: mp4Data)
        //excel
        let excelData = FileManager.default.contents(atPath: Bundle.main.path(forResource: "android_strings_excel.xlsx", ofType:nil) ?? "")
        self.fileManager.createFile(path: testPath, fileName: "表格.xlsx", fileData: excelData)
        //doc
        let docData = FileManager.default.contents(atPath: Bundle.main.path(forResource: "规则文字.docx", ofType:nil) ?? "")
        self.fileManager.createFile(path: testPath, fileName: "文档.docx", fileData: docData)
        
        //更新
        self.loadFileAttribute()
        
    }
    
    func getRandomDirName() -> String {
        let randomNum = arc4random()
        return String(format: "%d", randomNum)
    }
    
}



