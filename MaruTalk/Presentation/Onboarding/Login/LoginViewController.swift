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
                owner.coordinator?.didFinish()
            }
            .disposed(by: disposeBag)
        
        reactor.state.map { $0.isLoginButtonEnabled }
            .distinctUntilChanged()
            .bind(with: self) { owner, value in
                owner.rootView.loginButton.setButtonEnabled(isEnabled: value)
            }
            .disposed(by: disposeBag)
    }
}
