//
//  HomeEmptyView.swift
//  MaruTalk
//
//  Created by 권대윤 on 11/15/24.
//

import UIKit

import SnapKit

final class HomeEmptyView: BaseView {
    
    //MARK: - UI Components
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        let text = "워크스페이스를 찾을 수 없어요."
        label.setTextFontWithLineHeight(text: text, font: Constant.Font.title1, lineHeight: Constant.Font.LineHeight.title1)
        label.textColor = Constant.Color.brandBlack
        label.textAlignment = .center
        return label
    }()
    
    private let bodyLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        let text = "관리자에게 초대를 요청하거나, 다른 이메일로 시도하거나 새로운 워크스페이스를 생성해주세요."
        label.setTextFontWithLineHeight(text: text, font: Constant.Font.body, lineHeight: Constant.Font.LineHeight.body)
        label.textColor = Constant.Color.brandBlack
        label.textAlignment = .center
        return label
    }()
    
    private let launchingImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.image = UIImage(named: "workspace_empty")
        return iv
    }()
    
    let createWorkspaceButton = RectangleBrandColorButton(title: "워크스페이스 생성")
    
    //MARK: - Configurations
    
    override func configureHierarchy() {
        addSubviews(
            titleLabel,
            bodyLabel,
            launchingImageView,
            createWorkspaceButton
        )
    }
    
    override func configureLayout() {
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(safeAreaLayoutGuide).offset(35)
            make.horizontalEdges.equalTo(safeAreaLayoutGuide).inset(24)
        }
        
        bodyLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(24)
            make.leading.equalTo(safeAreaLayoutGuide).offset(23)
            make.trailing.equalTo(safeAreaLayoutGuide).offset(-25)
        }
        
        launchingImageView.snp.makeConstraints { make in
            make.top.equalTo(bodyLabel.snp.bottom).offset(15)
            make.horizontalEdges.equalTo(safeAreaLayoutGuide).inset(13)
            make.height.equalTo(launchingImageView.snp.width)
        }
        
        createWorkspaceButton.snp.makeConstraints { make in
            make.horizontalEdges.equalTo(safeAreaLayoutGuide).inset(24)
            make.bottom.equalToSuperview().inset(45)
            make.height.equalTo(44)
        }
    }
    
    override func configureUI() {
        super.configureUI()
    }
}
