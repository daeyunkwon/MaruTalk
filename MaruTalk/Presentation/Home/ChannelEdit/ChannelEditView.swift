//
//  ChannelEditView.swift
//  MaruTalk
//
//  Created by 권대윤 on 11/28/24.
//

import UIKit

import SnapKit

final class ChannelEditView: BaseView {
    
    //MARK: - UI Components
    
    let channelNameFieldView = TitleWithInputFieldView(title: "채널 이름", placeholderText: "채널 이름을 입력하세요 (필수)")
    
    let channelDescriptionFieldView = TitleWithInputFieldView(title: "채널 설명", placeholderText: "채널을 설명하세요 (옵션)")

    let doneButton = RoundedBrandButton(title: "완료")
    
    //MARK: - Configurations
    
    override func configureHierarchy() {
        addSubviews(
            channelNameFieldView,
            channelDescriptionFieldView,
            doneButton
        )
    }
    
    override func configureLayout() {
        channelNameFieldView.snp.makeConstraints { make in
            make.top.equalTo(safeAreaLayoutGuide).offset(24)
            make.horizontalEdges.equalTo(safeAreaLayoutGuide).inset(24)
            make.height.equalTo(76)
        }
        
        channelNameFieldView.inputTextField.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview().inset(12)
        }
        
        channelDescriptionFieldView.snp.makeConstraints { make in
            make.top.equalTo(channelNameFieldView.snp.bottom).offset(24)
            make.horizontalEdges.equalTo(safeAreaLayoutGuide).inset(24)
            make.height.equalTo(76)
        }
        
        channelDescriptionFieldView.inputTextField.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview().inset(12)
        }
        
        doneButton.snp.makeConstraints { make in
            make.height.equalTo(44)
            make.bottom.equalTo(keyboardLayoutGuide.snp.top).offset(-15)
            make.horizontalEdges.equalTo(safeAreaLayoutGuide).inset(24)
        }
    }
    
    override func configureUI() {
        super.configureUI()
    }
}
