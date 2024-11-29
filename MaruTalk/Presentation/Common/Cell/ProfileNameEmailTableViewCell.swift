//
//  ProfileNameEmailTableViewCell.swift
//  MaruTalk
//
//  Created by 권대윤 on 11/29/24.
//

import UIKit

import SnapKit

final class ProfileNameEmailTableViewCell: BaseTableViewCell {
    
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
    
    private let emailLabel: UILabel = {
        let label = UILabel()
        label.textColor = Constant.Color.textSecondary
        label.font = Constant.Font.body
        label.numberOfLines = 0
        label.textAlignment = .left
        return label
    }()
    
    //MARK: - Configurations
    
    override func configureHierarchy() {
        contentView.addSubviews(
            profileImageView,
            nicknameLabel,
            emailLabel
        )
    }
    
    override func configureLayout() {
        profileImageView.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(18)
            make.leading.equalToSuperview().inset(14)
            make.size.equalTo(44)
        }
        
        nicknameLabel.snp.makeConstraints { make in
            make.top.equalTo(profileImageView)
            make.leading.equalTo(profileImageView.snp.trailing).offset(11)
            make.trailing.equalToSuperview().inset(14)
        }
        
        emailLabel.snp.makeConstraints { make in
            make.top.equalTo(nicknameLabel.snp.bottom).offset(1)
            make.leading.equalTo(nicknameLabel)
            make.trailing.equalTo(nicknameLabel)
            make.bottom.equalToSuperview().inset(18)
        }
    }
    
    override func configureUI() {
        backgroundColor = .clear
    }
    
    func configureCell(data: User) {
        if let imagePath = data.profileImage {
            profileImageView.setImage(imagePath: imagePath)
        } else {
            profileImageView.image = [UIImage(named: "noPhotoA") ?? UIImage(), UIImage(named: "noPhotoB") ?? UIImage(), UIImage(named: "noPhotoC") ?? UIImage()].randomElement()
        }
        
        nicknameLabel.text = data.nickname
        emailLabel.text = data.email
    }
}
