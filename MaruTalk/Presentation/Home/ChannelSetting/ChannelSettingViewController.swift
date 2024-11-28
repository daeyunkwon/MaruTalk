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
                
    }
}

//MARK: - Bind State

extension ChannelSettingViewController {
    private func bindState(reactor: ChannelSettingReactor) {
        
    }
}

