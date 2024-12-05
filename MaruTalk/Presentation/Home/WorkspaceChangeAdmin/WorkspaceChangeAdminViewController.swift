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
        rx.methodInvoked(#selector(viewWillAppear(_:)))
            .map { _ in Reactor.Action.fetch }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        xMarkButton.rx.tap
            .map { Reactor.Action.xMarkButtonTapped }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        rootView.tableView.rx.modelSelected(User.self)
            .bind(with: self) { owner, value in
                owner.showAlert(title: "워크스페이스 관리자 변경", message: "\(value.nickname)님에게 관리자 권한을 양도하시겠습니까?", actions: [
                    ("확인", { owner.reactor?.action.onNext(.selectChangeAdmin(value)) })
                ])
            }
            .disposed(by: disposeBag)
    }
}

//MARK: - Bind State

extension WorkspaceChangeAdminViewController {
    private func bindState(reactor: WorkspaceChangeAdminReactor) {
        let memberListStream = reactor.pulse(\.$memberList)
            .compactMap { $0 }
            .share()
        
        memberListStream
            .bind(to: rootView.tableView.rx.items(cellIdentifier: ProfileNameEmailTableViewCell.reuseIdentifier, cellType: ProfileNameEmailTableViewCell.self)) { row, element, cell in
                cell.configureCell(data: element)
            }
            .disposed(by: disposeBag)
        
        memberListStream
            .filter { $0.isEmpty }
            .bind(with: self) { owner, _ in
                owner.showOnlyCloseActionAlert(title: "워크스페이스 관리자 변경 불가", message: "멤버가 없어 관리자를 변경할 수 없습니다.", action: ("확인", { [weak self] in
                    guard let self else { return }
                    self.coordinator?.didFinishWorkspaceChangeAdmin()
                }))
            }
            .disposed(by: disposeBag)
                
        reactor.pulse(\.$networkError)
            .compactMap { $0 }
            .bind(with: self) { owner, value in
                owner.showToastForNetworkError(api: value.0, errorCode: value.1)
            }
            .disposed(by: disposeBag)
        
        reactor.pulse(\.$shouldNavigateToWorkspaceList)
            .compactMap { $0 }
            .bind(with: self) { owner, _ in
                owner.coordinator?.didFinishWorkspaceChangeAdmin()
            }
            .disposed(by: disposeBag)
    }
}
