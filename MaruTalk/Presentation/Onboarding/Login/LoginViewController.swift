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
    
    private lazy var xMarkButton: UIBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "xmark")?.applyingSymbolConfiguration(.init(pointSize: 14)), style: .plain, target: self, action: nil)
    
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
        
    }
}

//MARK: - Bind State

extension LoginViewController {
    private func bindState(reactor: LoginReactor) {
        
    }
}
