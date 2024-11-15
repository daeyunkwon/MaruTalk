//
//  TitleWithInputFieldView.swift
//  MaruTalk
//
//  Created by 권대윤 on 11/2/24.
//

import UIKit

import SnapKit

final class TitleWithInputFieldView: UIView {
    
    //MARK: - UI Components
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = Constant.Color.brandBlack
        label.font = Constant.Font.title2
        return label
    }()
    
    private let backView: UIView = {
        let view = UIView()
        view.backgroundColor = Constant.Color.backgroundSecondary
        view.layer.cornerRadius = 8
        return view
    }()
    
    lazy var inputTextField: UITextField = {
        let tf = UITextField()
        tf.textColor = Constant.Color.brandBlack
        tf.font = Constant.Font.body
        tf.autocapitalizationType = .none
        tf.autocorrectionType = .no
        
        //완료 버튼 추가
        let accessory = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 50))
        lazy var doneButton = UIButton(type: .system)
        doneButton.addTarget(self, action: #selector(doneButtonTapped), for: .touchUpInside)
        doneButton.setTitle("완료", for: .normal)
        doneButton.titleLabel?.font = Constant.Font.title2
        accessory.addSubview(doneButton)
        doneButton.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.trailing.equalTo(accessory.snp.trailing).offset(-20)
            make.width.equalTo(50)
            make.height.equalTo(20)
        }
        accessory.backgroundColor = .systemGroupedBackground
        tf.inputAccessoryView = accessory
        
        return tf
    }()
    
    //MARK: - Init
    
    init(title: String, placeholderText: String) {
        super.init(frame: .zero)
        titleLabel.text = title
        inputTextField.attributedPlaceholder = NSAttributedString(
            string: placeholderText,
            attributes: [NSAttributedString.Key.foregroundColor: Constant.Color.brandGray]
        )
        
        configureHierarchy()
        configureLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Configurations
    
    private func configureHierarchy() {
        addSubview(titleLabel)
        addSubview(backView)
        backView.addSubview(inputTextField)
    }
    
    private func configureLayout() {
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.equalToSuperview()
            make.height.equalTo(24)
        }
        
        backView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(8)
            make.horizontalEdges.equalToSuperview()
            make.height.equalTo(44)
        }
        
        inputTextField.snp.makeConstraints { make in
            make.verticalEdges.equalToSuperview().inset(14)
            //            make.horizontalEdges.equalToSuperview().inset(12)
        }
    }
    
    //MARK: - Methods
    
    @objc private func doneButtonTapped() {
        inputTextField.resignFirstResponder() // 키보드 내림
    }
}

