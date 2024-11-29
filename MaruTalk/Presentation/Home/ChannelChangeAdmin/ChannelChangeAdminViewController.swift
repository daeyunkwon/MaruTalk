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
        
    }
}

//MARK: - Bind State

extension ChannelChangeAdminViewController {
    private func bindState(reactor: ChannelChangeAdminReactor) {
        
    }
}
