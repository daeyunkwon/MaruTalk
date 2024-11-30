//
//  RoundedImageTitleView.swift
//  MaruTalk
//
//  Created by 권대윤 on 11/17/24.
//

import UIKit

import SnapKit
import RxCocoa
import RxSwift

final class RoundedImageTitleView: BaseView {
    
    //MARK: - Properties
    
    var rxTap: ControlEvent<Void> {
        return button.rx.tap
    }
    
    //MARK: - UI Components
    
    let photoImageView: UIImageView = {
        let iv = UIImageView()
        iv.layer.cornerRadius = 8
        iv.backgroundColor = .lightGray
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        return iv
    }()
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "No Workspace"
        label.font = Constant.Font.title1
        label.textColor = Constant.Color.brandBlack
        return label
    }()
    
    private let stackView: UIStackView = {
        let sv = UIStackView()
        sv.axis = .horizontal
        sv.spacing = 4
        return sv
    }()
    
    private let button = UIButton(type: .custom)
    
    //MARK: - Configurations
    
    override func configureHierarchy() {
        addSubviews(
            stackView,
            button
        )
        stackView.addArrangedSubview(photoImageView)
        stackView.addArrangedSubview(titleLabel)
    }
    
    override func configureLayout() {
        stackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        photoImageView.snp.makeConstraints { make in
            make.size.equalTo(32)
        }
        
        button.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    override func configureUI() {
        backgroundColor = Constant.Color.brandWhite
    }
}
