//
//  ChannelChangeAdminView.swift
//  MaruTalk
//
//  Created by 권대윤 on 11/29/24.
//

import UIKit

import SnapKit

final class ChannelChangeAdminView: BaseView {
    
    //MARK: - UI Components
    
    let tableView: UITableView = {
        let tv = UITableView()
        tv.backgroundColor = Constant.Color.backgroundPrimary
        tv.separatorStyle = .none
        tv.rowHeight = UITableView.automaticDimension
        tv.register(ProfileNameEmailTableViewCell.self, forCellReuseIdentifier: ProfileNameEmailTableViewCell.reuseIdentifier)
        return tv
    }()
    
    //MARK: - Configurations
    
    override func configureHierarchy() {
        addSubview(tableView)
    }
    
    override func configureLayout() {
        tableView.snp.makeConstraints { make in
            make.top.equalTo(safeAreaLayoutGuide)
            make.horizontalEdges.bottom.equalToSuperview()
        }
    }
    
    override func configureUI() {
        super.configureUI()
    }
}
