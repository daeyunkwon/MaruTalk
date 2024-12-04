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
        view.backgroundColor = Constant.Color.brandWhite
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
    
    //MARK: - Configurations
    
    override func configureHierarchy() {
        addSubview(shadowBackView)
        shadowBackView.addSubview(containerView)
        containerView.addSubview(titleLabel)
        addSubview(shadowBackViewTapButton)
    }
    
    override func configureLayout() {
        shadowBackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        containerView.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.width.equalTo(300)
            make.leading.equalToSuperview().offset(-300)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        
        shadowBackViewTapButton.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.trailing.equalToSuperview()
            make.width.equalTo(0)
        }
    }
    
    override func configureUI() {
        backgroundColor = .clear
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let screenWidth = bounds.width
        shadowBackViewTapButton.snp.updateConstraints { make in
            make.width.equalTo(screenWidth - 300)
        }
    }
}
