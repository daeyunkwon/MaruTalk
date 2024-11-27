//
//  MemberInviteView.swift
//  MaruTalk
//
//  Created by 권대윤 on 11/27/24.
//

import UIKit

import SnapKit

final class MemberInviteView: BaseView {
    
    //MARK: - UI Components
    
    let emailFieldView = TitleWithInputFieldView(title: "이메일", placeholderText: "초대할 팀원의 이메일을 입력하세요.")

    let inviteButton = RoundedBrandButton(title: "초대 보내기")
    
    //MARK: - Configurations
    
    override func configureHierarchy() {
        addSubviews(
            emailFieldView,
            inviteButton
        )
    }
    
    override func configureLayout() {
        emailFieldView.snp.makeConstraints { make in
            make.top.equalTo(safeAreaLayoutGuide).offset(24)
            make.horizontalEdges.equalTo(safeAreaLayoutGuide).inset(24)
            make.height.equalTo(76)
        }
        
        emailFieldView.inputTextField.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview().inset(12)
        }
        
        inviteButton.snp.makeConstraints { make in
            make.height.equalTo(44)
            make.bottom.equalTo(keyboardLayoutGuide.snp.top).offset(-15)
            make.horizontalEdges.equalTo(safeAreaLayoutGuide).inset(24)
        }
    }
    
    override func configureUI() {
        super.configureUI()
    }
}
