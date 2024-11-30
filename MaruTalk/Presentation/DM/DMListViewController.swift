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
        
    }
}

//MARK: - Bind State

extension DMListViewController {
    private func bindState(reactor: DMListReactor) {
        
    }
}
