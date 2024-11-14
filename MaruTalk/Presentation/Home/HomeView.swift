//
//  HomeView.swift
//  MaruTalk
//
//  Created by 권대윤 on 11/14/24.
//

import UIKit

import SnapKit

final class HomeView: BaseView {
    
    //MARK: - UI Components
    
    let doneButton = RectangleBrandColorButton(title: "끝!!")
    
    
    
    //MARK: - Configurations
    
    override func configureHierarchy() {
        addSubviews(
            doneButton
        )
    }
    
    override func configureLayout() {
        doneButton.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.height.equalTo(44)
        }
    }
    
    override func configureUI() {
        super.configureUI()
    }
}
