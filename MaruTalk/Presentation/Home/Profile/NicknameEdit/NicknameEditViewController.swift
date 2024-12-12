//
//  NicknameEditViewController.swift
//  MaruTalk
//
//  Created by 권대윤 on 12/12/24.
//

import UIKit

import ReactorKit
import RxCocoa

final class NicknameEditViewController: BaseViewController<EditView>, View {
    
    //MARK: - Properties
    
    var disposeBag: DisposeBag = DisposeBag()
    weak var coordinator: ProfileCoordinator?
    
    init(reactor: NicknameEditReactor) {
        super.init()
        self.reactor = reactor
    }
    
    //MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        tabBarController?.tabBar.isHidden = false
    }
    
    //MARK: - Configurations
    
    override func setupNavi() {
        navigationItem.title = "닉네임"
    }
    
    //MARK: - Methods
    
    func bind(reactor: NicknameEditReactor) {
        bindAction(reactor: reactor)
        bindState(reactor: reactor)
    }
}

//MARK: - Bind Action

extension NicknameEditViewController {
    private func bindAction(reactor: NicknameEditReactor) {
        
    }
}

//MARK: - Bind State

extension NicknameEditViewController {
    private func bindState(reactor: NicknameEditReactor) {
        reactor.pulse(\.$nickname)
            .bind(to: rootView.inputFieldView.inputTextField.rx.text)
            .disposed(by: disposeBag)
        
        reactor.pulse(\.$placeholderText)
            .bind(to: rootView.inputFieldView.inputTextField.rx.placeholder)
            .disposed(by: disposeBag)
    }
}
