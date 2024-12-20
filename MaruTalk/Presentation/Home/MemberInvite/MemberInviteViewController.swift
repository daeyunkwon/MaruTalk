//
//  MemberInviteViewController.swift
//  MaruTalk
//
//  Created by 권대윤 on 11/27/24.
//

import UIKit

import ReactorKit
import RxCocoa

final class MemberInviteViewController: BaseViewController<MemberInviteView>, View {
    
    //MARK: - Properties
    
    var disposeBag: DisposeBag = DisposeBag()
    weak var coordinator: HomeCoordinator?
    
    init(reactor: MemberInviteReactor) {
        super.init()
        self.reactor = reactor
    }
    
    private let xMarkButton: UIBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "xmark")?.applyingSymbolConfiguration(.init(pointSize: 14)), style: .plain, target: nil, action: nil)
    
    //MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    //MARK: - Configurations
    
    override func setupNavi() {
        navigationItem.title = "팀원 초대"
        navigationItem.leftBarButtonItem = xMarkButton
    }
    
    //MARK: - Methods
    
    func bind(reactor: MemberInviteReactor) {
        bindAction(reactor: reactor)
        bindState(reactor: reactor)
    }
}

//MARK: - Bind Action

extension MemberInviteViewController {
    private func bindAction(reactor: MemberInviteReactor) {
        rootView.emailFieldView.inputTextField.rx.text.orEmpty
            .map { Reactor.Action.inputEmail($0) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        xMarkButton.rx.tap
            .map { Reactor.Action.xMarkButtonTapped }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        rootView.inviteButton.rx.tap
            .map { Reactor.Action.inviteButtonTapped }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
    }
}

//MARK: - Bind State

extension MemberInviteViewController {
    private func bindState(reactor: MemberInviteReactor) {
        reactor.state.map { $0.isInviteButtonEnabled }
            .distinctUntilChanged()
            .bind(with: self) { owner, value in
                owner.rootView.inviteButton.setButtonEnabled(isEnabled: value)
            }
            .disposed(by: disposeBag)
        
        reactor.state.map { $0.navigateToHome }
            .filter { $0 == true }
            .bind(with: self) { owner, _ in
                owner.coordinator?.didFinishMemberInvite()
            }
            .disposed(by: disposeBag)
        
        reactor.state.map { $0.inviteSuccess }
            .filter { $0 == true }
            .bind(with: self) { owner, _ in
                NotificationCenter.default.post(name: .memberInviteComplete, object: nil)
                owner.coordinator?.didFinishMemberInvite()
            }
            .disposed(by: disposeBag)
        
        reactor.pulse(\.$networkError)
            .compactMap { $0 }
            .bind(with: self) { owner, value in
                owner.showToastForNetworkError(api: value.0, errorCode: value.1)
            }
            .disposed(by: disposeBag)
    }
}

