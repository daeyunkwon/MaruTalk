//
//  WorkspaceInitialViewController.swift
//  MaruTalk
//
//  Created by 권대윤 on 11/11/24.
//

import UIKit

import ReactorKit

final class WorkspaceInitialViewController: BaseViewController<WorkspaceInitialView>, View {
    
    //MARK: - Properties
    
    weak var coordinator: OnboardingCoordinator?
    var disposeBag = DisposeBag()
    
    private let reactor: WorkspaceInitialReactor
    
    init(reactor: WorkspaceInitialReactor) {
        self.reactor = reactor
        super.init()
    }
    
    //MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bind(reactor: reactor)
    }
    
    //MARK: - Configurations
    
    override func setupNavi() {
        navigationItem.title = "시작하기"
        
        let closeButton = UIBarButtonItem(image: UIImage(systemName: "xmark")?.applyingSymbolConfiguration(.init(pointSize: 14)), style: .plain, target: self, action: nil)
        navigationItem.leftBarButtonItem = closeButton
    }
    
    //MARK: - Methods
    
    func bind(reactor: WorkspaceInitialReactor) {
        bindAction(reactor: reactor)
        bindState(reactor: reactor)
    }
}

//MARK: - Bind Action

extension WorkspaceInitialViewController {
    private func bindAction(reactor: Reactor) {
        rootView.createWorkspaceButton.rx.tap
            .map { Reactor.Action.createWorkspaceButtonTapped }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
    }
}

//MARK: - Bind State

extension WorkspaceInitialViewController {
    private func bindState(reactor: Reactor) {
        reactor.state.map { $0.nickname }
            .distinctUntilChanged()
            .bind(with: self) { owner, value in
                owner.rootView.configureBodyLabel(nickname: value)
            }
            .disposed(by: disposeBag)
        
        reactor.state.map { $0.shouldNavigateToWorkspaceAdd }
            .filter { $0 == true }
            .bind(with: self) { owner, _ in
                owner.coordinator?.showWorkspaceAdd()
            }
            .disposed(by: disposeBag)
    }
}
