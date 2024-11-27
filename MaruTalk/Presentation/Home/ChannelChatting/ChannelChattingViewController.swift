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
    weak var coordinator: HomeCoordinator?
    
    init(reactor: ChannelChattingReactor) {
        super.init()
        self.reactor = reactor
    }
    
    //MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        reactor?.action.onNext(.fetch)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.tabBarController?.tabBar.isHidden = false
        reactor?.action.onNext(.viewDisappear)
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
            .map { Reactor.Action.inputContent($0) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        rootView.messageSendButton.rx.tap
            .map { Reactor.Action.sendButtonTapped }
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
                
                //숫자 부분만 색상 변경
                let attributedText = NSMutableAttributedString(string: value)
                if let range = value.rangeOfCharacter(from: .decimalDigits) {
                    let nsRange = NSRange(range, in: value)
                    attributedText.addAttribute(.foregroundColor, value: UIColor.systemOrange, range: nsRange)
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
        
        reactor.pulse(\.$shouldScrollToBottom)
            .compactMap { $0 }
            .bind(with: self) { owner, _ in
                let lastRowIndex = owner.rootView.tableView.numberOfRows(inSection: 0) - 1
                guard lastRowIndex >= 0 else { return }
                
                let lastIndexPath = IndexPath(row: lastRowIndex, section: 0)
                owner.rootView.tableView.scrollToRow(at: lastIndexPath, at: .bottom, animated: false)
            }
            .disposed(by: disposeBag)
    }
}
