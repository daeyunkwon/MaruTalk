//
//  PlusTitleTableViewCell.swift
//  MaruTalk
//
//  Created by 권대윤 on 11/15/24.
//

import UIKit

import SnapKit

final class PlusTitleTableViewCell: BaseTableViewCell {
    
    //MARK: - UI Components
    
    private let plusImageView: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(named: "plus")
        iv.contentMode = .scaleAspectFit
        iv.tintColor = Constant.Color.textSecondary
        return iv
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = Constant.Color.textSecondary
        label.font = Constant.Font.body
        label.textAlignment = .left
        return label
    }()
    
    //MARK: - Configurations
    
    override func configureHierarchy() {
        contentView.addSubviews(
            plusImageView,
            titleLabel
        )
    }
    
    override func configureLayout() {
        plusImageView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.size.equalTo(18)
            make.leading.equalToSuperview().offset(16)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalTo(plusImageView.snp.trailing).offset(16)
            make.trailing.equalToSuperview().offset(-16)
        }
    }
    
    override func configureUI() {
        backgroundColor = Constant.Color.brandWhite.withAlphaComponent(0.5)
    }
    
    func configure(title: String) {
        self.titleLabel.text = title
    }
}
