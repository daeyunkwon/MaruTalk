//
//  ProfileNameMessageTableViewCell.swift
//  MaruTalk
//
//  Created by 권대윤 on 11/30/24.
//

import UIKit

import SnapKit

final class ProfileNameMessageTableViewCell: BaseTableViewCell {
    
    //MARK: - UI Components
    
    private let profileImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.layer.cornerRadius = 8
        iv.backgroundColor = .lightGray
        return iv
    }()
    
    private let nicknameLabel: UILabel = {
        let label = UILabel()
        label.textColor = Constant.Color.textPrimary
        label.font = Constant.Font.bodyBold
        label.numberOfLines = 0
        label.textAlignment = .left
        return label
    }()
    
    private let messageContentLabel: UILabel = {
        let label = UILabel()
        label.textColor = Constant.Color.textSecondary
        label.font = Constant.Font.caption
        label.textAlignment = .left
        label.numberOfLines = 2
        return label
    }()
    
    private let timeLabel: UILabel = {
        let label = UILabel()
        label.textColor = Constant.Color.textSecondary
        label.font = Constant.Font.caption
        label.textAlignment = .right
        return label
    }()
    
    private let countBackView: UIView = {
        let view = UIView()
        view.backgroundColor = Constant.Color.brandColor
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
            timeLabel,
            nicknameLabel,
            countBackView,
            countLabel,
            messageContentLabel
        )
    }
    
    override func configureLayout() {
        profileImageView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(16)
            make.leading.equalToSuperview().offset(16)
            make.size.equalTo(36)
        }
        
        timeLabel.snp.makeConstraints { make in
            make.top.equalTo(profileImageView)
            make.trailing.equalToSuperview().offset(-16)
        }
        
        nicknameLabel.snp.makeConstraints { make in
            make.top.equalTo(profileImageView)
            make.leading.equalTo(profileImageView.snp.trailing).offset(8)
            make.trailing.equalTo(timeLabel.snp.leading).offset(-8)
        }
        
        countBackView.snp.makeConstraints { make in
            make.top.equalTo(countLabel).offset(-2)
            make.bottom.equalTo(countLabel).offset(2)
            make.leading.equalTo(countLabel).offset(-4)
            make.trailing.equalTo(countLabel).offset(4)
        }
        
        countLabel.snp.makeConstraints { make in
            make.top.equalTo(timeLabel.snp.bottom).offset(2)
            make.trailing.equalTo(timeLabel.snp.trailing).offset(-5)
        }
        
        messageContentLabel.snp.makeConstraints { make in
            make.top.equalTo(nicknameLabel.snp.bottom).offset(8)
            make.leading.equalTo(nicknameLabel)
            make.bottom.equalToSuperview().offset(-16)
        }
    }
    
    override func configureUI() {
        backgroundColor = .clear
    }
    
    func configureCell(data: Chat) {
        if data.user.profileImage != nil {
            profileImageView.setImage(imagePath: data.user.profileImage)
        } else {
            profileImageView.image = UIImage(named: "noPhotoA")
        }
        
        nicknameLabel.text = data.user.nickname
        messageContentLabel.text = data.content
        timeLabel.setTimeString(date: Date.createdDate(dateString: data.createdAt), shouldShowYear: true)
    }
}
