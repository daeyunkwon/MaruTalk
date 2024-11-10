//
//  SignUpViewController.swift
//  MaruTalk
//
//  Created by 권대윤 on 11/2/24.
//

import UIKit

import ReactorKit
import RxCocoa
import RxSwift

final class SignUpViewController: BaseViewController<SignUpView>, View {
    
    //MARK: - Properties
    
    weak var coordinator: SignUpCoordinator?
    var disposeBag = DisposeBag()
    
    //MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.reactor = SignUpReactor()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        coordinator?.didFinish()
    }
    
    //MARK: - Configurations
    
    override func setupNavi() {
        navigationController?.navigationBar.isHidden = true
        
        let titleItem = UINavigationItem(title: "회원가입")
        let closeButton = UIBarButtonItem(image: UIImage(systemName: "xmark")?.applyingSymbolConfiguration(.init(pointSize: 14)), style: .plain, target: self, action: #selector(closeButtonTapped))
        titleItem.leftBarButtonItem = closeButton
        // 네비게이션 아이템 추가
        rootView.customNaviBar.items = [titleItem]
    }
    
    //MARK: - Methods
    
    func bind(reactor: SignUpReactor) {
        bindAction(reactor: reactor)
        bindState(reactor: reactor)
    }
    
    @objc func closeButtonTapped() { }
}

//MARK: - Bind Action

extension SignUpViewController {
    private func bindAction(reactor: SignUpReactor) {
        rootView.customNaviBar.items?[0].leftBarButtonItem?.rx.tap
            .map { Reactor.Action.closeButtonTapped }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        rootView.emailFieldView.inputTextField.rx.text.orEmpty
            .map { Reactor.Action.inputEmail($0) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        rootView.nicknameFieldView.inputTextField.rx.text.orEmpty
            .map { Reactor.Action.inputNickname($0) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        rootView.phoneNumberFieldView.inputTextField.rx.text.orEmpty
            .map { Reactor.Action.inputPhoneNumber($0) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        rootView.passwordFieldView.inputTextField.rx.text.orEmpty
            .map { Reactor.Action.inputPassword($0) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        rootView.passwordCheckFieldView.inputTextField.rx.text.orEmpty
            .map { Reactor.Action.inputPasswordCheck($0) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        rootView.emailCheckButton.rx.tap
            .map { Reactor.Action.emailCheckButtonTapped }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        rootView.signUpButton.rx.tap
            .map { Reactor.Action.signUpButtonTapped }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
    }
}

//MARK: - Bind State

extension SignUpViewController {
    private func bindState(reactor: SignUpReactor) {
        reactor.state.map { $0.shouldClose }
            .distinctUntilChanged()
            .bind(with: self) { owner, value in
                if value {
                    owner.coordinator?.didFinish()
                }
            }
            .disposed(by: disposeBag)
        
        reactor.state.map { $0.emailDuplicateCheckButtonEnabled }
            .distinctUntilChanged()
            .bind(with: self, onNext: { owner, value in
                if value {
                    owner.rootView.emailCheckButton.setBackgroundColor(Constant.Color.brandGreen, for: .normal)
                    owner.rootView.emailCheckButton.isUserInteractionEnabled = true
                } else {
                    owner.rootView.emailCheckButton.setBackgroundColor(Constant.Color.brandInactive, for: .normal)
                    owner.rootView.emailCheckButton.isUserInteractionEnabled = false
                }
            })
            .disposed(by: disposeBag)
        
        reactor.state.map { $0.phoneNumber }
            .distinctUntilChanged()
            .bind(to: rootView.phoneNumberFieldView.inputTextField.rx.text)
            .disposed(by: disposeBag)
        
        reactor.state.map { $0.signUpButtonEnabled }
            .distinctUntilChanged()
            .bind(with: self) { owner, value in
                if value {
                    owner.rootView.signUpButton.setBackgroundColor(Constant.Color.brandGreen, for: .normal)
                    owner.rootView.signUpButton.isUserInteractionEnabled = true
                } else {
                    owner.rootView.signUpButton.setBackgroundColor(Constant.Color.brandInactive, for: .normal)
                    owner.rootView.signUpButton.isUserInteractionEnabled = false
                }
            }
            .disposed(by: disposeBag)
        
        reactor.state.map { $0.toastMessage }
            .filter { !$0.isEmpty }
            .bind(with: self) { owner, value in
                owner.showToastMessage(message: value)
            }
            .disposed(by: disposeBag)
        
        reactor.state.map { $0.networkError }
            .filter { $0.0 != .empty }
            .bind(with: self) { owner, value in
                owner.showToastForNetworkError(api: value.0, errorCode: value.1)
            }
            .disposed(by: disposeBag)
        
        reactor.state.map { ($0.isSignUpInProgress, $0.validationStates) }
            .filter { $0.0 == true }
            .map { $0.1 }
            .bind(with: self) { owner, validationStates in
                var didShowToastMessage = false
                
                let fieldViews = [
                    owner.rootView.emailFieldView,
                    owner.rootView.nicknameFieldView,
                    owner.rootView.phoneNumberFieldView,
                    owner.rootView.passwordFieldView,
                    owner.rootView.passwordCheckFieldView
                ]
                //타이틀 컬러 변경 및 토스트 메시지 팝업
                for (index, isValid) in validationStates.enumerated() {
                    let fieldView = fieldViews[index]
                    
                    fieldView.titleLabel.textColor = isValid ? Constant.Color.brandBlack : Constant.Color.brandRed
                    
                    if !isValid && !didShowToastMessage {
                        
                        var message: String
                        
                        switch index {
                        case 0: message = "이메일 중복 확인을 진행해주세요."
                        case 1: message = "닉네임은 1글자 이상 30글자 이내로 부탁드려요."
                        case 2: message = "잘못된 전화번호 형식입니다."
                        case 3: message = "비밀번호는 최소 8자 이상, 하나 이상의 대소문자/숫자/특수 문자를 설정해주세요."
                        case 4: message = "작성하신 비밀번호가 일치하지 않습니다."
                        default: message = "이메일 중복 확인을 진행해주세요."
                        }
                        
                        owner.showToastMessage(message: message, backgroundColor: Constant.Color.brandRed)
                        fieldView.inputTextField.becomeFirstResponder()
                        didShowToastMessage = true
                    }
                }
            }
            .disposed(by: disposeBag)
    }
}
