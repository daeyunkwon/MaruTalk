//
//  PhoneNumberEditViewController.swift
//  MaruTalk
//
//  Created by 권대윤 on 12/13/24.
//

import UIKit

import ReactorKit
import RxCocoa

final class PhoneNumberEditViewController: BaseViewController<EditView>, View {
    
    //MARK: - Properties
    
    var disposeBag: DisposeBag = DisposeBag()
    weak var coordinator: ProfileCoordinator?
    
    init(reactor: PhoneNumberEditReactor) {
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
        navigationItem.title = "연락처"
    }
    
    //MARK: - Methods
    
    func bind(reactor: PhoneNumberEditReactor) {
        bindAction(reactor: reactor)
        bindState(reactor: reactor)
    }
}

//MARK: - Bind Action

extension PhoneNumberEditViewController {
    private func bindAction(reactor: PhoneNumberEditReactor) {
        rootView.inputFieldView.inputTextField.rx.text.orEmpty
            .skip(1)
            .map { Reactor.Action.inputPhoneNumber($0) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        rootView.doneButton.rx.tap
            .map { Reactor.Action.doneButtonTapped }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
    }
}

//MARK: - Bind State

extension PhoneNumberEditViewController {
    private func bindState(reactor: PhoneNumberEditReactor) {
        reactor.pulse(\.$placeholderText)
            .bind(to: rootView.inputFieldView.inputTextField.rx.placeholder)
            .disposed(by: disposeBag)
        
        reactor.state.map { $0.newPhoneNumber }
            .distinctUntilChanged()
            .bind(to: rootView.inputFieldView.inputTextField.rx.text)
            .disposed(by: disposeBag)
        
        reactor.state.map { $0.isDoneButtonEnabled }
            .distinctUntilChanged()
            .bind(with: self) { owner, value in
                owner.rootView.doneButton.setButtonEnabled(isEnabled: value)
            }
            .disposed(by: disposeBag)
        
        reactor.pulse(\.$navigateToProfile)
            .compactMap { $0 }
            .bind(with: self) { owner, _ in
                owner.coordinator?.didFinishPhoneNumberEdit()
            }
            .disposed(by: disposeBag)
    }
}
