//
//  WorkspaceAddView.swift
//  MaruTalk
//
//  Created by 권대윤 on 11/12/24.
//

import UIKit

import SnapKit

final class WorkspaceAddView: BaseView {
    
    //MARK: - UI Components
    
    let imageSettingButton: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setImage(UIImage(systemName: "star"), for: .normal)
        btn.imageView?.contentMode = .scaleAspectFill
        btn.backgroundColor = .clear
        btn.clipsToBounds = true
        btn.layer.cornerRadius = 8
        btn.tintColor = .clear
        return btn
    }()
    
    private let placeholderImage: UIButton = {
        let btn = UIButton(type: .system)
        var config = UIButton.Configuration.filled()
        config.baseBackgroundColor = Constant.Color.brandGreen
        config.image = UIImage(named: "workspace")
        config.imagePadding = -10
        config.imagePlacement = .bottom
        config.title = " "
        btn.imageView?.contentMode = .scaleAspectFit
        btn.configuration = config
        btn.clipsToBounds = true
        btn.layer.cornerRadius = 8
        btn.isUserInteractionEnabled = false
        return btn
    }()
    
    private let cameraIconButton: UIButton = {
        let btn = UIButton(type: .system)
        let image = UIImage(named: "Camera")?.resizeImageTo(size: CGSize(width: 14, height: 14))
        btn.setImage(image?.withRenderingMode(.alwaysOriginal), for: .normal)
        btn.backgroundColor = Constant.Color.brandGreen
        btn.layer.cornerRadius = 24 / 2
        btn.clipsToBounds = true
        btn.layer.borderColor = Constant.Color.brandWhite.cgColor
        btn.layer.borderWidth = 3
        btn.isUserInteractionEnabled = false
        return btn
    }()
    
    let nameFieldView = TitleWithInputFieldView(title: "워크스페이스 이름", placeholderText: "워크스페이스 이름을 입력하세요 (필수)")
    
    let descriptionFieldView = TitleWithInputFieldView(title: "워크스페이스 설명", placeholderText: "워크스페이스를 설명하세요 (옵션)")
    
    let doneButton = RectangleBrandColorButton(title: "완료")
    
    //MARK: - Configurations
    
    override func configureHierarchy() {
        addSubviews(
            placeholderImage,
            imageSettingButton,
            cameraIconButton,
            nameFieldView,
            descriptionFieldView,
            doneButton
        )
    }
    
    override func configureLayout() {
        placeholderImage.snp.makeConstraints { make in
            make.top.equalTo(safeAreaLayoutGuide).offset(24)
            make.centerX.equalToSuperview()
            make.size.equalTo(70)
        }
        
        imageSettingButton.snp.makeConstraints { make in
            make.top.equalTo(safeAreaLayoutGuide).offset(24)
            make.centerX.equalToSuperview()
            make.size.equalTo(70)
        }
        
        cameraIconButton.snp.makeConstraints { make in
            make.size.equalTo(24)
            make.trailing.equalTo(imageSettingButton.snp.trailing).offset(5)
            make.bottom.equalTo(imageSettingButton.snp.bottom).offset(5)
        }
        
        nameFieldView.snp.makeConstraints { make in
            make.top.equalTo(imageSettingButton.snp.bottom).offset(16)
            make.horizontalEdges.equalTo(safeAreaLayoutGuide).inset(24)
            make.height.equalTo(76)
        }
        
        nameFieldView.inputTextField.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview().inset(12)
        }
        
        descriptionFieldView.snp.makeConstraints { make in
            make.top.equalTo(nameFieldView.snp.bottom).offset(24)
            make.horizontalEdges.equalTo(safeAreaLayoutGuide).inset(24)
            make.height.equalTo(76)
        }
        
        descriptionFieldView.inputTextField.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview().inset(12)
        }
        
        doneButton.snp.makeConstraints { make in
            make.height.equalTo(44)
            make.horizontalEdges.equalTo(safeAreaLayoutGuide).inset(24)
            make.bottom.equalTo(keyboardLayoutGuide.snp.top).offset(-15)
        }
    }
    
    override func configureUI() {
        super.configureUI()
    }
}
