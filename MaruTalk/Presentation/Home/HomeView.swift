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
        let tv = UITableView(frame: .zero, style: .grouped)
        tv.register(PlusTitleTableViewCell.self, forCellReuseIdentifier: PlusTitleTableViewCell.reuseIdentifier)
        tv.register(HashTitleCountTableViewCell.self, forCellReuseIdentifier: HashTitleCountTableViewCell.reuseIdentifier)
        tv.register(ImageTitleCountTableViewCell.self, forCellReuseIdentifier: ImageTitleCountTableViewCell.reuseIdentifier)
        tv.register(DropdownArrowTableViewCell.self, forHeaderFooterViewReuseIdentifier: DropdownArrowTableViewCell.reuseIdentifier)
        tv.register(PlusTitleHeaderTableViewCell.self, forHeaderFooterViewReuseIdentifier: PlusTitleHeaderTableViewCell.reuseIdentifier)
        tv.backgroundColor = Constant.Color.brandWhite
        tv.sectionFooterHeight = 0 //섹션 상단 빈 여백 제거하기
        tv.rowHeight = 41
        tv.sectionHeaderHeight = 56
        tv.separatorStyle = .none
        return tv
    }()
    
    let newMessageButton: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setImage(UIImage(systemName: "plus.message"), for: .normal)
        btn.imageView?.contentMode = .scaleAspectFill
        btn.backgroundColor = Constant.Color.brandColor
        btn.tintColor = Constant.Color.brandWhite
        btn.layer.cornerRadius = 54 / 2
        btn.layer.shadowRadius = 3
        btn.layer.shadowOpacity = 0.3
        btn.layer.shadowOffset = .init(width: 0, height: 1)
        return btn
    }()
    
    //MARK: - Configurations
    
    override func configureHierarchy() {
        addSubviews(
            tableView,
            newMessageButton,
            emptyView
        )
    }
    
    override func configureLayout() {
        tableView.snp.makeConstraints { make in
            make.edges.equalTo(safeAreaLayoutGuide)
        }
        
        newMessageButton.snp.makeConstraints { make in
            make.trailing.bottom.equalTo(safeAreaLayoutGuide).inset(16)
            make.size.equalTo(54)
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
