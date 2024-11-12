//
//  WorkspaceAddViewController.swift
//  MaruTalk
//
//  Created by 권대윤 on 11/12/24.
//

import UIKit

import ReactorKit

final class WorkspaceAddViewController: BaseViewController<WorkspaceAddView>, View {
    
    //MARK: - Properties
    
    var disposeBag: DisposeBag = DisposeBag()
    var reactor: WorkspaceAddReactor
    weak var coordinator: OnboardingCoordinator?
    
    init(reactor: WorkspaceAddReactor) {
        self.reactor = reactor
        super.init()
    }
    
    //MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    //MARK: - Configurations
    
    override func setupNavi() {
        navigationItem.title = "워크스페이스 생성"
        
        let closeButton = UIBarButtonItem(image: UIImage(systemName: "xmark")?.applyingSymbolConfiguration(.init(pointSize: 14)), style: .plain, target: self, action: nil)
        navigationItem.leftBarButtonItem = closeButton
    }
    
    //MARK: - Methods
    
    func bind(reactor: WorkspaceAddReactor) {
        bindAction(reactor: reactor)
        bindState(reactor: reactor)
    }
}

//MARK: - Bind Action

extension WorkspaceAddViewController {
    private func bindAction(reactor: Reactor) {
        
    }
}

//MARK: - Bind State

extension WorkspaceAddViewController {
    private func bindState(reactor: Reactor) {
        
    }
}
