//
//  AuthViewController.swift
//  MaruTalk
//
//  Created by 권대윤 on 10/31/24.
//

import UIKit

import RxCocoa
import RxSwift

final class AuthViewController: BaseViewController<AuthView> {
    
    //MARK: - Properties
    
    weak var coordinator: OnboardingCoordinator?
    private let disposeBag = DisposeBag()
    
    //MARK: - Life Cycle
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        coordinator?.didFinishAuth()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    //MARK: - Bind
    
    override func bind() {
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
    }
}

