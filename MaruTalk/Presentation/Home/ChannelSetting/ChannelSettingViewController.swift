//
//  ChannelSettingViewController.swift
//  MaruTalk
//
//  Created by 권대윤 on 11/28/24.
//

import UIKit

import ReactorKit
import RxCocoa

final class ChannelSettingViewController: BaseViewController<ChannelSettingView>, View {
    
    //MARK: - Properties
    
    var disposeBag: DisposeBag = DisposeBag()
    weak var coordinator: HomeCoordinator?
    
    init(reactor: ChannelSettingReactor) {
        super.init()
        self.reactor = reactor
    }
    
    //MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        reactor?.action.onNext(.fetch)
        self.tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        tabBarController?.tabBar.isHidden = false
    }
    
    //MARK: - Configurations
    
    override func setupNavi() {
        navigationItem.title = "채널 설정"
    }
    
    //MARK: - Methods
    
    func bind(reactor: ChannelSettingReactor) {
        bindAction(reactor: reactor)
        bindState(reactor: reactor)
    }
}

//MARK: - Bind Action

extension ChannelSettingViewController {
    private func bindAction(reactor: ChannelSettingReactor) {
        rootView.arrowIconButton.rx.tap
            .map { Reactor.Action.arrowButtonTapped }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
    }
}

//MARK: - Bind State

extension ChannelSettingViewController {
    private func bindState(reactor: ChannelSettingReactor) {
        reactor.pulse(\.$networkError)
            .compactMap { $0 }
            .bind(with: self) { owner, value in
                owner.showToastForNetworkError(api: value.0, errorCode: value.1)
            }
            .disposed(by: disposeBag)
        
        reactor.state.map { $0.channelName }
            .distinctUntilChanged()
            .bind(to: rootView.channelNameLabel.rx.text)
            .disposed(by: disposeBag)
        
        reactor.state.map { $0.description }
            .distinctUntilChanged()
            .bind(to: rootView.channelDescriptionLabel.rx.text)
            .disposed(by: disposeBag)
        
        reactor.state.map { $0.memberCount }
            .distinctUntilChanged()
            .bind(with: self) { owner, value in
                owner.rootView.channelMemberCountLabel.text = "멤버 (\(value))"
            }
            .disposed(by: disposeBag)
        
        rootView.collectionView.rx.observe(CGSize.self, "contentSize")
            .compactMap { $0 }
            .bind(with: self) { owner, size in
                owner.rootView.collectionView.snp.updateConstraints { make in
                    make.height.equalTo(size.height)
                }
            }
            .disposed(by: disposeBag)
        
        reactor.pulse(\.$memberList)
            .compactMap { $0 }
            .bind(to: rootView.collectionView.rx.items(cellIdentifier: ProfileImageTitleCollectionViewCell.reuseIdentifier, cellType: ProfileImageTitleCollectionViewCell.self)) { row, element, cell in
                cell.configureCell(data: element)
            }
            .disposed(by: disposeBag)
        
        reactor.state.map { $0.isExpand }
            .distinctUntilChanged()
            .bind(with: self) { owner, value in
                owner.rootView.updateDisplayMemberCollection(isExpand: value)
            }
            .disposed(by: disposeBag)
        
    }
}

