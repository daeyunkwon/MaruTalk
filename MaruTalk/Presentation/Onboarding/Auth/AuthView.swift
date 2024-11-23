//
//  AuthView.swift
//  MaruTalk
//
//  Created by 권대윤 on 10/31/24.
//

import UIKit

import SnapKit

final class AuthView: BaseView {
    
    //MARK: - UI Components
    
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = Constant.Color.backgroundPrimary
        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        view.layer.cornerRadius = 10
        view.clipsToBounds = true
        return view
    }()
    
    let appleLoginButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle(" Apple로 계속하기", for: .normal)
        btn.setImage(UIImage(named: "apple_logo"), for: .normal)
        btn.tintColor = .white
        btn.backgroundColor = .black
        btn.titleLabel?.font = Constant.Font.title2
        btn.layer.cornerRadius = 8
        return btn
    }()
    
    let kakaoLoginButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle(" 카카오톡으로 계속하기", for: .normal)
        btn.setImage(UIImage(named: "kakao_logo"), for: .normal)
        btn.tintColor = .black
        btn.backgroundColor = UIColor(red: 254/255, green: 229/255, blue: 0/255, alpha: 1.0)
        btn.titleLabel?.font = Constant.Font.title2
        btn.layer.cornerRadius = 8
        return btn
    }()
    
    let emailLoginButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle(" 이메일로 계속하기", for: .normal)
        btn.setImage(UIImage(named: "email_icon"), for: .normal)
        btn.tintColor = .white
        btn.backgroundColor = Constant.Color.brandColor
        btn.titleLabel?.font = Constant.Font.title2
        btn.layer.cornerRadius = 8
        return btn
    }()
    
    let signUpButton: UIButton = {
        let btn = UIButton(type: .system)
        let attributedString = NSMutableAttributedString(string: "또는 ", attributes: [.foregroundColor: Constant.Color.brandBlack, .font: Constant.Font.title2])
        attributedString.append(NSAttributedString(string: "새롭게 회원가입 하기", attributes: [.foregroundColor: Constant.Color.brandColor, .font: Constant.Font.title2]))
        btn.setAttributedTitle(attributedString, for: .normal)
        return btn
    }()
    
    //MARK: - Configurations
    
    override func configureHierarchy() {
        addSubview(containerView)
        containerView.addSubviews(
            appleLoginButton,
            kakaoLoginButton,
            emailLoginButton,
            signUpButton
        )
    }
    
    override func configureLayout() {
        containerView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        appleLoginButton.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(42)
            make.horizontalEdges.equalToSuperview().inset(35)
            make.height.equalTo(44)
        }
        
        kakaoLoginButton.snp.makeConstraints { make in
            make.top.equalTo(appleLoginButton.snp.bottom).offset(16)
            make.horizontalEdges.equalToSuperview().inset(35)
            make.height.equalTo(44)
        }
        
        emailLoginButton.snp.makeConstraints { make in
            make.top.equalTo(kakaoLoginButton.snp.bottom).offset(16)
            make.horizontalEdges.equalToSuperview().inset(35)
            make.height.equalTo(44)
        }
        
        signUpButton.snp.makeConstraints { make in
            make.top.equalTo(emailLoginButton.snp.bottom).offset(16)
            make.horizontalEdges.equalToSuperview().inset(35)
        }
    }
}
