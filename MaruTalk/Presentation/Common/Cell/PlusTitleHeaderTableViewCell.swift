//
//  PlusTitleHeaderTableViewCell.swift
//  MaruTalk
//
//  Created by 권대윤 on 11/17/24.
//

import UIKit

import SnapKit

final class PlusTitleHeaderTableViewCell: UITableViewHeaderFooterView {
    
    //MARK: - Properties
    
    weak var delegate: PlusTitleHeaderTableViewCellDelegate?
    
    //MARK: - UI Components
    
    private let separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = Constant.Color.viewSeparator
        return view
    }()
    
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
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        configureHierarchy()
        configureLayout()
        configureUI()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(cellTapped))
        addGestureRecognizer(tapGesture)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureHierarchy() {
        contentView.addSubviews(
            separatorView,
            plusImageView,
            titleLabel
        )
    }
    
    private func configureLayout() {
        separatorView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.height.equalTo(0.5)
            make.horizontalEdges.equalToSuperview()
        }
        
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
    
    private func configureUI() {
        contentView.backgroundColor = Constant.Color.brandWhite.withAlphaComponent(0.8)
    }
    
    func configure(title: String) {
        self.titleLabel.text = title
    }
    
    @objc private func cellTapped() {
        delegate?.cellTapped()
    }
}
