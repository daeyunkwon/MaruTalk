//
//  DMListViewController.swift
//  MaruTalk
//
//  Created by 권대윤 on 11/14/24.
//

import UIKit

import ReactorKit
import RxCocoa

final class DMListViewController: BaseViewController<DMListView>, View {
    
    //MARK: - Properties
    
    var disposeBag = DisposeBag()
    weak var coordinator: DMCoordinator?
    
    init(reactor: DMListReactor) {
        super.init()
        self.reactor = reactor
    }
    
    private let profileCircleView = ProfileCircleView()
    private let navigationTitleView: RoundedImageTitleView = {
        let view = RoundedImageTitleView()
        view.photoImageView.isHidden = true
        view.titleLabel.text = "Direct Message"
        return view
    }()
    
    //MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    //MARK: - Configurations
 
    override func setupNavi() {
        navigationItem.title = ""
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: navigationTitleView)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: profileCircleView)
    }
    
    //MARK: - Methods
    
    func bind(reactor: DMListReactor) {
        bindAction(reactor: reactor)
        bindState(reactor: reactor)
    }
}

//MARK: - Bind Action

extension DMListViewController {
    private func bindAction(reactor: DMListReactor) {
        rx.methodInvoked(#selector(viewWillAppear(_:)))
            .map { _ in Reactor.Action.fetch }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        rootView.collectionView.rx.modelSelected(User.self)
            .map { Reactor.Action.selectMember($0) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        rootView.tableView.rx.modelSelected(Chat.self)
            .map { Reactor.Action.selectChat($0) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
    }
}

//MARK: - Bind State

extension DMListViewController {
    private func bindState(reactor: DMListReactor) {
        reactor.pulse(\.$networkError)
            .compactMap { $0 }
            .bind(with: self) { owner, value in
                owner.showToastForNetworkError(api: value.0, errorCode: value.1)
            }
            .disposed(by: disposeBag)
        
        reactor.pulse(\.$memberList)
            .compactMap { $0 }
            .map { !$0.isEmpty }
            .bind(to: rootView.emptyView.rx.isHidden)
            .disposed(by: disposeBag)
        
        reactor.pulse(\.$memberList)
            .compactMap { $0 }
            .bind(to: rootView.collectionView.rx.items(cellIdentifier: ProfileCircleImageTitleCollectionViewCell.reuseIdentifier, cellType: ProfileCircleImageTitleCollectionViewCell.self)) { row, element, cell in
                cell.configureCell(data: element)
            }
            .disposed(by: disposeBag)
        
        reactor.pulse(\.$user)
            .compactMap { $0 }
            .bind(with: self) { owner, value in
                if value.profileImage != nil {
                    owner.profileCircleView.profileImageView.setImage(imagePath: value.profileImage)
                } else {
                    owner.profileCircleView.profileImageView.image = UIImage(named: "noPhotoA")
                }
            }
            .disposed(by: disposeBag)
        
        reactor.pulse(\.$dmRoomList)
            .compactMap { $0 }
            .bind(to: rootView.tableView.rx.items(cellIdentifier: ProfileNameMessageTableViewCell.reuseIdentifier, cellType: ProfileNameMessageTableViewCell.self)) { row, element, cell in
                cell.configureCell(data: element)
            }
            .disposed(by: disposeBag)
        
        reactor.pulse(\.$shouldNavigateToDMChatting)
            .compactMap { $0 }
            .bind(with: self) { owner, value in
                owner.coordinator?.showDMChatting(roomID: value.roomID, otherUserID: value.user.userID)
            }
            .disposed(by: disposeBag)
    }
}
