//
//  LoginView.swift
//  MaruTalk
//
//  Created by 권대윤 on 11/19/24.
//

import UIKit

import SnapKit

final class LoginView: BaseView {
    
    //MARK: - UI Components
    
    let emailFieldView = TitleWithInputFieldView(title: "이메일", placeholderText: "이메일을 입력하세요")
    
    let passwordFieldView = TitleWithInputFieldView(title: "비밀번호", placeholderText: "비밀번호를 입력하세요")
    
    let loginButton = RoundedBrandButton(title: "로그인")
    
    //MARK: - Configurations
    
    override func configureHierarchy() {
        addSubviews(
            emailFieldView,
            passwordFieldView,
            loginButton
        )
    }
    
    override func configureLayout() {
        emailFieldView.snp.makeConstraints { make in
            make.top.horizontalEdges.equalTo(safeAreaLayoutGuide).inset(24)
            make.height.equalTo(76)
        }
        
        emailFieldView.inputTextField.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview().inset(12)
        }
        
        passwordFieldView.snp.makeConstraints { make in
            make.top.equalTo(emailFieldView.snp.bottom).offset(24)
            make.horizontalEdges.equalTo(safeAreaLayoutGuide).inset(24)
            make.height.equalTo(76)
        }
        
        passwordFieldView.inputTextField.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview().inset(12)
        }
        
        loginButton.snp.makeConstraints { make in
            make.horizontalEdges.equalTo(safeAreaLayoutGuide).inset(24)
            make.height.equalTo(44)
            make.bottom.equalTo(keyboardLayoutGuide.snp.top).offset(-5)
        }
    }
    
    override func configureUI() {
        super.configureUI()
        
        self.emailFieldView.inputTextField.text = "p1@naver.com"
        self.passwordFieldView.inputTextField.text = "1111aA@@"
    }
}
