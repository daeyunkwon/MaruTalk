//
//  MessageThreePhotoTextTableViewCell.swift
//  MaruTalk
//
//  Created by 권대윤 on 11/25/24.
//

import UIKit

import SnapKit

final class MessageThreePhotoTextTableViewCell: BaseTableViewCell {
    
    //MARK: - UI Components
    
    let profileImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.layer.cornerRadius = 34 / 2
        return iv
    }()
    
    let usernameLabel: UILabel = {
        let label = UILabel()
        label.textColor = Constant.Color.brandWhite
        label.font = Constant.Font.caption
        label.textAlignment = .left
        return label
    }()
    
    let messageBodyLabel: UILabel = {
        let label = UILabel()
        label.textColor = Constant.Color.textPrimary
        label.font = Constant.Font.body
        label.textAlignment = .left
        return label
    }()
    
    private let messageBodyBackView: UIView = {
        let view = UIView()
        view.backgroundColor = Constant.Color.brandWhite
        view.layer.cornerRadius = 8
        return view
    }()
    
    let firstPhotoImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.layer.cornerRadius = 12
        iv.layer.maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner]
        return iv
    }()
    
    let secondPhotoImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        return iv
    }()
    
    let thirdPhotoImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.layer.cornerRadius = 12
        iv.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMaxXMaxYCorner]
        return iv
    }()
    
    let timeLabel: UILabel = {
        let label = UILabel()
        label.textColor = Constant.Color.textSecondary
        label.font = Constant.Font.caption
        label.textAlignment = .left
        return label
    }()
    
    //MARK: - Configurations
    
    override func configureHierarchy() {
        contentView.addSubviews(
            profileImageView,
            usernameLabel,
            messageBodyBackView,
            messageBodyLabel,
            firstPhotoImageView,
            secondPhotoImageView,
            thirdPhotoImageView,
            timeLabel
        )
    }
    
    override func configureLayout() {
        profileImageView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(6)
            make.leading.equalToSuperview()
            make.size.equalTo(34)
        }
        
        usernameLabel.snp.makeConstraints { make in
            make.top.equalTo(profileImageView.snp.top)
            make.leading.equalTo(profileImageView.snp.trailing).offset(8)
            make.trailing.equalToSuperview().inset(16)
        }
        
        messageBodyLabel.snp.makeConstraints { make in
            make.top.equalTo(usernameLabel.snp.bottom).offset(13)
            make.leading.equalTo(profileImageView.snp.trailing).offset(16)
            make.trailing.equalToSuperview().inset(16)
        }
        
        messageBodyBackView.snp.makeConstraints { make in
            make.top.equalTo(messageBodyLabel).offset(-8)
            make.leading.equalTo(messageBodyLabel).offset(-8)
            make.trailing.equalTo(messageBodyLabel).offset(8)
            make.bottom.equalTo(messageBodyLabel).offset(8)
        }
        
        firstPhotoImageView.snp.makeConstraints { make in
            make.leading.equalTo(usernameLabel)
            make.top.equalTo(messageBodyBackView).offset(8)
            make.width.equalTo(80)
            make.height.equalTo(80)
        }
        
        secondPhotoImageView.snp.makeConstraints { make in
            make.top.equalTo(firstPhotoImageView)
            make.leading.equalTo(firstPhotoImageView.snp.trailing).offset(2)
            make.width.equalTo(80)
            make.height.equalTo(80)
        }
        
        thirdPhotoImageView.snp.makeConstraints { make in
            make.top.equalTo(firstPhotoImageView)
            make.leading.equalTo(secondPhotoImageView.snp.trailing).offset(2)
            make.width.equalTo(80)
            make.height.equalTo(80)
        }
        
        timeLabel.snp.makeConstraints { make in
            make.leading.equalTo(usernameLabel)
            make.top.equalTo(firstPhotoImageView.snp.bottom).offset(8)
            make.bottom.equalToSuperview().offset(-6)
        }
    }
    
    override func configureUI() {
        
    }
}

