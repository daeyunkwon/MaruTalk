//
//  WorkspaceInitialView.swift
//  MaruTalk
//
//  Created by 권대윤 on 11/11/24.
//

import UIKit

import SnapKit

final class WorkspaceInitialView: BaseView {
    
    //MARK: - UI Components
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        let text = "출시 준비 완료!"
        label.setTextFontWithLineHeight(text: text, font: Constant.Font.title1, lineHeight: Constant.Font.LineHeight.title1)
        label.textColor = Constant.Color.brandBlack
        label.textAlignment = .center
        return label
    }()
    
    let bodyLabel: UILabel = {
        let label = UILabel()
        let text = "옹골찬 고래밥님의 조직을 위해 새로운 마루톡 워크스페이스를 시작할 준비가 완료되었어요!"
        label.setTextFontWithLineHeight(text: text, font: Constant.Font.body, lineHeight: Constant.Font.LineHeight.body)
        label.numberOfLines = 0
        label.textAlignment = .center
        label.textColor = Constant.Color.brandBlack
        return label
    }()
    
    private let launchingImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.image = UIImage(named: "launching")
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
