//
//  DMListView.swift
//  MaruTalk
//
//  Created by 권대윤 on 11/14/24.
//

import UIKit

import SnapKit

final class DMListView: BaseView {
    
    //MARK: - UI Components
    
    let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = .init(width: 76, height: 90)
        layout.minimumLineSpacing = 0
        layout.sectionInset = .init(top: 16, left: 0, bottom: 0, right: 0)
        
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.register(ProfileCircleImageTitleCollectionViewCell.self, forCellWithReuseIdentifier: ProfileCircleImageTitleCollectionViewCell.reuseIdentifier)
        cv.backgroundColor = Constant.Color.brandWhite
        cv.showsHorizontalScrollIndicator = false
        return cv
    }()
    
    private let separatorLineView: UIView = {
        let view = UIView()
        view.backgroundColor = Constant.Color.viewSeparator
        return view
    }()
    
    private let tableView: UITableView = {
        let tv = UITableView()
        tv.separatorStyle = .none
        tv.backgroundColor = Constant.Color.brandWhite
        tv.register(ProfileNameMessageTableViewCell.self, forCellReuseIdentifier: ProfileNameMessageTableViewCell.reuseIdentifier)
        return tv
    }()
    
    let emptyView = DMListEmptyView()
    
    //MARK: - Configurations
    
    override func configureHierarchy() {
        addSubviews(
            collectionView,
            separatorLineView,
            tableView,
            emptyView
        )
    }
    
    override func configureLayout() {
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(safeAreaLayoutGuide)
            make.horizontalEdges.equalToSuperview()
            make.height.equalTo(90)
        }
        
        separatorLineView.snp.makeConstraints { make in
            make.top.equalTo(collectionView.snp.bottom)
            make.horizontalEdges.equalToSuperview()
            make.height.equalTo(1)
        }
        
        tableView.snp.makeConstraints { make in
            make.top.equalTo(separatorLineView.snp.bottom)
            make.horizontalEdges.equalToSuperview()
            make.bottom.equalTo(safeAreaLayoutGuide)
        }
        
        emptyView.snp.makeConstraints { make in
            make.top.bottom.equalTo(safeAreaLayoutGuide)
            make.horizontalEdges.equalToSuperview()
        }
    }
    
    override func configureUI() {
        backgroundColor = Constant.Color.brandWhite
    }
}
