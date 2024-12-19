//
//  ImageTitleCountTableViewCell.swift
//  MaruTalk
//
//  Created by 권대윤 on 11/15/24.
//

import UIKit

import SnapKit

final class DMRoomImageTitleCountTableViewCell: BaseTableViewCell {
    
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
        label.textColor = Constant.Color.textPrimary
        return label
    }()
    
    //MARK: - Configurations
    
    override func configureHierarchy() {
        contentView.addSubviews(
            profileImageView,
            titleLabel
        )
    }
    
    override func configureLayout() {
        profileImageView.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(14)
            make.size.equalTo(24)
            make.centerY.equalToSuperview()
        }
        
        titleLabel.snp.makeConstraints { make in
            make.leading.equalTo(profileImageView.snp.trailing).offset(8)
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview().inset(21)
            make.width.greaterThanOrEqualTo(100)
        }
    }
    
    override func configureUI() {
        backgroundColor = Constant.Color.brandWhite.withAlphaComponent(0.8)
    }
    
    func configure(dm: DMRoom) {
        self.titleLabel.text = dm.user.nickname
        
        if let path = dm.user.profileImage {
            //유저 프로필 이미지 적용
            self.profileImageView.setImage(imagePath: path)
        } else {
            //랜덤 이미지 적용
            self.profileImageView.image = [UIImage(named: "noPhotoA") ?? UIImage(), UIImage(named: "noPhotoB") ?? UIImage(), UIImage(named: "noPhotoC") ?? UIImage()].randomElement()
        }
    }
}
