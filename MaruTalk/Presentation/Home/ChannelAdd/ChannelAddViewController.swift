//
//  ChannelAddViewController.swift
//  MaruTalk
//
//  Created by 권대윤 on 11/23/24.
//

import UIKit

import ReactorKit
import RxCocoa

final class ChannelAddViewController: BaseViewController<ChannelAddView>, View {
    
    //MARK: - Properties
    
    var disposeBag: DisposeBag = DisposeBag()
    weak var coordinator: HomeCoordinator?
    
    init(reactor: ChannelAddReactor) {
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
        navigationItem.title = "채널 만들기"
        navigationItem.leftBarButtonItem = xMarkButton
    }
    
    //MARK: - Methods
    
    func bind(reactor: ChannelAddReactor) {
        bindAction(reactor: reactor)
        bindState(reactor: reactor)
    }
}

//MARK: - Bind Action

extension ChannelAddViewController {
    private func bindAction(reactor: ChannelAddReactor) {
        xMarkButton.rx.tap
            .map { Reactor.Action.xMarkButtonTapped }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        rootView.channelNameFieldView.inputTextField.rx.text.orEmpty
            .map { Reactor.Action.inputName($0) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        rootView.channelDescriptionFieldView.inputTextField.rx.text.orEmpty
            .map { Reactor.Action.inputDescription($0) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        rootView.createButton.rx.tap
            .map { Reactor.Action.createButtonTapped }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
    }
}

//MARK: - Bind State

extension ChannelAddViewController {
    private func bindState(reactor: ChannelAddReactor) {
        reactor.pulse(\.$shouldDismiss)
            .compactMap { $0 }
            .bind(with: self) { owner, _ in
                owner.coordinator?.didFinishChannelAdd()
            }
            .disposed(by: disposeBag)
        
        reactor.state.map { $0.isCreateButtonEnabled }
            .distinctUntilChanged()
            .bind(with: self) { owner, value in
                owner.rootView.createButton.setButtonEnabled(isEnabled: value)
            }
            .disposed(by: disposeBag)
        
        reactor.pulse(\.$networkError)
            .compactMap { $0 }
            .bind(with: self) { owner, value in
                owner.showToastForNetworkError(api: value.0, errorCode: value.1)
            }
            .disposed(by: disposeBag)
    }
}
