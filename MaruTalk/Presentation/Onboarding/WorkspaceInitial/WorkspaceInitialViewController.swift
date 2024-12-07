//
//  WorkspaceInitialViewController.swift
//  MaruTalk
//
//  Created by 권대윤 on 11/11/24.
//

import UIKit

import ReactorKit
import RxCocoa

//TODO: X 버튼 동작 처리

final class WorkspaceInitialViewController: BaseViewController<WorkspaceInitialView>, View {
    
    //MARK: - Properties
    
    weak var coordinator: OnboardingCoordinator?
    var disposeBag = DisposeBag()
    
    private let xMarkButton = UIBarButtonItem(image: UIImage(systemName: "xmark")?.applyingSymbolConfiguration(.init(pointSize: 14)), style: .plain, target: nil, action: nil)
    
    init(reactor: WorkspaceInitialReactor) {
        super.init()
        self.reactor = reactor
    }
    
    //MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    //MARK: - Configurations
    
    override func setupNavi() {
        navigationItem.title = "시작하기"
        navigationItem.leftBarButtonItem = self.xMarkButton
    }
    
    //MARK: - Methods
    
    func bind(reactor: WorkspaceInitialReactor) {
        bindAction(reactor: reactor)
        bindState(reactor: reactor)
    }
}

//MARK: - Bind Action

extension WorkspaceInitialViewController {
    private func bindAction(reactor: WorkspaceInitialReactor) {
        rootView.createWorkspaceButton.rx.tap
            .map { Reactor.Action.createWorkspaceButtonTapped }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        xMarkButton.rx.tap
            .map { Reactor.Action.xButtonTapped }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
    }
}

//MARK: - Bind State

extension WorkspaceInitialViewController {
    private func bindState(reactor: WorkspaceInitialReactor) {
        reactor.state.map { $0.nickname }
            .distinctUntilChanged()
            .bind(with: self) { owner, value in
                owner.rootView.configureBodyLabel(nickname: value)
            }
            .disposed(by: disposeBag)
        
        reactor.state.map { $0.navigateToWorkspaceAdd }
            .filter { $0 == true }
            .bind(with: self) { owner, _ in
                owner.coordinator?.showWorkspaceAdd()
            }
            .disposed(by: disposeBag)
        
        reactor.state.map { $0.navigateToHome }
            .filter { $0 == true }
            .bind(with: self) { owner, _ in
                owner.coordinator?.didFinish()
            }
            .disposed(by: disposeBag)
    }
}
