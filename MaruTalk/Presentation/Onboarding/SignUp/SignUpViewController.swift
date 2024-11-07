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
    }
}
