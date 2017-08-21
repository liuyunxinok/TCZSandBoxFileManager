//
//  TCZFileListCell.swift
//  TCZSandBoxFileManager
//
//  Created by liuyunxin on 2017/8/17.
//  Copyright © 2017年 liuyunxin. All rights reserved.
//

import UIKit

protocol TCZFileListCellDelegate: NSObjectProtocol{
    
    func fileListCellDidSelctButton(cell: TCZFileListCell) -> Void
}


class TCZFileListCell: UICollectionViewCell {
    
    var fileModel: TCZFileModel? {
        didSet {
            if let aFileModel = self.fileModel {
                self.imageView.image = UIImage(named: aFileModel.cellImageName)
                self.fileNameLabel.text = aFileModel.name ?? ""
                self.fileSizeLabel.text = aFileModel.size ?? "0KB"
                self.selectedButton.isSelected = aFileModel.isSelect
            }
        }
    }
    
    weak var fileCellDelegate: TCZFileListCellDelegate?
    
    lazy var bgView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        return view
    }()
    
    lazy var imageView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFill
        view.isUserInteractionEnabled = true
        return view
    }()
    
    lazy var fileNameLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .black
        return label
    }()
    
    lazy var fileSizeLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 13)
        label.textColor = .gray
        return label
    }()
    
    lazy var selectedButton: UIButton = {
        let button = UIButton(type: UIButtonType.custom)
        button.setImage(UIImage(named: "unSelectedCircle"), for: .normal)
        button.setImage(UIImage(named: "selectedPoint"), for: .selected)
        button.addTarget(self, action: #selector(selectButtonDidClick), for: .touchUpInside)
        button.isHidden = true
        return button
    }()
    
    var isEditing: Bool = false {
        didSet{
            self.selectedButton.isHidden = !self.isEditing
        }
    }
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.contentView.addSubview(self.bgView)
        self.bgView.addSubview(self.imageView)
        self.bgView.addSubview(self.fileNameLabel)
        self.bgView.addSubview(self.fileSizeLabel)
        self.bgView.addSubview(self.selectedButton)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func layoutSubviews() {
        self.bgView.frame = self.contentView.bounds
        self.imageView.frame = CGRect(x: 16, y: 0, width: self.contentView.bounds.width - 32, height: self.contentView.bounds.width - 32)
        self.fileNameLabel.frame = CGRect(x: 0, y: self.contentView.bounds.width - 32, width: self.contentView.bounds.width, height: 20)
        self.fileSizeLabel.frame = CGRect(x: 0, y: self.contentView.bounds.width - 12, width: self.contentView.bounds.width, height: 18)
        self.selectedButton.frame = CGRect(x: self.contentView.bounds.width - 16, y: 0, width: 16, height: 16)
    }
    
    func selectButtonDidClick(sender: UIButton) -> Void {
        sender.isSelected = !sender.isSelected
        if let delegate = fileCellDelegate {
            delegate.fileListCellDidSelctButton(cell: self)
        }
    }
    
}
