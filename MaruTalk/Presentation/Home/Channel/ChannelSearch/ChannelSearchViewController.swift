//
//  ChannelSearchViewController.swift
//  MaruTalk
//
//  Created by 권대윤 on 11/27/24.
//

import UIKit

import ReactorKit
import RxCocoa

final class ChannelSearchViewController: BaseViewController<ChannelSearchView>, View {
    
    //MARK: - Properties
    
    var disposeBag: DisposeBag = DisposeBag()
    weak var coordinator: ChannelCoordinator?
    
    init(reactor: ChannelSearchReactor) {
        super.init()
        self.reactor = reactor
    }
    
    private let xMarkButton: UIBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "xmark")?.applyingSymbolConfiguration(.init(pointSize: 14)), style: .plain, target: nil, action: nil)
    
    //MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        reactor?.action.onNext(.fetch)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.tabBarController?.tabBar.isHidden = false
        self.navigationItem.title = ""
    }
    
    //MARK: - Configurations
    
    override func setupNavi() {
        navigationItem.title = "채널 탐색"
        navigationItem.leftBarButtonItem = xMarkButton
    }
    
    //MARK: - Methods
    
    func bind(reactor: ChannelSearchReactor) {
        bindAction(reactor: reactor)
        bindState(reactor: reactor)
    }
}

//MARK: - Bind Action

extension ChannelSearchViewController {
    private func bindAction(reactor: ChannelSearchReactor) {
        xMarkButton.rx.tap
            .map { Reactor.Action.xMarkButtonTapped }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        rootView.tableView.rx.modelSelected(Channel.self)
            .map { Reactor.Action.selectChannel($0) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        rootView.tableView.rx.itemSelected
            .subscribe(onNext: { [weak self] indexPath in
                guard let self = self else { return }
                //선택 마크 해제하기
                self.rootView.tableView.deselectRow(at: indexPath, animated: true)
            })
            .disposed(by: disposeBag)
        
    }
}

//MARK: - Bind State

extension ChannelSearchViewController {
    private func bindState(reactor: ChannelSearchReactor) {
        reactor.pulse(\.$navigateToHome)
            .compactMap { $0 }
            .bind(with: self) { owner, _ in
                owner.coordinator?.didFinishChannelSearch()
            }
            .disposed(by: disposeBag)
        
        reactor.pulse(\.$networkError)
            .compactMap { $0 }
            .bind(with: self) { owner, value in
                owner.showToastForNetworkError(api: value.0, errorCode: value.1)
            }
            .disposed(by: disposeBag)
        
        reactor.pulse(\.$channelList)
            .compactMap { $0 }
            .bind(to: rootView.tableView.rx.items(cellIdentifier: ChannelIconTitleCountTableViewCell.reuseIdentifier, cellType: ChannelIconTitleCountTableViewCell.self)) { row, element, cell in
                cell.configure(channel: element)
            }
            .disposed(by: disposeBag)
        
        reactor.pulse(\.$showJoinAlert)
            .compactMap { $0 }
            .bind(with: self) { [weak self] owner, value in
                guard let self else { return }
                let message = "[\(value.name)] 채널에 참여하시겠습니까?"
                //수락할 경우 채팅 화면으로 진입
                let okAction = {
                    self.coordinator?.showChannelChatting(channelID: value.id) //먼저 화면 이동
                    self.coordinator?.didFinishChannelSearch(isNavigateToChannelChatting: true) //네비게이션 스택 제거 작업
                }
                
                owner.showAlert(title: "채널 참여", message: message, actions: [
                    ("확인", okAction)
                ])
            }
            .disposed(by: disposeBag)
        
        reactor.pulse(\.$navigateToCannelChatting)
            .compactMap { $0 }
            .bind(with: self) { owner, value in
                owner.coordinator?.showChannelChatting(channelID: value.id) //먼저 화면 이동
                owner.coordinator?.didFinishChannelSearch(isNavigateToChannelChatting: true) //네비게이션 스택 제거 작업
            }
            .disposed(by: disposeBag)
    }
}
