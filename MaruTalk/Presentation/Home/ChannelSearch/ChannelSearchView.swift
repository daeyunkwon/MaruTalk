//
//  ChannelSearchView.swift
//  MaruTalk
//
//  Created by 권대윤 on 11/27/24.
//

import UIKit

import SnapKit

final class ChannelSearchView: BaseView {
    
    //MARK: - UI Components
    
    let tableView: UITableView = {
        let tv = UITableView()
        tv.register(HashTitleCountTableViewCell.self, forCellReuseIdentifier: HashTitleCountTableViewCell.reuseIdentifier)
        tv.separatorStyle = .none
        tv.backgroundColor = .yellow
        tv.rowHeight = UITableView.automaticDimension
        return tv
    }()
    
    //MARK: - Configurations
    
    override func configureHierarchy() {
        addSubview(tableView)
    }
    
    override func configureLayout() {
        tableView.snp.makeConstraints { make in
            make.top.horizontalEdges.equalTo(safeAreaLayoutGuide)
            make.bottom.equalToSuperview()
        }
    }
}
