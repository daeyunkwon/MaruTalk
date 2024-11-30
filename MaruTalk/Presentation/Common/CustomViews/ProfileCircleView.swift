//
//  ProfileCircleView.swift
//  MaruTalk
//
//  Created by 권대윤 on 11/17/24.
//

import UIKit

import SnapKit
import RxCocoa
import RxSwift

final class ProfileCircleView: BaseView {
    
    //MARK: - Properties
    
    var rxTap: ControlEvent<Void> {
        return button.rx.tap
    }
    
    //MARK: - UI Components
    
    let profileImageView: UIImageView = {
        let iv = UIImageView()
        iv.layer.borderWidth = 2
        iv.layer.borderColor = Constant.Color.brandBlack.cgColor
        iv.image = UIImage(named: "noPhotoB")
        iv.clipsToBounds = true
        iv.contentMode = .scaleAspectFit
        iv.layer.cornerRadius = 16
        return iv
    }()
    
    private let button = UIButton(type: .custom)
    
    //MARK: - Configurations
    
    override func configureHierarchy() {
        addSubview(profileImageView)
        addSubview(button)
    }
    
    override func configureLayout() {
        profileImageView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.size.equalTo(32)
            make.trailing.equalToSuperview().inset(2)
        }
        
        button.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    override func configureUI() {
        backgroundColor = Constant.Color.brandWhite
    }
}
