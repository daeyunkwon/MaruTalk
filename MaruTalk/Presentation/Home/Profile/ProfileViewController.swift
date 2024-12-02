//
//  ProfileViewController.swift
//  MaruTalk
//
//  Created by 권대윤 on 12/2/24.
//

import UIKit

import ReactorKit
import RxCocoa
import RxDataSources

final class ProfileViewController: BaseViewController<ProfileView>, View {
    
    //MARK: - Properties
    
    var disposeBag: DisposeBag = DisposeBag()
    weak var coordinator: Coordinator?
    
    init(reactor: ProfileReactor) {
        super.init()
        self.reactor = reactor
    }
    
    private var dataSource: RxTableViewSectionedAnimatedDataSource<ProfileSectionModel>?
    
    //MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        tabBarController?.tabBar.isHidden = false
    }
    
    //MARK: - Configurations
    
    override func setupNavi() {
        navigationItem.title = "내 정보 수정"
    }
    
    //MARK: - Methods
    
    func bind(reactor: ProfileReactor) {
        bindAction(reactor: reactor)
        bindState(reactor: reactor)
    }
}

//MARK: - Bind Action

extension ProfileViewController {
    private func bindAction(reactor: ProfileReactor) {
        
        
        
        
    }
}

//MARK: - Bind State

extension ProfileViewController {
    private func bindState(reactor: ProfileReactor) {
        let dataSource = RxTableViewSectionedAnimatedDataSource<ProfileSectionModel>(
            configureCell: { datasource, tableView, indexPath, item in
                guard let cell = tableView.dequeueReusableCell(withIdentifier: ProfileSettingTableViewCell.reuseIdentifier) as? ProfileSettingTableViewCell else {
                    return UITableViewCell()
                }
                
                cell.settingNameLabel.text = item.title
                cell.settingValueLabel.text = item.subTitle
                return cell
            }
        )
        
        reactor.pulse(\.$sections)
            .bind(to: rootView.tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
        
        
        
    }
}
