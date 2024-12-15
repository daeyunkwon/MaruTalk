//
//  ChannelChattingViewController.swift
//  MaruTalk
//
//  Created by 권대윤 on 11/24/24.
//

import UIKit

import ReactorKit
import RxCocoa

final class ChannelChattingViewController: BaseViewController<ChannelChattingView>, View {
    
    //MARK: - Properties
    
    var disposeBag: DisposeBag = DisposeBag()
    weak var coordinator: ChannelCoordinator?
    
    init(reactor: ChannelChattingReactor) {
        super.init()
        self.reactor = reactor
    }
    
    deinit {
        self.coordinator?.didFinish()
    }
    
    private let settingButton: UIBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "gearshape.fill")?.applyingSymbolConfiguration(.init(pointSize: 14)), style: .plain, target: nil, action: nil)
    
    private let phpickerManager = PHPickerManager()
    
    //MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = true
        reactor?.action.onNext(.fetch)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.tabBarController?.tabBar.isHidden = false
        reactor?.action.onNext(.viewDisappear)
        navigationItem.title = ""
    }
    
    //MARK: - Configurations
    
    override func setupNavi() {
        self.navigationItem.rightBarButtonItem = settingButton
    }
    
    //MARK: - Methods
    
    func bind(reactor: ChannelChattingReactor) {
        bindAction(reactor: reactor)
        bindState(reactor: reactor)
    }
}

//MARK: - Bind Action

extension ChannelChattingViewController {
    private func bindAction(reactor: ChannelChattingReactor) {
        rootView.messageInputTextView.rx.text.orEmpty
            .bind(with: self) { owner, value in
                
                var isPlaceholderText: Bool = false
                
                if owner.rootView.messageInputTextView.textColor == Constant.Color.textSecondary {
                    isPlaceholderText = true
                }
                
                owner.reactor?.action.onNext(.inputContent((value, isPlaceholderText)))
            }
            .disposed(by: disposeBag)
        
        rootView.messageSendButton.rx.tap
            .map { Reactor.Action.sendButtonTapped }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        rootView.messagePlusButton.rx.tap
            .map { Reactor.Action.messagePlusButtonTapped }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        settingButton.rx.tap
            .map { Reactor.Action.settingButtonTapped }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
    }
}

//MARK: - Bind State

