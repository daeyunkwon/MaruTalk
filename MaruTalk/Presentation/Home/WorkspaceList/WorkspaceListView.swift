//
//  WorkspaceListView.swift
//  MaruTalk
//
//  Created by 권대윤 on 12/3/24.
//

import UIKit

import SnapKit
import RxCocoa

final class WorkspaceListView: BaseView {
    
    //MARK: - Properties
    
    //우측 어두운 그림자 영역을 탭 했을 때를 감지하는 용도
    var shadowBackViewRxTap: ControlEvent<Void> {
        return shadowBackViewTapButton.rx.tap
    }
    
    //MARK: - UI Components
    
    private let shadowBackView: UIView = {
        let view = UIView()
        view.backgroundColor = .black.withAlphaComponent(0.5)
        return view
    }()
    
    let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = Constant.Color.backgroundPrimary
        view.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMaxXMaxYCorner]
        view.layer.masksToBounds = true
        view.layer.cornerRadius = 20
        return view
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = Constant.Font.title1
        label.textColor = Constant.Color.textPrimary
        label.text = "워크스페이스"
        return label
    }()
    
    private let shadowBackViewTapButton: UIButton = {
        let btn = UIButton(type: .system)
        return btn
    }()
    
    let tableView: UITableView = {
        let tv = UITableView()
        tv.separatorStyle = .none
        tv.backgroundColor = Constant.Color.brandWhite
        tv.register(WorkspaceListTableViewCell.self, forCellReuseIdentifier: WorkspaceListTableViewCell.reuseIdentifier)
        tv.rowHeight = 75
        return tv
    }()
    
    let emptyLabel: UILabel = {
        let label = UILabel()
        let text = "워크스페이스를 찾을 수 없어요.\n관리자에게 초대를 요청하거나, 새로운 워크스페이스를 생성해주세요."
        label.setTextFontWithLineHeight(text: text, font: Constant.Font.bodyBold, lineHeight: Constant.Font.LineHeight.bodyBold)
        label.numberOfLines = 0
        label.font = Constant.Font.bodyBold
        label.textColor = Constant.Color.textPrimary
        label.textAlignment = .center
        return label
    }()
    
    let workspaceAddButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("   워크스페이스 추가", for: .normal)
        btn.setImage(UIImage(systemName: "plus.app")?.applyingSymbolConfiguration(.init(font: Constant.Font.body)), for: .normal)
        btn.tintColor = Constant.Color.textSecondary
        btn.titleLabel?.font = Constant.Font.body
        btn.contentHorizontalAlignment = .leading
        return btn
    }()
    
    //MARK: - Configurations
    
    override func configureHierarchy() {
        addSubview(shadowBackView)
        addSubview(shadowBackViewTapButton)
        shadowBackView.addSubview(containerView)
        containerView.addSubviews(
            titleLabel,
            tableView,
            emptyLabel,
            workspaceAddButton
        )
    }
    
    override func configureLayout() {
        shadowBackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        shadowBackViewTapButton.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.trailing.equalToSuperview()
            make.width.equalTo(0)
        }
        
        containerView.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.width.equalTo(300) //임시
            make.leading.equalToSuperview().offset(-300) //임시
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(64)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(16)
        }
        
        tableView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(17)
            make.horizontalEdges.equalToSuperview()
            make.bottom.equalToSuperview().offset(-100)
        }
        
        emptyLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.horizontalEdges.equalToSuperview().inset(16)
        }
        
        workspaceAddButton.snp.makeConstraints { make in
            make.top.equalTo(tableView.snp.bottom).offset(20)
            make.horizontalEdges.equalToSuperview().inset(16)
        }
    }
    
    override func configureUI() {
        backgroundColor = .clear
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let screenWidth = bounds.width
        
        let containerWidth = bounds.width - (bounds.width / 4)
        
        shadowBackViewTapButton.snp.updateConstraints { make in
            make.width.equalTo(screenWidth - containerWidth)
        }
        
        containerView.snp.updateConstraints { make in
            make.width.equalTo(containerWidth)
            make.leading.equalToSuperview().offset(-containerWidth)
        }
    }
}
