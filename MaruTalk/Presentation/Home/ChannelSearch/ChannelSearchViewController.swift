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
    weak var coordinator: HomeCoordinator?
    
    init(reactor: ChannelSearchReactor) {
        super.init()
        self.reactor = reactor
    }
    
    private let xMarkButton: UIBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "xmark")?.applyingSymbolConfiguration(.init(pointSize: 14)), style: .plain, target: nil, action: nil)
    
    //MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.tabBarController?.tabBar.isHidden = false
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
    }
}

//MARK: - Bind State

extension ChannelSearchViewController {
    private func bindState(reactor: ChannelSearchReactor) {
        reactor.pulse(\.$shouldNavigateToHome)
            .compactMap { $0 }
            .bind(with: self) { owner, _ in
                owner.coordinator?.didFinishChannelSearch()
            }
            .disposed(by: disposeBag)
    }
}
