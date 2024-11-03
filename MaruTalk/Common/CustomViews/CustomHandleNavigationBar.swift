//
//  CustomHandleNavigationBar.swift
//  MaruTalk
//
//  Created by 권대윤 on 11/3/24.
//

import UIKit

import SnapKit

final class CustomHandleNavigationBar: UINavigationBar {
    
    //MARK: - UI Components
    
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = Constant.Color.backgroundSecondary
        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        view.layer.cornerRadius = 9
        return view
    }()
    
    private let handleView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.gray.withAlphaComponent(0.5)
        view.layer.cornerRadius = 2.5
        return view
    }()
    
    //MARK: - Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureHierarchy()
        configureLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Configurations
    
    private func configureHierarchy() {
        addSubview(containerView)
        containerView.addSubview(handleView)
    }
    
    private func configureLayout() {
        containerView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(-5)
            make.horizontalEdges.equalToSuperview()
            make.height.equalTo(15)
        }
        
        handleView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.equalTo(36)
            make.height.equalTo(5)
        }
    }
}
