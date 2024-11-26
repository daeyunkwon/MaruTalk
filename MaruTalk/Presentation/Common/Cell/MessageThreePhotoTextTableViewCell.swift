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
    
    private let firstPhotoImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.layer.cornerRadius = 12
        iv.layer.maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner]
        return iv
    }()
    
    private let secondPhotoImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        return iv
    }()
    
    private let thirdPhotoImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.layer.cornerRadius = 12
        iv.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMaxXMaxYCorner]
        return iv
    }()
    
    private let timeLabel: UILabel = {
        let label = UILabel()
        label.textColor = Constant.Color.textSecondary
        label.font = .systemFont(ofSize: 10, weight: .regular)
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
    
    private let photoStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 2.5
        return stackView
    }()
    
    //MARK: - Configurations
    
    override func configureHierarchy() {
        contentView.addSubviews(
            profileImageView,
            stackView
        )
        
        photoStackView.addArrangedSubview(firstPhotoImageView)
        photoStackView.addArrangedSubview(secondPhotoImageView)
        photoStackView.addArrangedSubview(thirdPhotoImageView)
        
        stackView.addArrangedSubview(usernameLabel)
        stackView.addArrangedSubview(messageBodyBackView)
        messageBodyBackView.addSubview(messageBodyLabel)
        stackView.addArrangedSubview(photoStackView)
        stackView.addArrangedSubview(timeLabel)
    }
    
    override func configureLayout() {
        profileImageView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(6)
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
        
        firstPhotoImageView.snp.makeConstraints { make in
            make.width.equalTo(80)
            make.height.equalTo(80)
        }
        
        secondPhotoImageView.snp.makeConstraints { make in
            make.width.equalTo(80)
            make.height.equalTo(80)
        }
        
        thirdPhotoImageView.snp.makeConstraints { make in
            make.width.equalTo(80)
            make.height.equalTo(80)
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
        
        if !data.files.isEmpty {
            firstPhotoImageView.isHidden = false
            secondPhotoImageView.isHidden = false
            thirdPhotoImageView.isHidden = false
            for path in data.files {
                firstPhotoImageView.setImage(imagePath: path)
                secondPhotoImageView.setImage(imagePath: path)
                thirdPhotoImageView.setImage(imagePath: path)
            }
        } else {
            firstPhotoImageView.isHidden = true
            secondPhotoImageView.isHidden = true
            thirdPhotoImageView.isHidden = true
        }
        
        timeLabel.setTimeString(date: data.createdAt)
        
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

