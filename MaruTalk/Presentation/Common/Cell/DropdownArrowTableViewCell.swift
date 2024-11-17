//
//  DropdownArrowTableViewCell.swift
//  MaruTalk
//
//  Created by 권대윤 on 11/15/24.
//

import UIKit

import SnapKit

final class DropdownArrowTableViewCell: UITableViewHeaderFooterView {
    
    //MARK: - Properties
    
    weak var delegate: DropdownArrowTableViewCellDelegate?
    var section: Int?
    
    //MARK: - UI Components
    
    private let separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = Constant.Color.viewSeparator
        return view
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = Constant.Color.brandBlack
        label.font = Constant.Font.bodyBold
        label.textAlignment = .left
        return label
    }()
    
    private let arrowIconImageView: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(named: "chevron_right")?.withRenderingMode(.alwaysOriginal)
        iv.contentMode = .scaleAspectFill
        return iv
    }()
    
    //MARK: - Configurations
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        
        configureHierarchy()
        configureLayout()
        
        contentView.backgroundColor = Constant.Color.brandWhite
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapGesture))
        contentView.addGestureRecognizer(tapGesture)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureHierarchy() {
        contentView.addSubviews(
            separatorView,
            arrowIconImageView,
            titleLabel
        )
    }
    
    private func configureLayout() {
        separatorView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.height.equalTo(0.5)
            make.horizontalEdges.equalToSuperview()
        }
        
        arrowIconImageView.snp.makeConstraints { make in
            make.size.equalTo(24)
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview().offset(-16)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(8)
            make.centerY.equalToSuperview()
            make.trailing.equalTo(arrowIconImageView.snp.leading).offset(-5)
        }
    }
    
    func configure(title: String, isExpanded: Bool) {
        titleLabel.text = title
        arrowIconImageView.image = UIImage(named: isExpanded ? "chevron_down" : "chevron_right")
    }
    
    @objc private func tapGesture() {
        delegate?.sectionHeaderTapped(section: section ?? 0)
    }
}
