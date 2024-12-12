//
//  EditView.swift
//  MaruTalk
//
//  Created by 권대윤 on 12/12/24.
//

import UIKit

import SnapKit

final class EditView: BaseView {
    
    //MARK: - UI Components
    
    let inputFieldView = TitleWithInputFieldView(title: "", placeholderText: "")
    
    let doneButton = RoundedBrandButton(title: "완료")
    
    //MARK: - Configurations
    
    override func configureHierarchy() {
        addSubviews(
            inputFieldView,
            doneButton
        )
    }
    
    override func configureLayout() {
        inputFieldView.snp.makeConstraints { make in
            make.top.equalTo(safeAreaLayoutGuide).offset(24)
            make.horizontalEdges.equalToSuperview().inset(24)
            make.height.equalTo(76)
        }
        
        inputFieldView.inputTextField.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview().inset(12)
        }
        
        doneButton.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview().inset(24)
            make.height.equalTo(44)
            make.bottom.equalTo(keyboardLayoutGuide.snp.top).offset(-10)
        }
    }
    
    override func configureUI() {
        super.configureUI()
    }
}
