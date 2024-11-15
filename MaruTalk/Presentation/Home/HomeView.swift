//
//  HomeView.swift
//  MaruTalk
//
//  Created by 권대윤 on 11/14/24.
//

import UIKit

import SnapKit

final class HomeView: BaseView {
    
    //MARK: - UI Components
    
    let emptyView: HomeEmptyView = {
        let view = HomeEmptyView()
        view.isHidden = true
        return view
    }()

    let tableView: UITableView = {
        let tv = UITableView()
        tv.backgroundColor = .systemYellow
        return tv
    }()
    
    //MARK: - Configurations
    
    override func configureHierarchy() {
        addSubviews(
            tableView,
            emptyView
        )
    }
    
    override func configureLayout() {
        tableView.snp.makeConstraints { make in
            make.edges.equalTo(safeAreaLayoutGuide)
        }
        
        emptyView.snp.makeConstraints { make in
            make.top.equalTo(safeAreaLayoutGuide)
            make.horizontalEdges.bottom.equalToSuperview()
        }
    }
    
    override func configureUI() {
        super.configureUI()
    }
}
