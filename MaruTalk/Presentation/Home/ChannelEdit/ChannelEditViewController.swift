//
//  ChannelEditViewController.swift
//  MaruTalk
//
//  Created by 권대윤 on 11/28/24.
//

import UIKit

import ReactorKit
import RxCocoa

final class ChannelEditViewController: BaseViewController<ChannelEditView>, View {
    
    //MARK: - Properties
    
    var disposeBag: DisposeBag = DisposeBag()
    weak var coordinator: HomeCoordinator?
    
    init(reactor: ChannelEditReactor) {
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
        navigationItem.title = "채널 편집"
        navigationItem.leftBarButtonItem = xMarkButton
    }
    
    //MARK: - Methods
    
    func bind(reactor: ChannelEditReactor) {
        bindAction(reactor: reactor)
        bindState(reactor: reactor)
    }
}

//MARK: - Bind Action

extension ChannelEditViewController {
    private func bindAction(reactor: ChannelEditReactor) {
        xMarkButton.rx.tap
            .map { Reactor.Action.xMarkButtonTapped }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
    }
}

//MARK: - Bind State

extension ChannelEditViewController {
    private func bindState(reactor: ChannelEditReactor) {
        
    }
}
