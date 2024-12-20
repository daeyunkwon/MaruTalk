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
    weak var coordinator: ChannelCoordinator?
    
    init(reactor: ChannelSettingReactor) {
        super.init()
        self.reactor = reactor
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    //MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNotification()
        reactor?.action.onNext(.fetch)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
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
    
    private func setupNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleModalDismissed), name: .channelEditComplete, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleModalDismissed), name: .channelChangeAdminComplete, object: nil)
    }
    
    //MARK: - Methods
    
    func bind(reactor: ChannelSettingReactor) {
        bindAction(reactor: reactor)
        bindState(reactor: reactor)
    }
    
    @objc private func handleModalDismissed(notification: Notification) {
        reactor?.action.onNext(.fetch)
        
        switch notification.name {
        case .channelEditComplete:
            showToastMessage(message: "채널이 편집되었습니다.")
        case .channelChangeAdminComplete:
            showToastMessage(message: "채널 관리자가 변경되었습니다.")
        default: break
        }
    }
}

//MARK: - Bind Action

extension ChannelSettingViewController {
    private func bindAction(reactor: ChannelSettingReactor) {
        rootView.arrowIconButton.rx.tap
            .map { Reactor.Action.arrowButtonTapped }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        rootView.editButton.rx.tap
            .map { Reactor.Action.editButtonTapped }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        rootView.changeAdminButton.rx.tap
            .map { Reactor.Action.changeAdminButtonTapped }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        rootView.exitButton.rx.tap
            .bind(with: self) { [weak self] owner, _ in
                owner.showAlert(title: "채널 나가기", message: "정말 채널을 나가시겠습니까?", actions: [
                    ("확인", { [weak self] in
                        self?.reactor?.action.onNext(.exitTapped) })
                ])
            }
            .disposed(by: disposeBag)
        
        rootView.deleteButton.rx.tap
            .bind(with: self) { [weak self] owner, _ in
                owner.showAlert(title: "채널 삭제", message: "정말 채널 삭제하시겠습니까? 삭제 시 멤버/채팅 등 채널 내의 모든 정보가 삭제되고 복구가 불가능합니다.", actions: [
                    ("확인", { [weak self] in
                        self?.reactor?.action.onNext(.deleteTapped) })
                ])
            }
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
        
        let channelStream = reactor.pulse(\.$channel)
            .compactMap { $0 }
            .share()
        
        channelStream
            .map { $0.name }
            .bind(with: self, onNext: { owner, value in
                owner.rootView.channelNameLabel.text = "☕️\(value)"
            })
            .disposed(by: disposeBag)
        
        channelStream
            .map { $0.description }
            .bind(to: rootView.channelDescriptionLabel.rx.text)
            .disposed(by: disposeBag)
        
        channelStream
            .map { $0.channelMembers?.count }
            .bind(with: self) { owner, value in
                owner.rootView.channelMemberCountLabel.text = "멤버 (\(value ?? 0))"
            }
            .disposed(by: disposeBag)
        
        channelStream
            .map {
                print("DEBUG: 채널 멤버 -> \(String(describing: $0.channelMembers))")
                print("DEBUG: 채널 관리자 -> \($0.ownerID)")
                return $0.ownerID
            }
            .bind(with: self) { owner, value in
                guard let loginUserID = UserDefaultsManager.shared.userID else { return }
                //관리자가 아닌 경우는 채널 나가기 메뉴만 제공
                if value == loginUserID {
                    owner.rootView.editButton.isHidden = false
                    owner.rootView.changeAdminButton.isHidden = false
                    owner.rootView.deleteButton.isHidden = false
                } else {
                    owner.rootView.editButton.isHidden = true
                    owner.rootView.changeAdminButton.isHidden = true
                    owner.rootView.deleteButton.isHidden = true
                }
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
        
        channelStream
            .map { $0.channelMembers ?? [] }
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
        
        reactor.pulse(\.$navigateToChannelEdit)
            .compactMap { $0 }
            .bind(with: self) { owner, value in
                owner.coordinator?.showChannelEdit(channel: value)
            }
            .disposed(by: disposeBag)
        
        reactor.pulse(\.$navigateToChannelChangeAdmin)
            .compactMap { $0 }
            .bind(with: self) { owner, value in
                owner.coordinator?.showChannelChangeAdmin(channelID: value)
            }
            .disposed(by: disposeBag)
        
        reactor.pulse(\.$naviageToHome)
            .compactMap { $0 }
            .bind(with: self) { owner, _ in
                owner.coordinator?.didFinishChannelSetting(isNaviageToHome: true)
            }
            .disposed(by: disposeBag)
        
        reactor.pulse(\.$showRetryDeleteFromDBAlert)
            .compactMap { $0 }
            .bind(with: self) { [weak self] owner, _ in
                guard let self else { return }
                owner.showAlert(title: "데이터 정리 실패", message: "채팅 관련 데이터 정리에 실패했습니다. 재시도 해주세요.", actions: [
                    ("확인", { self.reactor?.action.onNext(.retryDeleteFromDB) })
                ], cancelHandler: { self.reactor?.action.onNext(.cancelRetryDeleteFromDB)  })
            }
            .disposed(by: disposeBag)
    }
}

