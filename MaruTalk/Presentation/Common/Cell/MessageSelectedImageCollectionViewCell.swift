//
//  MessageSelectedImageCollectionViewCell.swift
//  MaruTalk
//
//  Created by 권대윤 on 11/25/24.
//

import UIKit

import RxSwift
import SnapKit

final class MessageSelectedImageCollectionViewCell: BaseCollectionViewCell {
    
    //MARK: - Properties
    
    var disposeBag = DisposeBag()
    
    //MARK: - UI Components
    
    let photoImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.layer.cornerRadius = 8
        iv.isUserInteractionEnabled = false
        return iv
    }()
    
    let xSquareButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setImage(UIImage(named: "x_circle")?.withRenderingMode(.alwaysOriginal), for: .normal)
        return btn
    }()
    
    //MARK: - Configurations
    
    override func prepareForReuse() {
        super.prepareForReuse()
        disposeBag = DisposeBag()
    }
    
    override func configureHierarchy() {
        contentView.addSubviews(
            photoImageView,
            xSquareButton
        )
    }
    
    override func configureLayout() {
        photoImageView.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.bottom.equalToSuperview()
            make.size.equalTo(44)
        }
        
        xSquareButton.snp.makeConstraints { make in
            make.leading.equalTo(photoImageView.snp.leading).offset(30)
            make.bottom.equalTo(photoImageView.snp.bottom).offset(-30)
            make.size.equalTo(20)
        }
    }
}
