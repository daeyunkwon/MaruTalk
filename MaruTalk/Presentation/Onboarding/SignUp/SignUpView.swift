//
//  SignUpView.swift
//  MaruTalk
//
//  Created by 권대윤 on 11/2/24.
//

import UIKit

import SnapKit

final class SignUpView: BaseView {
    
    //MARK: - UI Components
    
    private let scrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.backgroundColor = Constant.Color.backgroundPrimary
        return sv
    }()
    
    let customNaviBar = CustomHandleNavigationBar()
    
    private let backView: UIView = {
        let view = UIView()
        view.backgroundColor = Constant.Color.backgroundPrimary
        return view
    }()
    
    let emailFieldView: TitleWithInputFieldView = TitleWithInputFieldView(title: "이메일", placeholderText: "이메일을 입력하세요")
    
    let emailCheckButton: RectangleBrandColorButton = RectangleBrandColorButton(title: "중복 확인")
    
    let nicknameFieldView: TitleWithInputFieldView = TitleWithInputFieldView(title: "닉네임", placeholderText: "닉네임을 입력하세요")
    
    let phoneNumberFieldView: TitleWithInputFieldView = TitleWithInputFieldView(title: "연락처", placeholderText: "전화번호를 입력하세요")
    
    let passwordFieldView: TitleWithInputFieldView = TitleWithInputFieldView(title: "비밀번호", placeholderText: "비밀번호를 입력하세요")
    
    let passwordCheckFieldView: TitleWithInputFieldView = TitleWithInputFieldView(title: "비밀번호 확인", placeholderText: "비밀번호를 한 번 더 입력하세요")
    
    let signUpButton: RectangleBrandColorButton = RectangleBrandColorButton(title: "가입하기")
    
    //MARK: - Configurations
    
    override func configureHierarchy() {
        addSubview(scrollView)
        scrollView.addSubviews(
            backView
        )
        
        backView.addSubviews(
            emailCheckButton,
            emailFieldView,
            nicknameFieldView,
            phoneNumberFieldView,
            passwordFieldView,
            passwordCheckFieldView,
            signUpButton
        )
        
        addSubview(customNaviBar)
    }
    
    override func configureLayout() {
        scrollView.snp.makeConstraints { make in
            make.top.equalTo(safeAreaLayoutGuide)
            make.horizontalEdges.bottom.equalToSuperview()
        }
        
        customNaviBar.snp.makeConstraints { make in
            make.top.horizontalEdges.equalTo(safeAreaLayoutGuide)
            make.height.equalTo(44)
        }
        
        backView.snp.makeConstraints { make in
            make.leading.trailing.equalTo(scrollView.contentLayoutGuide)
            make.verticalEdges.equalToSuperview()
            make.width.equalTo(scrollView.frameLayoutGuide) // 스크롤뷰와 같은 너비로 설정
        }
        
        emailCheckButton.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(101)
            make.trailing.equalTo(safeAreaLayoutGuide).offset(-24)
            make.width.equalTo(100)
            make.height.equalTo(44)
        }
        
        emailFieldView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(70)
            make.leading.equalTo(safeAreaLayoutGuide).inset(24)
            make.height.equalTo(76)
            make.trailing.equalTo(emailCheckButton.snp.leading).offset(-12)
        }
        
        emailFieldView.inputTextField.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview().inset(12)
        }
        
        nicknameFieldView.snp.makeConstraints { make in
            make.top.equalTo(emailFieldView.snp.bottom).offset(24)
            make.horizontalEdges.equalTo(safeAreaLayoutGuide).inset(24)
            make.height.equalTo(76)
        }
        
        nicknameFieldView.inputTextField.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview().inset(12)
        }
        
        phoneNumberFieldView.snp.makeConstraints { make in
            make.top.equalTo(nicknameFieldView.snp.bottom).offset(24)
            make.horizontalEdges.equalTo(safeAreaLayoutGuide).inset(24)
            make.height.equalTo(76)
        }
        
        phoneNumberFieldView.inputTextField.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview().inset(12)
        }
        
        passwordFieldView.snp.makeConstraints { make in
            make.top.equalTo(phoneNumberFieldView.snp.bottom).offset(24)
            make.horizontalEdges.equalTo(safeAreaLayoutGuide).inset(24)
            make.height.equalTo(76)
        }
        
        passwordFieldView.inputTextField.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview().inset(12)
        }
        
        passwordCheckFieldView.snp.makeConstraints { make in
            make.top.equalTo(passwordFieldView.snp.bottom).offset(24)
            make.horizontalEdges.equalTo(safeAreaLayoutGuide).inset(24)
            make.height.equalTo(76)
            make.bottom.equalToSuperview().inset(420)
        }
        
        passwordCheckFieldView.inputTextField.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview().inset(12)
        }
        
        signUpButton.snp.makeConstraints { make in
            make.horizontalEdges.equalTo(safeAreaLayoutGuide).inset(24)
            make.bottom.equalTo(keyboardLayoutGuide.snp.top).offset(-5)
            make.height.equalTo(44)
        }
    }
    
    override func configureUI() {
        backgroundColor = Constant.Color.brandBlack
        
        [emailFieldView, nicknameFieldView, phoneNumberFieldView, passwordFieldView, passwordCheckFieldView].forEach {
            $0.inputTextField.delegate = self
        }
    }
    
    //MARK: - Methods
    
    func scrollToOffset(x: CGFloat, y: CGFloat, animated: Bool) {
        scrollView.setContentOffset(CGPoint(x: x, y: y), animated: animated)
    }
}

//MARK: - UITextFieldDelegate

extension SignUpView: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        //화면 스크롤 조작
        if textField == passwordFieldView.inputTextField || textField == passwordCheckFieldView.inputTextField {
            scrollToOffset(x: 0, y: 200, animated: true)
        } else {
            scrollToOffset(x: 0, y: 0, animated: true)
        }
    }
}
