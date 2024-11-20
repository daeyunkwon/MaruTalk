//
//  LoginViewController.swift
//  MaruTalk
//
//  Created by 권대윤 on 11/19/24.
//

import UIKit

import ReactorKit
import RxCocoa

final class LoginViewController: BaseViewController<LoginView>, View {
    
    //MARK: - Properties
    
    weak var coordinator: OnboardingCoordinator?
    var disposeBag = DisposeBag()
    
    private var shouldNavigateToAuth: Bool = true
    
    private let xMarkButton: UIBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "xmark")?.applyingSymbolConfiguration(.init(pointSize: 14)), style: .plain, target: nil, action: nil)
    
    init(reactor: LoginReactor) {
        super.init()
        self.reactor = reactor
    }
    
    //MARK: - Life Cycle
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        if shouldNavigateToAuth {
            coordinator?.showAuth()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    //MARK: - Configurations
    
    override func setupNavi() {
        navigationItem.title = "이메일 로그인"
        navigationItem.leftBarButtonItem = xMarkButton
    }
    
    //MARK: - Methods
    
    func bind(reactor: LoginReactor) {
        self.bindAction(reactor: reactor)
        self.bindState(reactor: reactor)
    }
}

//MARK: - Bind Action

extension LoginViewController {
    private func bindAction(reactor: LoginReactor) {
        xMarkButton.rx.tap
            .map { Reactor.Action.xButtonTapped }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        rootView.emailFieldView.inputTextField.rx.text.orEmpty
            .map { Reactor.Action.inputEmail($0) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        rootView.passwordFieldView.inputTextField.rx.text.orEmpty
            .map { Reactor.Action.inputPassword($0) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        rootView.loginButton.rx.tap
            .map { Reactor.Action.loginButtonTapped }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
    }
}

//MARK: - Bind State

extension LoginViewController {
    private func bindState(reactor: LoginReactor) {
        reactor.state.map { $0.shouldNavigateToAuth }
            .filter { $0 == true }
            .bind(with: self) { owner, _ in
                owner.coordinator?.didFinishLogin()
            }
            .disposed(by: disposeBag)
        
        reactor.state.map { $0.shouldNavigateToHome }
            .filter { $0 == true }
            .bind(with: self) { owner, _ in
                owner.shouldNavigateToAuth = false
                owner.coordinator?.didFinish()
            }
            .disposed(by: disposeBag)
        
        reactor.state.map { $0.isLoginButtonEnabled }
            .distinctUntilChanged()
            .bind(with: self) { owner, value in
                owner.rootView.loginButton.setButtonEnabled(isEnabled: value)
            }
            .disposed(by: disposeBag)
        
        reactor.pulse(\.$validationStates)
            .bind(with: self) { owner, values in
                var didShowToastMessage = false
                
                let fieldViews = [
                    owner.rootView.emailFieldView,
                    owner.rootView.passwordFieldView
                ]
                
                for (index, isValid) in values.enumerated() {
                    let fieldView = fieldViews[index]
                    
                    fieldView.titleLabel.textColor = isValid ? Constant.Color.brandBlack : Constant.Color.brandRed
                    
                    if !isValid && !didShowToastMessage {
                        var message: String
                        switch index {
                        case 0: message = "이메일 형식이 올바르지 않습니다."
                        case 1: message = "비밀번호는 최소 8자 이상, 하나 이상의 대소문자/숫자/특수 문자를 설정해주세요."
                        default: message = "이메일 형식이 올바르지 않습니다."
                        }
                        owner.showToastMessage(message: message, backgroundColor: Constant.Color.brandRed)
                        fieldView.inputTextField.becomeFirstResponder()
                        didShowToastMessage = true
                    }
                }
            }
            .disposed(by: disposeBag)
        
        reactor.pulse(\.$networkError)
            .bind(with: self) { owner, value in
                owner.showToastForNetworkError(api: value.0, errorCode: value.1)
            }
            .disposed(by: disposeBag)
        
        reactor.state.map { $0.isLoginInProgress }
            .distinctUntilChanged()
            .bind(with: self) { owner, value in
                owner.showToastActivity(shouldShow: value)
            }
            .disposed(by: disposeBag)
    }
}
