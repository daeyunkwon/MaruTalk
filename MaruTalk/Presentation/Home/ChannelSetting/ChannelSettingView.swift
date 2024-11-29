//
//  ChannelSettingView.swift
//  MaruTalk
//
//  Created by 권대윤 on 11/28/24.
//

import UIKit

import SnapKit

final class ChannelSettingView: BaseView {
    
    //MARK: - UI Components
    
    let channelNameLabel: UILabel = {
        let label = UILabel()
        label.font = Constant.Font.title2
        label.textColor = Constant.Color.textPrimary
        label.textAlignment = .left
        label.numberOfLines = 0
        return label
    }()
    
    let channelDescriptionLabel: UILabel = {
        let label = UILabel()
        label.font = Constant.Font.body
        label.textColor = Constant.Color.textPrimary
        label.textAlignment = .left
        label.numberOfLines = 0
        return label
    }()
    
    let channelMemberCountLabel: UILabel = {
        let label = UILabel()
        label.font = Constant.Font.title2
        label.textColor = Constant.Color.textPrimary
        label.textAlignment = .left
        return label
    }()
    
    let arrowIconButton: UIButton = {
        let btn = UIButton(type: .system)
        let image = UIImage(named: "chevron_down")?.withRenderingMode(.alwaysOriginal)
        btn.setImage(image , for: .normal)
        return btn
    }()
    
    let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize

        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.register(ProfileImageTitleCollectionViewCell.self, forCellWithReuseIdentifier: ProfileImageTitleCollectionViewCell.reuseIdentifier)
        cv.isScrollEnabled = false
        cv.backgroundColor = .clear
        return cv
    }()
    
    let editButton = RoundedWhiteBackOutlineButton(title: "채널 편집")
    let exitButton = RoundedWhiteBackOutlineButton(title: "채널 나가기")
    let changeAdminButton = RoundedWhiteBackOutlineButton(title: "채널 관리자 변경")
    let deleteButton = RoundedWhiteBackOutlineButton(title: "채널 삭제", color: Constant.Color.brandRed)
    
    private let scrollView: UIScrollView = UIScrollView()
    
    private let stackView: UIStackView = {
        let sv = UIStackView()
        sv.axis = .vertical
        sv.spacing = 8
        sv.alignment = .fill
        return sv
    }()
    
    private let memberCountStackView: UIStackView = {
        let sv = UIStackView()
        sv.axis = .horizontal
        sv.alignment = .fill
        return sv
    }()
    
    private let roundedButtonStackView: UIStackView = {
        let sv = UIStackView()
        sv.axis = .vertical
        sv.spacing = 8
        sv.distribution = .fillEqually
        return sv
    }()
    
    //MARK: - Configurations
    
    override func configureHierarchy() {
        addSubview(scrollView)
        scrollView.addSubview(stackView)
        scrollView.addSubview(roundedButtonStackView)
        
        stackView.addArrangedSubview(channelNameLabel)
        stackView.addArrangedSubview(channelDescriptionLabel)
        stackView.addArrangedSubview(memberCountStackView)
        stackView.addArrangedSubview(collectionView)
        
        memberCountStackView.addArrangedSubview(channelMemberCountLabel)
        memberCountStackView.addArrangedSubview(arrowIconButton)
        
        roundedButtonStackView.addArrangedSubview(editButton)
        roundedButtonStackView.addArrangedSubview(exitButton)
        roundedButtonStackView.addArrangedSubview(changeAdminButton)
        roundedButtonStackView.addArrangedSubview(deleteButton)
    }
    
    override func configureLayout() {
        scrollView.snp.makeConstraints { make in
            make.top.equalTo(safeAreaLayoutGuide)
            make.horizontalEdges.bottom.equalToSuperview()
        }
        
        stackView.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(16)
            make.horizontalEdges.equalToSuperview().inset(16)
            
            if let window = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                make.width.equalTo(window.screen.bounds.width - 32)
            } else {
                make.width.equalTo(UIScreen.main.bounds.width - 32)
            }
        }
        
        roundedButtonStackView.snp.makeConstraints { make in
            make.top.equalTo(stackView.snp.bottom).offset(16)
            make.bottom.equalToSuperview().inset(16)
            make.horizontalEdges.equalTo(stackView).inset(24)
        }
        
        exitButton.snp.makeConstraints { make in
            make.height.equalTo(44)
        }
        
        arrowIconButton.snp.makeConstraints { make in
            make.size.equalTo(24)
        }
    }
    
    override func configureUI() {
        super.configureUI()
    }
    
    func updateDisplayMemberCollection(isExpand: Bool) {
        if isExpand {
            self.collectionView.alpha = 0.0
            UIView.animate(withDuration: 0.3) { [weak self] in
                guard let self else { return }
                self.arrowIconButton.transform = CGAffineTransform.identity
                self.collectionView.alpha = 1.0
                self.collectionView.isHidden = false
            }
        } else {
            self.collectionView.alpha = 1.0
            UIView.animate(withDuration: 0.3) { [weak self] in
                guard let self else { return }
                self.arrowIconButton.transform = CGAffineTransform(rotationAngle: 17.25)
                self.collectionView.alpha = 0.0
                self.collectionView.isHidden = true
            }
        }
    }
}
