//
//  MessageOnePhotoTextTableViewCell.swift
//  MaruTalk
//
//  Created by 권대윤 on 11/25/24.
//

import UIKit

import SnapKit

final class MessageOnePhotoTextTableViewCell: BaseTableViewCell {
    
    //MARK: - UI Components
    
    private let profileImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.layer.cornerRadius = 34 / 2
        return iv
    }()
    
    private let usernameLabel: UILabel = {
        let label = UILabel()
        label.textColor = .darkGray
        label.font = Constant.Font.captionSemiBold
        label.textAlignment = .left
        return label
    }()
    
    private let messageBodyLabel: UILabel = {
        let label = UILabel()
        label.textColor = Constant.Color.textPrimary
        label.font = Constant.Font.body
        label.textAlignment = .left
        label.numberOfLines = 0
        return label
    }()
    
    private let messageBodyBackView: UIView = {
        let view = UIView()
        view.backgroundColor = Constant.Color.brandWhite
        view.layer.cornerRadius = 8
        return view
    }()
    
    private let photoImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.layer.cornerRadius = 12
        return iv
    }()
    
    private let timeLabel: UILabel = {
        let label = UILabel()
        label.textColor = Constant.Color.textSecondary
        label.font = Constant.Font.caption
        label.textAlignment = .left
        return label
    }()
    
    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 5
        stackView.alignment = .leading
        return stackView
    }()
    
    //MARK: - Configurations
    
    override func configureHierarchy() {
        addSubviews(
            profileImageView,
            stackView
        )
        
        stackView.addArrangedSubview(usernameLabel)
        stackView.addArrangedSubview(messageBodyBackView)
        messageBodyBackView.addSubview(messageBodyLabel)
        stackView.addArrangedSubview(photoImageView)
        stackView.addArrangedSubview(timeLabel)
    }
    
    override func configureLayout() {
        profileImageView.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(6)
            make.leading.equalToSuperview().inset(5)
            make.size.equalTo(34)
        }
        
        stackView.snp.makeConstraints { make in
            make.top.equalTo(profileImageView.snp.top)
            make.leading.equalTo(profileImageView.snp.trailing).offset(8)
            make.trailing.equalToSuperview().inset(16)
            make.bottom.equalToSuperview().offset(-6)
        }
        
        messageBodyLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(8)
            make.leading.equalToSuperview().offset(8)
            make.trailing.equalToSuperview().offset(-8)
            make.bottom.equalToSuperview().offset(-8)
        }
        
        photoImageView.snp.makeConstraints { make in
            make.width.equalTo(244)
            make.height.equalTo(160)
        }
    }
    
    override func configureUI() {
        backgroundColor = .clear
        selectionStyle = .none
    }
    
    func configureCell(data: RealmChat) {
        if let profileImagePath = data.user?.profileImage {
            profileImageView.setImage(imagePath: profileImagePath)
        } else {
            profileImageView.image = UIImage(named: "noPhotoA")
        }
        
        usernameLabel.text = data.user?.nickname
        
        if !data.content.trimmingCharacters(in: .whitespaces).isEmpty {
            messageBodyLabel.isHidden = false
            messageBodyBackView.isHidden = false
            messageBodyLabel.text = data.content
        } else {
            messageBodyLabel.isHidden = true
            messageBodyBackView.isHidden = true
        }
        
        if let photo = data.files.first {
            photoImageView.isHidden = false
            photoImageView.setImage(imagePath: photo)
        } else {
            photoImageView.isHidden = true
        }
        
        timeLabel.text = Date.dateToString(date: data.createdAt)
        
        if data.user?.userID == UserDefaultsManager.shared.userID {
            //자신이 보낸 메시지의 경우 오른쪽 배치
            stackView.alignment = .trailing
            usernameLabel.isHidden = true
            profileImageView.isHidden = true
            messageBodyBackView.backgroundColor = Constant.Color.brandBlue
            messageBodyLabel.textColor = Constant.Color.brandWhite
        } else {
            //다른 사람이 보낸 메시지의 경우 왼쪽 배치
            stackView.alignment = .leading
            usernameLabel.isHidden = false
            profileImageView.isHidden = false
            messageBodyBackView.backgroundColor = Constant.Color.brandWhite
            messageBodyLabel.textColor = Constant.Color.textPrimary
        }
    }
}