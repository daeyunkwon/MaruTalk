//
//  DMChattingViewController.swift
//  MaruTalk
//
//  Created by 권대윤 on 11/30/24.
//

import UIKit

import ReactorKit

final class DMChattingViewController: BaseViewController<ChannelChattingView>, View {
    
    //MARK: - Properties
    
    var disposeBag: DisposeBag = DisposeBag()
    weak var coordinator: DMCoordinator?
    
    init(reactor: DMChattingReactor) {
        super.init()
        self.reactor = reactor
    }
    
    //MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    
    //MARK: - Methods
    
    func bind(reactor: DMChattingReactor) {
        bindAction(reactor: reactor)
        bindState(reactor: reactor)
    }
}

//MARK: - Bind Action

extension DMChattingViewController {
    private func bindAction(reactor: DMChattingReactor) {
        rx.methodInvoked(#selector(viewWillAppear(_:)))
            .map { _ in Reactor.Action.fetch }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
    }
}

//MARK: - Bind State

extension DMChattingViewController {
    private func bindState(reactor: DMChattingReactor) {
        reactor.pulse(\.$navigationTitle)
            .compactMap { $0 }
            .bind(to: navigationItem.rx.title)
            .disposed(by: disposeBag)
        
        reactor.pulse(\.$networkError)
            .compactMap { $0 }
            .bind(with: self) { owner, value in
                owner.showToastForNetworkError(api: value.0, errorCode: value.1)
            }
            .disposed(by: disposeBag)
    }
}
