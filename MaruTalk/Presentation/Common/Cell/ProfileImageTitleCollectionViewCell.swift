//
//  ProfileImageTitleCollectionViewCell.swift
//  MaruTalk
//
//  Created by 권대윤 on 11/28/24.
//

import UIKit

import SnapKit

final class ProfileImageTitleCollectionViewCell: BaseCollectionViewCell {
    
    //MARK: - UI Components
    
    private let profileImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.layer.cornerRadius = 8
        return iv
    }()
    
    private let nicknameLabel: UILabel = {
        let label = UILabel()
        label.textColor = Constant.Color.textPrimary
        label.font = Constant.Font.body
        label.numberOfLines = 2
        label.textAlignment = .center
        return label
    }()
    
    //MARK: - Configurations
    
    override func configureHierarchy() {
        contentView.addSubviews(
            profileImageView,
            nicknameLabel
        )
    }
    
    override func configureLayout() {
        profileImageView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.size.equalTo(44)
            make.centerX.equalToSuperview()
        }
        
        nicknameLabel.snp.makeConstraints { make in
            make.top.equalTo(profileImageView.snp.bottom).offset(4)
            make.horizontalEdges.equalToSuperview().inset(4)
            make.bottom.equalToSuperview()
        }
    }
    
    func configureCell(data: User) {
        if let imagePath = data.profileImage {
            profileImageView.setImage(imagePath: data.profileImage)
        } else {
            let placeholderImages: [UIImage] = [UIImage(named: "noPhotoA") ?? UIImage(), UIImage(named: "noPhotoB") ?? UIImage(), UIImage(named: "noPhotoC") ?? UIImage()]
            profileImageView.image = placeholderImages.randomElement()
        }
        
        nicknameLabel.text = data.nickname
    }
}
