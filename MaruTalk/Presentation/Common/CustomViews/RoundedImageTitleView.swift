//
//  RoundedImageTitleView.swift
//  MaruTalk
//
//  Created by 권대윤 on 11/17/24.
//

import UIKit

import SnapKit
import RxCocoa
import RxSwift

final class RoundedImageTitleView: BaseView {
    
    //MARK: - Properties
    
    var rxTap: ControlEvent<Void> {
        return button.rx.tap
    }
    
    //MARK: - UI Components
    
    let photoImageView: UIImageView = {
        let iv = UIImageView()
        iv.layer.cornerRadius = 8
        iv.backgroundColor = .lightGray
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        return iv
    }()
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "No Workspace"
        label.font = Constant.Font.title1
        label.textColor = Constant.Color.brandBlack
        return label
    }()
    
    let button = UIButton(type: .custom)
    
    //MARK: - Configurations
    
    override func configureHierarchy() {
        addSubviews(
            photoImageView,
            titleLabel,
            button
        )
    }
    
    override func configureLayout() {
        photoImageView.snp.makeConstraints { make in
            make.size.equalTo(32)
            make.leading.equalToSuperview()
            make.centerY.equalToSuperview()
        }
        
        titleLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalTo(photoImageView.snp.trailing).offset(8)
            make.trailing.equalToSuperview()
        }
        
        button.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    override func configureUI() {
        backgroundColor = Constant.Color.brandWhite
    }
}
