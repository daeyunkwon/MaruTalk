//
//  OnboardingView.swift
//  MaruTalk
//
//  Created by 권대윤 on 10/30/24.
//

import UIKit

import SnapKit

final class OnboardingView: BaseView {
    
    //MARK: - UI Components
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        let text = "마루톡을 사용하면 어디서나\n 팀을 모을 수 있어요"
        label.setTextFontWithLineHeight(text: text, font: Constant.Font.title1.0, lineHeight: Constant.Font.title1.1)
        label.textColor = Constant.Color.brandBlack
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()
    
    private let mainImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.image = UIImage(named: "onboarding")
        return iv
    }()
    
    private let startButton = RectangleBrandColorButton(title: "시작하기")
    
    //MARK: - Configurations
    
    override func configureHierarchy() {
        addSubviews(
            titleLabel,
            mainImageView,
            startButton
        )
    }
    
    override func configureLayout() {
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(93)
            make.horizontalEdges.equalTo(safeAreaLayoutGuide).inset(24)
            make.height.equalTo(60)
        }
        
        mainImageView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(89)
            make.horizontalEdges.equalTo(safeAreaLayoutGuide).inset(12)
            make.height.equalTo(mainImageView.snp.width)
        }
        
        startButton.snp.makeConstraints { make in
            make.horizontalEdges.equalTo(safeAreaLayoutGuide).inset(24)
            make.height.equalTo(44)
            make.bottom.equalTo(safeAreaLayoutGuide).offset(-24)
        }
    }
    
    override func configureUI() {
        super.configureUI()
    }
}
