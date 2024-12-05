//
//  HomeViewController.swift
//  MaruTalk
//
//  Created by 권대윤 on 11/14/24.
//

import UIKit

import ReactorKit
import RxCocoa
import RxDataSources

final class HomeViewController: BaseViewController<HomeView>, View {
    
    //MARK: - Properties
    
    weak var coordinator: HomeCoordinator?
    var disposeBag = DisposeBag()
    private var sections: [SectionModel] = []
    private var screenEdgeGestureFlag = false
    
    init(reactor: HomeReactor) {
        super.init()
        self.reactor = reactor
    }
    
    private let profileCircleView = ProfileCircleView()
    private let workspaceNameView = RoundedImageTitleView()
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    //MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNotificationCenter()
        setupEdgePenGesture()
    }
    
    //MARK: - Configurations
    
    override func setupNavi() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: workspaceNameView)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: profileCircleView)
        navigationItem.title = ""
    }
    
    private func setupNotificationCenter() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleModalDismissed), name: .workspaceAddComplete, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleModalDismissed), name: .channelAddComplete, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleModalDismissed), name: .memberInviteComplete, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleScreenEdgeGestureFlag), name: .workspaceListViewFadeInComplete, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleModalDismissed), name: .workspaceChangeComplete, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleModalDismissed), name: .workspaceEditComplete, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleModalDismissed), name: .workspaceExitComplete, object: nil)
    }
    
    private func setupEdgePenGesture() {
        let edgePanGesture = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(handleEdgePan))
        edgePanGesture.edges = .left
        rootView.addGestureRecognizer(edgePanGesture)
    }
    
    //MARK: - Methods
    
    func bind(reactor: HomeReactor) {
        bindAction(reactor: reactor)
        bindState(reactor: reactor)
        bindTableView(reactor: reactor)
    }
    
    @objc private func handleModalDismissed(notification: Notification) {
        reactor?.action.onNext(.fetch)
        
        switch notification.name {
        case .channelAddComplete:
            showToastMessage(message: "채널이 생성되었습니다.")
        case .memberInviteComplete:
            showToastMessage(message: "멤버를 성공적으로 초대했습니다.")
        default: break
        }
    }
    
    @objc private func handleScreenEdgeGestureFlag() {
        self.screenEdgeGestureFlag = false
    }
    
    @objc private func handleEdgePan() {
        if screenEdgeGestureFlag == false {
            self.screenEdgeGestureFlag = true
            self.coordinator?.showWorkspaceList()
        }
    }
}

//MARK: - Bind Action

