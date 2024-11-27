//
//  HashTitleCountTableViewCell.swift
//  MaruTalk
//
//  Created by 권대윤 on 11/16/24.
//

import UIKit

import SnapKit

final class HashTitleCountTableViewCell: BaseTableViewCell {
    
    //MARK: - UI Components
    
    private let hashImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.image = UIImage(named: "hash_thin")
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
            hashImageView,
            titleLabel,
            countBackView,
            countLabel
        )
    }
    
    override func configureLayout() {
        hashImageView.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(14)
            make.size.equalTo(18)
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
            make.leading.equalTo(hashImageView.snp.trailing).offset(8)
            make.centerY.equalToSuperview()
            make.trailing.equalTo(countBackView.snp.leading).offset(-8)
            make.width.greaterThanOrEqualTo(100)
        }
    }
    
    override func configureUI() {
        backgroundColor = Constant.Color.brandWhite.withAlphaComponent(0.8)
    }
    
    func configure(channel: Channel) {
        self.titleLabel.text = channel.name
    }
}
