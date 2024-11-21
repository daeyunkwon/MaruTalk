//
//  AuthViewController.swift
//  MaruTalk
//
//  Created by 권대윤 on 10/31/24.
//

import AuthenticationServices
import UIKit

import ReactorKit
import RxCocoa
import RxSwift

final class AuthViewController: BaseViewController<AuthView>, View {
    
    //MARK: - Properties
    
    var disposeBag = DisposeBag()
    weak var coordinator: OnboardingCoordinator?
    
    init(reactor: AuthReactor) {
        super.init()
        self.reactor = reactor
    }
    
    //MARK: - Life Cycle
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        coordinator?.didFinishAuth()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    //MARK: - Bind
    
    func bind(reactor: AuthReactor) {
        rootView.appleLoginButton.rx.tap
            .bind(with: self) { owner, _ in
                let provider = ASAuthorizationAppleIDProvider()
                let request = provider.createRequest()
                
                request.requestedScopes = [.fullName, .email]
                
                let controller = ASAuthorizationController(authorizationRequests: [request])
                controller.delegate = self
                controller.performRequests()
            }
            .disposed(by: disposeBag)
        
        rootView.kakaoLoginButton.rx.tap
            .map { Reactor.Action.loginWithKakao }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        rootView.signUpButton.rx.tap
            .bind(with: self) { owner, _ in
                owner.coordinator?.didFinishAuth()
                owner.coordinator?.showSignUp()
            }
            .disposed(by: disposeBag)
        
        rootView.emailLoginButton.rx.tap
            .bind(with: self) { owner, _ in
                owner.coordinator?.didFinishAuth()
                owner.coordinator?.showLogin()
            }
            .disposed(by: disposeBag)
        
        reactor.pulse(\.$networkError)
            .bind(with: self) { owner, value in
                owner.showToastForNetworkError(api: value.0, errorCode: value.1)
            }
            .disposed(by: disposeBag)
        
        reactor.state.map { $0.loginSuccess }
            .filter { $0 == true }
            .bind(with: self) { owner, _ in
                owner.coordinator?.didFinish()
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

//MARK: - ASAuthorizationControllerDelegate

extension AuthViewController: ASAuthorizationControllerDelegate {
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: any Error) {
        print("로그인 실패", error.localizedDescription)
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        switch authorization.credential {
        case let appleIdCredential as ASAuthorizationAppleIDCredential:
            self.reactor?.action.onNext(.loginWithApple(appleIdCredential: appleIdCredential))
        default:
            break
        }
    }
}