extension ChannelChattingViewController {
    private func bindState(reactor: ChannelChattingReactor) {
        reactor.pulse(\.$navigationTitle)
            .compactMap { $0 }
            .bind(with: self, onNext: { owner, value in
                let titleLabel = UILabel()
                titleLabel.font = .boldSystemFont(ofSize: 16)
                titleLabel.textColor = Constant.Color.textPrimary
                
                let attributedText = NSMutableAttributedString(string: value)
                //숫자 부분만 색상 변경
                do {
                    let regex = try NSRegularExpression(pattern: "\\d+")
                    let matches = regex.matches(in: value, options: [], range: NSRange(location: 0, length: value.utf16.count))
                    
                    for match in matches {
                        attributedText.addAttribute(.foregroundColor, value: UIColor.systemOrange, range: match.range)
                    }
                } catch {
                    print("DEBUG: Invalid regex pattern - \(error)")
                }
                
                titleLabel.attributedText = attributedText
                owner.navigationItem.titleView = titleLabel
            })
            .disposed(by: disposeBag)
        
        reactor.pulse(\.$networkError)
            .compactMap { $0 }
            .bind(with: self) { owner, value in
                owner.showToastForNetworkError(api: value.0, errorCode: value.1)
            }
            .disposed(by: disposeBag)
        
        reactor.pulse(\.$messageSendSuccess)
            .compactMap { $0 }
            .bind(with: self) { owner, _ in
                owner.rootView.messageInputTextView.text = nil
            }
            .disposed(by: disposeBag)
        
        reactor.pulse(\.$chatList)
            .compactMap { $0 }
            .bind(to: rootView.tableView.rx.items) { (tableView, row, element) in
                
                switch element.files.count {
                case 0, 1:
                    //파일이 0개 또는 1개인 경우
                    guard let cell = tableView.dequeueReusableCell(withIdentifier: MessageOnePhotoTextTableViewCell.reuseIdentifier) as? MessageOnePhotoTextTableViewCell else { return UITableViewCell() }
                    cell.configureCell(data: element)
                    return cell
                    
                case 2:
                    //파일이 2개인 경우
                    guard let cell = tableView.dequeueReusableCell(withIdentifier: MessageTwoPhotoTextTableViewCell.reuseIdentifier) as? MessageTwoPhotoTextTableViewCell else { return UITableViewCell() }
                    cell.configureCell(data: element)
                    return cell
                    
                case 3:
                    //파일이 3개인 경우
                    guard let cell = tableView.dequeueReusableCell(withIdentifier: MessageThreePhotoTextTableViewCell.reuseIdentifier) as? MessageThreePhotoTextTableViewCell else { return UITableViewCell() }
                    cell.configureCell(data: element)
                    return cell
                    
                case 4:
                    //파일이 4개인 경우
                    guard let cell = tableView.dequeueReusableCell(withIdentifier: MessageFourPhotoTextTableViewCell.reuseIdentifier) as? MessageFourPhotoTextTableViewCell else { return UITableViewCell() }
                    cell.configureCell(data: element)
                    return cell
                    
                case 5:
                    //파일이 5개인 경우
                    guard let cell = tableView.dequeueReusableCell(withIdentifier: MessageFivePhotoTextTableViewCell.reuseIdentifier) as? MessageFivePhotoTextTableViewCell else { return UITableViewCell() }
                    cell.configureCell(data: element)
                    return cell
                default: return UITableViewCell()
                }
            }
            .disposed(by: disposeBag)
        
        reactor.pulse(\.$scrollToBottom)
            .compactMap { $0 }
            .bind(with: self) { owner, _ in
                let lastRowIndex = owner.rootView.tableView.numberOfRows(inSection: 0) - 1
                guard lastRowIndex >= 0 else { return }
                
                let lastIndexPath = IndexPath(row: lastRowIndex, section: 0)
                owner.rootView.tableView.scrollToRow(at: lastIndexPath, at: .bottom, animated: false)
            }
            .disposed(by: disposeBag)
        
        reactor.pulse(\.$showPhotoAlbum)
            .compactMap { $0 }
            .bind(with: self) { [weak self] owner, _ in
                guard let self else { return }
                owner.phpickerManager.openPhotoPicker(in: owner, limit: 5) { [weak self] dataList in
                    self?.reactor?.action.onNext(.selectPhotoImage(dataList))
                }
            }
            .disposed(by: disposeBag)
        
        reactor.pulse(\.$photoImageDatas)
            .bind(with: self) { owner, value in
                if value.isEmpty {
                    owner.rootView.collectionView.isHidden = true
                } else {
                    owner.rootView.collectionView.isHidden = false
                }
                owner.rootView.updateMessageSendButtonActiveState()
            }
            .disposed(by: disposeBag)
        
        reactor.pulse(\.$photoImageDatas)
            .bind(to: rootView.collectionView.rx.items) { [weak self] (collectionView, row, element) in
                guard let self else { return UICollectionViewCell() }
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MessageSelectedImageCollectionViewCell.reuseIdentifier, for: IndexPath(row: row, section: 0)) as? MessageSelectedImageCollectionViewCell else {
                    return UICollectionViewCell()
                }
                cell.photoImageView.image = UIImage(data: element)
                
                cell.xSquareButton.rx.tap
                    .bind(with: self) { owner, _ in
                        owner.reactor?.action.onNext(.deselectPhotoImage(row))
                    }
                    .disposed(by: cell.disposeBag)
                
                return cell
            }
            .disposed(by: disposeBag)
        
        reactor.pulse(\.$navigateToSetting)
            .compactMap { $0 }
            .bind(with: self) { owner, value in
                owner.coordinator?.showChannelSetting(channelID: value)
            }
            .disposed(by: disposeBag)
    }
}
