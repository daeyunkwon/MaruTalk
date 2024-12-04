//
//  WorkspaceListTableViewCell.swift
//  MaruTalk
//
//  Created by 권대윤 on 12/4/24.
//

import UIKit

import SnapKit

final class WorkspaceListTableViewCell: BaseTableViewCell {
    
    //MARK: - UI Components
    
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = Constant.Color.brandWhite
        view.layer.cornerRadius = 5
        view.clipsToBounds = true
        return view
    }()
    
    private let workspaceImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.layer.cornerRadius = 4
        iv.backgroundColor = .lightGray
        return iv
    }()
    
    private let workspaceNameLabel: UILabel = {
        let label = UILabel()
        label.font = Constant.Font.bodyBold
        label.textAlignment = .left
        label.textColor = Constant.Color.textPrimary
        return label
    }()
    
    private let createLabel: UILabel = {
        let label = UILabel()
        label.font = Constant.Font.body
        label.textColor = Constant.Color.textSecondary
        label.textAlignment = .left
        return label
    }()
    
    let menuButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setImage(UIImage(named: "three_dots"), for: .normal)
        btn.tintColor = Constant.Color.brandBlack
        btn.isHidden = true
        return btn
    }()
    
    //MARK: - Configurations
    
    override func configureHierarchy() {
        contentView.addSubview(containerView)
        containerView.addSubviews(
            workspaceImageView,
            workspaceNameLabel,
            createLabel,
            menuButton
        )
    }
    
    override func configureLayout() {
        containerView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(7)
        }
        
        workspaceImageView.snp.makeConstraints { make in
            make.size.equalTo(45)
            make.leading.equalToSuperview().inset(8)
        }
        
        menuButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-8)
            make.centerY.equalTo(workspaceImageView)
        }
        
        workspaceNameLabel.snp.makeConstraints { make in
            make.top.equalTo(workspaceImageView).offset(4)
            make.leading.equalTo(workspaceImageView.snp.trailing).offset(8)
            make.trailing.equalTo(menuButton.snp.leading).offset(-5)
        }
        
        createLabel.snp.makeConstraints { make in
            make.leading.equalTo(workspaceNameLabel)
            make.top.equalTo(workspaceNameLabel.snp.bottom).offset(1)
            make.trailing.equalTo(workspaceNameLabel)
        }
    }
    
    override func configureUI() {
        backgroundColor = .clear
    }
    
    func configureCell(data: Workspace) {
        guard let workspaceID = UserDefaultsManager.shared.recentWorkspaceID else { return }
        
        if data.id == workspaceID {
            //선택한 워크스페이스인 경우
            containerView.backgroundColor = Constant.Color.brandInactive
            menuButton.isHidden = false
        } else {
            //미선택 워크스페이스인 경우
            containerView.backgroundColor = Constant.Color.brandWhite
            menuButton.isHidden = true
        }
        
        workspaceImageView.setImage(imagePath: data.coverImage)
        workspaceNameLabel.text = data.name
        let date = Date.createdDate(dateString: data.createdAt)
        createLabel.setDateString(date: date)
    }
}