extension HomeViewController {
    private func bindAction(reactor: HomeReactor) {
        rootView.emptyView.createWorkspaceButton.rx.tap
            .map { Reactor.Action.workspaceAddButtonTapped }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        rx.methodInvoked(#selector(viewWillAppear(_:)))
            .map { _ in Reactor.Action.fetch }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        rootView.tableView.rx.modelSelected(SectionModel.Item.self)
            .filter { $0 == .add("채널 추가") }
            .bind(with: self) { owner, value in
                owner.showActionSheet(actions: [
                    ("채널 추가", UIAlertAction.Style.default, { owner.coordinator?.showChannelAdd() }),
                    ("채널 탐색", UIAlertAction.Style.default, { owner.coordinator?.showChannelSearch() })
                ])
            }
            .disposed(by: disposeBag)
        
        rootView.tableView.rx.modelSelected(SectionModel.Item.self)
            .bind(with: self) { owner, item in
                switch item {
                case .channel(let data):
                    owner.coordinator?.showChannelChatting(channelID: data.id)
                case .dm(let data):
                    print(data)
                default: break
                }
            }
            .disposed(by: disposeBag)
        
        profileCircleView.rxTap
            .bind(with: self) { owner, _ in
                owner.coordinator?.showProfile()
            }
            .disposed(by: disposeBag)
        
        workspaceNameView.rxTap
            .bind(with: self) { owner, _ in
                owner.coordinator?.showWorkspaceList()
            }
            .disposed(by: disposeBag)
    }
}

//MARK: - Bind State

extension HomeViewController {
    private func bindState(reactor: HomeReactor) {
        reactor.pulse(\.$isShowEmpty)
            .bind(with: self) { owner, value in
                if value {
                    owner.rootView.emptyView.isHidden = false
                    owner.tabBarController?.tabBar.isHidden = true
                    
                    owner.workspaceNameView.titleLabel.text = "No Workspace"
                    owner.workspaceNameView.photoImageView.image = nil
                } else {
                    owner.rootView.emptyView.isHidden = true
                    owner.tabBarController?.tabBar.isHidden = false
                }
            }
            .disposed(by: disposeBag)
        
        reactor.pulse(\.$shouldNavigateToWorkspaceAdd)
            .bind(with: self) { owner, _ in
                owner.coordinator?.showWorkspaceAdd(previousScreen: .workspaceInitial)
            }
            .disposed(by: disposeBag)
        
        reactor.pulse(\.$networkError)
            .bind(with: self) { owner, value in
                owner.showToastForNetworkError(api: value.0, errorCode: value.1)
            }
            .disposed(by: disposeBag)
        
        reactor.pulse(\.$workspace)
            .compactMap { $0 }
            .bind(with: self) { owner, workspace in
                owner.workspaceNameView.titleLabel.text = workspace.name
                owner.workspaceNameView.photoImageView.setImage(imagePath: workspace.coverImage)
            }
            .disposed(by: disposeBag)
        
        reactor.pulse(\.$user)
            .compactMap { $0 }
            .bind(with: self) { owner, user in
                if user.profileImage != nil {
                    owner.profileCircleView.profileImageView.setImage(imagePath: user.profileImage)
                } else {
                    owner.profileCircleView.profileImageView.image = UIImage(named: "noPhotoA")
                }
            }
            .disposed(by: disposeBag)
        
        reactor.pulse(\.$toastMessage)
            .compactMap { $0 }
            .bind(with: self) { owner, value in
                owner.showToastMessage(message: value)
            }
            .disposed(by: disposeBag)
        
        reactor.pulse(\.$shouldNavigateToMemberInvite)
            .compactMap { $0 }
            .bind(with: self) { owner, _ in
                owner.coordinator?.showMemberInvite()
            }
            .disposed(by: disposeBag)
    }
}

//MARK: - BindTableView

extension HomeViewController {
    private func bindTableView(reactor: HomeReactor) {
        let dataSource = RxTableViewSectionedAnimatedDataSource<SectionModel>(
            configureCell: { _, tableView, indexPath, item in
                switch item {
                case .channel(let channel):
                    guard let cell = tableView.dequeueReusableCell(withIdentifier: HashTitleCountTableViewCell.reuseIdentifier, for: indexPath) as? HashTitleCountTableViewCell else {
                        return UITableViewCell()
                    }
                    cell.configure(channel: channel)
                    return cell
                
                case .dm(let dm):
                    guard let cell = tableView.dequeueReusableCell(withIdentifier: ImageTitleCountTableViewCell.reuseIdentifier, for: indexPath) as? ImageTitleCountTableViewCell else {
                        return UITableViewCell()
                    }
                    cell.configure(dm: dm)
                    return cell
                    
                case .add(let text):
                    guard let cell = tableView.dequeueReusableCell(withIdentifier: PlusTitleTableViewCell.reuseIdentifier, for: indexPath) as? PlusTitleTableViewCell else {
                        return UITableViewCell()
                    }
                    cell.configure(title: text)
                    return cell
                }
            }
        )
        
        reactor.pulse(\.$sections)
            .bind(to: rootView.tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
        
        rootView.tableView.rx.setDelegate(self)
            .disposed(by: disposeBag)
        
        reactor.pulse(\.$sections)
            .bind(with: self, onNext: { owner, value in
                owner.sections = value
                
                guard let channel = owner.rootView.tableView.headerView(forSection: 0) as? DropdownArrowTableViewCell else {
                    return
                }
                
                channel.configure(title: owner.sections[0].headerTitle, isExpanded: owner.sections[0].isExpanded)
                
                guard let dm = owner.rootView.tableView.headerView(forSection: 1) as? DropdownArrowTableViewCell else {
                    return
                }
                
                dm.configure(title: owner.sections[1].headerTitle, isExpanded: owner.sections[1].isExpanded)
            })
            .disposed(by: disposeBag)
    }
}

//MARK: - UITableViewDelegate

extension HomeViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        switch section {
        case 0, 1:
            guard let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: DropdownArrowTableViewCell.reuseIdentifier) as? DropdownArrowTableViewCell else {
                return nil
            }
            
            headerView.section = section
            headerView.delegate = self
            
            let section = self.sections[section]
            headerView.configure(title: section.headerTitle, isExpanded: section.isExpanded)
            
            return headerView
            
        case 2:
            guard let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: PlusTitleHeaderTableViewCell.reuseIdentifier) as? PlusTitleHeaderTableViewCell else {
                return nil
            }
            headerView.delegate = self
            headerView.configure(title: self.sections[section].headerTitle)
            return headerView
            
        default: return nil
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.reloadRows(at: [indexPath], with: .automatic)
    }
}

//MARK: - DropdownArrowTableViewCellDelegate

extension HomeViewController: DropdownArrowTableViewCellDelegate {
    func sectionHeaderTapped(section: Int) {
        reactor?.action.onNext(.sectionTapped(section))
    }
}

//MARK: - PlusTitleHeaderTableViewCellDelegate

extension HomeViewController: PlusTitleHeaderTableViewCellDelegate {
    func cellTapped() {
        reactor?.action.onNext(.addTeamMembersTapped)
    }
}
