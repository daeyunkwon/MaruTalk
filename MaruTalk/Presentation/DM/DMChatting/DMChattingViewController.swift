//
//  DMChattingViewController.swift
//  MaruTalk
//
//  Created by 권대윤 on 11/30/24.
//

import UIKit

import ReactorKit

final class DMChattingViewController: BaseViewController<ChannelChattingView>, View {
    
    //MARK: - Properties
    
    var disposeBag: DisposeBag = DisposeBag()
    weak var coordinator: DMCoordinator?
    
    init(reactor: DMChattingReactor) {
        super.init()
        self.reactor = reactor
    }
    
    //MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.tabBarController?.tabBar.isHidden = false
    }
    
    //MARK: - Methods
    
    func bind(reactor: DMChattingReactor) {
        bindAction(reactor: reactor)
        bindState(reactor: reactor)
    }
}

//MARK: - Bind Action

extension DMChattingViewController {
    private func bindAction(reactor: DMChattingReactor) {
        rx.methodInvoked(#selector(viewWillAppear(_:)))
            .map { _ in Reactor.Action.fetch }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        rx.methodInvoked(#selector(viewWillDisappear(_:)))
            .map { _ in Reactor.Action.viewDisappear }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
    }
}

//MARK: - Bind State

extension DMChattingViewController {
    private func bindState(reactor: DMChattingReactor) {
        reactor.pulse(\.$navigationTitle)
            .compactMap { $0 }
            .bind(to: navigationItem.rx.title)
            .disposed(by: disposeBag)
        
        reactor.pulse(\.$networkError)
            .compactMap { $0 }
            .bind(with: self) { owner, value in
                owner.showToastForNetworkError(api: value.0, errorCode: value.1)
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
    }
}
