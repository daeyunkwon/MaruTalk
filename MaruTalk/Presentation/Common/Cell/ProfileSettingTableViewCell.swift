//
//  ProfileSettingTableViewCell.swift
//  MaruTalk
//
//  Created by 권대윤 on 12/2/24.
//

import UIKit

import SnapKit

final class ProfileSettingTableViewCell: BaseTableViewCell {
    
    //MARK: - UI Components
    
    let settingNameLabel: UILabel = {
        let label = UILabel()
        label.textColor = Constant.Color.textPrimary
        label.font = Constant.Font.bodyBold
        label.textAlignment = .left
        return label
    }()
    
    let settingValueLabel: UILabel = {
        let label = UILabel()
        label.textColor = Constant.Color.textSecondary
        label.font = Constant.Font.captionSemiBold
        label.textAlignment = .right
        return label
    }()
    
    //MARK: - Configurations
    
    override func configureHierarchy() {
        contentView.addSubviews(
            settingNameLabel,
            settingValueLabel
        )
    }
    
    override func configureLayout() {
        settingValueLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview().offset(-15)
        }
        
        settingNameLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview().offset(15)
            make.trailing.equalTo(settingValueLabel.snp.leading).offset(-10)
        }
    }
    
    override func configureUI() {
        backgroundColor = Constant.Color.brandWhite
    }
    
    func configureCell(data: String) {
        
    }
}
