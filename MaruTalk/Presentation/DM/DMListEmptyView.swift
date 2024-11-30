//
//  DMListEmptyView.swift
//  MaruTalk
//
//  Created by 권대윤 on 11/30/24.
//

import UIKit

import SnapKit

final class DMListEmptyView: BaseView {
    
    //MARK: - UI Components
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        let text = "워크스페이스에 멤버가 없어요"
        label.setTextFontWithLineHeight(text: text, font: Constant.Font.title1, lineHeight: Constant.Font.LineHeight.title1)
        label.textColor = Constant.Color.brandBlack
        label.textAlignment = .center
        return label
    }()
    
    private let bodyLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        let text = "새로운 팀원을 초대해보세요."
        label.setTextFontWithLineHeight(text: text, font: Constant.Font.body, lineHeight: Constant.Font.LineHeight.body)
        label.textColor = Constant.Color.brandBlack
        label.textAlignment = .center
        return label
    }()
    
    let inviteButton = RoundedBrandButton(title: "팀원 초대하기")
    
    //MARK: - Configurations
    
    override func configureHierarchy() {
        addSubviews(
            titleLabel,
            bodyLabel,
            inviteButton
        )
    }
    
    override func configureLayout() {
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(safeAreaLayoutGuide).offset(229)
            make.horizontalEdges.equalTo(safeAreaLayoutGuide).inset(62)
        }
        
        bodyLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(19)
            make.horizontalEdges.equalTo(safeAreaLayoutGuide).inset(62)
        }
        
        inviteButton.snp.makeConstraints { make in
            make.top.equalTo(bodyLabel.snp.bottom).offset(19)
            make.horizontalEdges.equalTo(safeAreaLayoutGuide).inset(62)
            make.height.equalTo(44)
        }
    }
    
    override func configureUI() {
        backgroundColor = Constant.Color.brandWhite
    }
}
