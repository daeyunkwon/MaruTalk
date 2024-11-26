//
//  ChannelChattingView.swift
//  MaruTalk
//
//  Created by 권대윤 on 11/24/24.
//

import UIKit

import SnapKit

final class ChannelChattingView: BaseView {
    
    //MARK: - UI Components
    
    lazy var tableView: UITableView = {
        let tv = UITableView()
        tv.backgroundColor = Constant.Color.brandColor.withAlphaComponent(0.4)
        tv.register(MessageOnePhotoTextTableViewCell.self, forCellReuseIdentifier: MessageOnePhotoTextTableViewCell.reuseIdentifier)
        tv.register(MessageTwoPhotoTextTableViewCell.self, forCellReuseIdentifier: MessageTwoPhotoTextTableViewCell.reuseIdentifier)
        tv.register(MessageThreePhotoTextTableViewCell.self, forCellReuseIdentifier: MessageThreePhotoTextTableViewCell.reuseIdentifier)
        tv.register(MessageFourPhotoTextTableViewCell.self, forCellReuseIdentifier: MessageFourPhotoTextTableViewCell.reuseIdentifier)
        tv.register(MessageFivePhotoTextTableViewCell.self, forCellReuseIdentifier: MessageFivePhotoTextTableViewCell.reuseIdentifier)
        tv.rowHeight = UITableView.automaticDimension
        tv.separatorStyle = .none
        tv.contentInset = .init(top: 22, left: 0, bottom: 22, right: 0)
        return tv
    }()
    
    private let bottomContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = Constant.Color.backgroundPrimary
        return view
    }()
    
    private let messageInputBackView: UIView = {
        let view = UIView()
        view.backgroundColor = Constant.Color.backgroundPrimary
        view.layer.cornerRadius = 8
        return view
    }()
    
    lazy var messageInputTextView: UITextView = {
        let tv = UITextView()
        tv.textColor = Constant.Color.textSecondary
        tv.text = "메시지를 입력하세요"
        tv.isScrollEnabled = false
        tv.delegate = self
        tv.autocapitalizationType = .none
        tv.autocorrectionType = .no
        tv.backgroundColor = Constant.Color.brandWhite
        tv.layer.cornerRadius = 8
        return tv
    }()
    
    let messagePlusButton: UIButton = {
        let btn = UIButton(type: .system)
        let configuration = UIImage.SymbolConfiguration.init(paletteColors: [Constant.Color.textSecondary, Constant.Color.brandColor])
        let image = UIImage(systemName: "plus.circle.fill", withConfiguration: configuration)
        btn.setImage(image, for: .normal)
        return btn
    }()
    
    let messageSendButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setImage(UIImage(systemName: "arrow.up.message"), for: .normal)
        btn.tintColor = Constant.Color.textSecondary
        return btn
    }()
    
    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = .init(width: 50, height: 50)
        layout.minimumLineSpacing = 6
        
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = Constant.Color.brandWhite
        cv.layer.cornerRadius = 8
        cv.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMinXMaxYCorner]
        cv.register(MessageSelectedImageCollectionViewCell.self, forCellWithReuseIdentifier: MessageSelectedImageCollectionViewCell.reuseIdentifier)
        return cv
    }()
    
    //MARK: - Configurations
    
    override func configureHierarchy() {
        addSubviews(
            tableView,
            bottomContainerView,
            messageInputBackView,
            messageInputTextView,
            messagePlusButton,
            messageSendButton,
            collectionView
        )
    }
    
    override func configureLayout() {
        tableView.snp.makeConstraints { make in
            make.top.equalTo(safeAreaLayoutGuide)
            make.horizontalEdges.equalToSuperview()
            make.bottom.equalTo(messageInputBackView.snp.top)
        }
        
        messageInputBackView.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview().inset(16)
            make.bottom.equalTo(keyboardLayoutGuide.snp.top).offset(-5)
            make.top.equalTo(messageInputTextView.snp.top).offset(-5)
        }
        
        messageInputTextView.snp.makeConstraints { make in
            make.centerX.equalTo(messageInputBackView)
            make.width.equalTo(275)
            make.height.equalTo(30)
        }
        
        messagePlusButton.snp.makeConstraints { make in
            make.size.equalTo(24)
            make.bottom.equalTo(messageInputTextView).offset(-3)
            make.leading.equalTo(messageInputBackView.snp.leading).offset(12)
        }
        
        messageSendButton.snp.makeConstraints { make in
            make.size.equalTo(24)
            make.bottom.equalTo(messageInputTextView).offset(-3)
            make.trailing.equalTo(messageInputBackView.snp.trailing).offset(-12)
        }
        
        bottomContainerView.snp.makeConstraints { make in
            make.bottom.equalToSuperview()
            make.horizontalEdges.equalToSuperview()
            make.top.equalTo(messageInputBackView.snp.top)
        }
        
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(messageInputTextView.snp.bottom)
            make.bottom.equalTo(messageInputBackView.snp.bottom).offset(-8)
            make.width.equalTo(messageInputTextView)
        }
    }
    
    override func configureUI() {
        super.configureUI()
        setupTapGesture()
    }
    
    private func setupTapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTap))
        self.addGestureRecognizer(tapGesture)
    }
    
    //MARK: - Methods
    
    @objc private func didTap() {
        endEditing(true)
    }
    
    private func updateMessageSendButtonActiveState() {
        if messageInputTextView.text.trimmingCharacters(in: .whitespaces).isEmpty {
            messageSendButton.setImage(UIImage(systemName: "arrow.up.message"), for: .normal)
            messageSendButton.tintColor = Constant.Color.textSecondary
            messageSendButton.isUserInteractionEnabled = false
        } else {
            messageSendButton.setImage(UIImage(systemName: "arrow.up.message.fill"), for: .normal)
            messageSendButton.tintColor = Constant.Color.brandColor
            messageSendButton.isUserInteractionEnabled = true
        }
    }
}

//MARK: - UITextViewDelegate

extension ChannelChattingView: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        let size = CGSize(width: textView.frame.width, height: .infinity)
        let estimatedSize = textView.sizeThatFits(size)
        
        //height 제약조건 업데이트(최소: 30, 최대: 60)
        let adjustedHeight = min(max(estimatedSize.height, 30), 60)
        textView.snp.updateConstraints { make in
            make.centerX.equalTo(messageInputBackView)
            make.width.equalTo(275)
            make.height.equalTo(adjustedHeight)
        }
        //3줄 이상부터 스크롤 허용
        if estimatedSize.height >= 60 {
            textView.isScrollEnabled = true
        } else {
            textView.isScrollEnabled = false
        }
        
        //전송 버튼 활성화 설정
        self.updateMessageSendButtonActiveState()
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        //플레이스 홀더 제거
        if textView.text == "메시지를 입력하세요" {
            textView.text = nil
            textView.textColor = Constant.Color.textPrimary
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        //플레이스 홀더 보여주기
        if textView.text.isEmpty {
            textView.text = "메시지를 입력하세요"
            textView.textColor = Constant.Color.textSecondary
        }
    }
}
