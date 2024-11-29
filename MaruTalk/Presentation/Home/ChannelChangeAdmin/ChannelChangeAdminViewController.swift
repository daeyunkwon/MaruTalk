//
//  ChannelChangeAdminViewController.swift
//  MaruTalk
//
//  Created by 권대윤 on 11/29/24.
//

import UIKit

import ReactorKit
import RxCocoa

final class ChannelChangeAdminViewController: BaseViewController<ChannelChangeAdminView>, View {
    
    //MARK: - Properties
    
    var disposeBag: DisposeBag = DisposeBag()
    weak var coordinator: HomeCoordinator?
    
    init(reactor: ChannelChangeAdminReactor) {
        super.init()
        self.reactor = reactor
    }
    
    private let xMarkButton: UIBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "xmark")?.applyingSymbolConfiguration(.init(pointSize: 14)), style: .plain, target: nil, action: nil)
    
    //MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        reactor?.action.onNext(.fetch)
    }
    
    //MARK: - Configurations
    
    override func setupNavi() {
        navigationItem.title = "채널 관리자 변경"
        navigationItem.leftBarButtonItem = xMarkButton
    }
    
    //MARK: - Methods
    
    func bind(reactor: ChannelChangeAdminReactor) {
        bindAction(reactor: reactor)
        bindState(reactor: reactor)
    }
}

//MARK: - Bind Action

extension ChannelChangeAdminViewController {
    private func bindAction(reactor: ChannelChangeAdminReactor) {
        xMarkButton.rx.tap
            .map { Reactor.Action.xMarkButtonTapped }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        rootView.tableView.rx.itemSelected
            .bind(with: self) { owner, indexPath in
                owner.rootView.tableView.deselectRow(at: indexPath, animated: true)
                owner.reactor?.action.onNext(.selectRow(indexPath.row))
            }
            .disposed(by: disposeBag)
    }
}

//MARK: - Bind State

extension ChannelChangeAdminViewController {
    private func bindState(reactor: ChannelChangeAdminReactor) {
        reactor.pulse(\.$shouldNavigateToChannelSetting)
            .compactMap { $0 }
            .bind(with: self) { owner, _ in
                owner.coordinator?.didFinishChannelChangeAdmin()
            }
            .disposed(by: disposeBag)
        
        reactor.pulse(\.$networkError)
            .compactMap { $0 }
            .bind(with: self) { owner, value in
                owner.showToastForNetworkError(api: value.0, errorCode: value.1)
            }
            .disposed(by: disposeBag)
        
        reactor.pulse(\.$memberList)
            .compactMap { $0 }
            .bind(to: rootView.tableView.rx.items(cellIdentifier: ProfileNameEmailTableViewCell.reuseIdentifier, cellType: ProfileNameEmailTableViewCell.self)) { row, element, cell in
                cell.configureCell(data: element)
            }
            .disposed(by: disposeBag)
        
        reactor.pulse(\.$memberList)
            .compactMap { $0 }
            .filter { $0.isEmpty }
            .bind(with: self) { owner, _ in
                //본인 제외 멤버가 없는 경우
                owner.showOnlyCloseActionAlert(title: "채널 관리자 변경 불가", message: "채널 멤버가 없어 관리자를 변경할 수 없습니다.", action: ("확인", { [weak self] in
                    guard let self else { return }
                    self.coordinator?.didFinishChannelChangeAdmin()
                }))
            }
            .disposed(by: disposeBag)
    }
}
