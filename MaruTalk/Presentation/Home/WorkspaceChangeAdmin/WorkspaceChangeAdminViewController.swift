//
//  WorkspaceChangeAdminViewController.swift
//  MaruTalk
//
//  Created by 권대윤 on 12/5/24.
//

import UIKit

import ReactorKit
import RxCocoa

final class WorkspaceChangeAdminViewController: BaseViewController<ChannelChangeAdminView>, View {
    
    //MARK: - Properties
    
    var disposeBag: DisposeBag = DisposeBag()
    weak var coordinator: HomeCoordinator?
    
    init(reactor: WorkspaceChangeAdminReactor) {
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
        navigationItem.title = "워크스페이스 관리자 변경"
        navigationItem.leftBarButtonItem = xMarkButton
    }
    
    //MARK: - Methods
    
    func bind(reactor: WorkspaceChangeAdminReactor) {
        bindAction(reactor: reactor)
        bindState(reactor: reactor)
    }
}

//MARK: - Bind Action

extension WorkspaceChangeAdminViewController {
    private func bindAction(reactor: WorkspaceChangeAdminReactor) {
        
    }
}

//MARK: - Bind State

extension WorkspaceChangeAdminViewController {
    private func bindState(reactor: WorkspaceChangeAdminReactor) {
        
    }
}
