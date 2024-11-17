//
//  ImageTitleCountTableViewCell.swift
//  MaruTalk
//
//  Created by 권대윤 on 11/15/24.
//

import UIKit

import SnapKit

final class ImageTitleCountTableViewCell: BaseTableViewCell {
    
    //MARK: - UI Components
    
    private let profileImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.layer.cornerRadius = 4
        iv.backgroundColor = .lightGray
        return iv
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = Constant.Font.body
        label.textAlignment = .left
        
        return label
    }()
    
    private let countBackView: UIView = {
        let view = UIView()
        view.backgroundColor = Constant.Color.brandGreen
        view.clipsToBounds = true
        view.layer.cornerRadius = 8
        return view
    }()
    
    private let countLabel: UILabel = {
        let label = UILabel()
        label.textColor = Constant.Color.brandWhite
        label.font = Constant.Font.caption
        label.textAlignment = .center
        label.text = "88"
        return label
    }()
    
    //MARK: - Configurations
    
    override func configureHierarchy() {
        contentView.addSubviews(
            profileImageView,
            countBackView,
            countLabel,
            titleLabel
        )
    }
    
    override func configureLayout() {
        profileImageView.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(14)
            make.size.equalTo(24)
            make.centerY.equalToSuperview()
        }
        
        countLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview().inset(21)
        }
        
        countBackView.snp.makeConstraints { make in
            make.top.equalTo(countLabel.snp.top).offset(-2)
            make.bottom.equalTo(countLabel.snp.bottom).offset(2)
            make.leading.equalTo(countLabel.snp.leading).offset(-4)
            make.trailing.equalTo(countLabel.snp.trailing).offset(4)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.leading.equalTo(profileImageView.snp.trailing).offset(8)
            make.centerY.equalToSuperview()
            make.trailing.equalTo(countBackView.snp.leading).offset(-8)
            make.width.greaterThanOrEqualTo(100)
        }
    }
    
    override func configureUI() {
        backgroundColor = Constant.Color.brandWhite
    }
    
    func configure(title: String) {
        self.titleLabel.text = title
    }
}
