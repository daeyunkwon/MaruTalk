//
//  ProfileView.swift
//  MaruTalk
//
//  Created by 권대윤 on 12/2/24.
//

import UIKit

import SnapKit

final class ProfileView: BaseView {
    
    //MARK: - UI Components
    
    let profileImageSettingButton: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setImage(UIImage(named: "noPhotoA"), for: .normal)
        btn.imageView?.contentMode = .scaleAspectFill
        btn.backgroundColor = .red
        btn.clipsToBounds = true
        btn.layer.cornerRadius = 8
        btn.tintColor = .clear
        btn.contentHorizontalAlignment = .fill
        btn.contentVerticalAlignment = .fill
        return btn
    }()
    
    private let cameraIconButton: UIButton = {
        let btn = UIButton(type: .system)
        let image = UIImage(named: "Camera")?.resizeImageTo(size: CGSize(width: 14, height: 14))
        btn.setImage(image?.withRenderingMode(.alwaysOriginal), for: .normal)
        btn.backgroundColor = Constant.Color.brandColor
        btn.layer.cornerRadius = 24 / 2
        btn.clipsToBounds = true
        btn.layer.borderColor = Constant.Color.brandWhite.cgColor
        btn.layer.borderWidth = 3
        btn.isUserInteractionEnabled = false
        return btn
    }()
    
    let tableView: UITableView = {
        let tv = UITableView(frame: .zero, style: .insetGrouped)
        tv.backgroundColor = .clear
        tv.separatorStyle = .none
        tv.register(ProfileSettingTableViewCell.self, forCellReuseIdentifier: ProfileSettingTableViewCell.reuseIdentifier)
        tv.rowHeight = 44
        return tv
    }()
    
    //MARK: - Configurations
    
    override func configureHierarchy() {
        addSubviews(
            profileImageSettingButton,
            cameraIconButton,
            tableView
        )
    }
    
    override func configureLayout() {
        profileImageSettingButton.snp.makeConstraints { make in
            make.top.equalTo(safeAreaLayoutGuide).offset(24)
            make.centerX.equalToSuperview()
            make.size.equalTo(80)
        }
        
        cameraIconButton.snp.makeConstraints { make in
            make.size.equalTo(24)
            make.trailing.equalTo(profileImageSettingButton.snp.trailing).offset(5)
            make.bottom.equalTo(profileImageSettingButton.snp.bottom).offset(5)
        }
        
        tableView.snp.makeConstraints { make in
            make.top.equalTo(profileImageSettingButton.snp.bottom).offset(16)
            make.horizontalEdges.equalTo(safeAreaLayoutGuide)
            make.bottom.equalToSuperview()
        }
    }
    
    override func configureUI() {
        super.configureUI()
    }
}
