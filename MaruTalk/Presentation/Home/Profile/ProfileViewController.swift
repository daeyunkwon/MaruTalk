//
//  ProfileViewController.swift
//  MaruTalk
//
//  Created by 권대윤 on 12/2/24.
//

import UIKit

import ReactorKit
import RxCocoa
import RxDataSources

final class ProfileViewController: BaseViewController<ProfileView>, View {
    
    //MARK: - Properties
    
    var disposeBag: DisposeBag = DisposeBag()
    weak var coordinator: ProfileCoordinator?
    
    init(reactor: ProfileReactor) {
        super.init()
        self.reactor = reactor
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        self.coordinator?.didFinish()
    }
    
    private var dataSource: RxTableViewSectionedAnimatedDataSource<ProfileSectionModel>?
    
    private let phpickerManager = PHPickerManager()
    
    //MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNotification()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.title = "내 정보 수정"
        tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        tabBarController?.tabBar.isHidden = false
        navigationItem.title = ""
    }
    
    //MARK: - Configurations
    
    private func setupNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleProfileEditComplete), name: .profileEditComplete, object: nil)
    }
    
    //MARK: - Methods
    
    @objc private func handleProfileEditComplete(notification: Notification) {
        if let user = notification.userInfo?[NotificationUserInfoKey.user] as? User {
            self.reactor?.action.onNext(.update(user))
        }
    }
    
    func bind(reactor: ProfileReactor) {
        bindAction(reactor: reactor)
        bindState(reactor: reactor)
    }
}

//MARK: - Bind Action

extension ProfileViewController {
    private func bindAction(reactor: ProfileReactor) {
        rx.methodInvoked(#selector(viewDidLoad))
            .map { _ in Reactor.Action.fetch }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        rootView.profileImageSettingButton.rx.tap
            .bind(with: self) { [weak self] owner, _ in
                guard let self else { return }
                owner.phpickerManager.requestPhotoLibraryPermission { isGranted in
                    if isGranted {
                        //권한 허용된 경우
                        self.phpickerManager.openPhotoPicker(in: self, limit: 1) { datas in
                            if let imageData = datas.first {
                                self.reactor?.action.onNext(.profileImageChange(imageData))
                            }
                        }
                    } else {
                        //권한 거부된 경우
                        self.showToastMessage(message: "앨범 접근 권한이 거부되었습니다.", backgroundColor: Constant.Color.brandRed)
                    }
                }
            }
            .disposed(by: disposeBag)
        
        rootView.tableView.rx.itemSelected
            .bind(with: self) { owner, indexPath in
                owner.rootView.tableView.deselectRow(at: indexPath, animated: true)
            }
            .disposed(by: disposeBag)
        
        let modelSelectedStream = rootView.tableView.rx.modelSelected(ProfileSectionItem.self)
            .share()
        
        modelSelectedStream
            .filter { $0.title == "로그아웃" }
            .bind(with: self) { [weak self] owner, _ in
                guard let self else { return }
                owner.showAlert(title: "로그아웃", message: "로그아웃 하시겠습니까?", actions: [
                    ("확인", { self.reactor?.action.onNext(.logout) })
                ])
            }
            .disposed(by: disposeBag)
        
        modelSelectedStream
            .filter { $0.title == "닉네임" }
            .map { _ in Reactor.Action.selectNickname }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        modelSelectedStream
            .filter { $0.title == "연락처" }
            .map { _ in Reactor.Action.selectPhoneNumber }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
    }
}

//MARK: - Bind State

extension ProfileViewController {
    private func bindState(reactor: ProfileReactor) {
        let dataSource = RxTableViewSectionedAnimatedDataSource<ProfileSectionModel>(
            configureCell: { datasource, tableView, indexPath, item in
                guard let cell = tableView.dequeueReusableCell(withIdentifier: ProfileSettingTableViewCell.reuseIdentifier) as? ProfileSettingTableViewCell else {
                    return UITableViewCell()
                }
                
                cell.settingNameLabel.text = item.title
                cell.settingValueLabel.text = item.subTitle
                return cell
            }
        )
        
        reactor.pulse(\.$sections)
            .bind(to: rootView.tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
        
        reactor.pulse(\.$networkError)
            .compactMap { $0 }
            .bind(with: self) { owner, value in
                owner.showToastForNetworkError(api: value.0, errorCode: value.1)
            }
            .disposed(by: disposeBag)
        
        reactor.pulse(\.$profileImagePath)
            .compactMap { $0 }
            .bind(with: self) { owner, value in
                owner.rootView.profileImageView.setImage(imagePath: value)
            }
            .disposed(by: disposeBag)
        
        reactor.pulse(\.$navigateToOnboarding)
            .compactMap { $0 }
            .bind(with: self) { owner, _ in
                owner.coordinator?.didFinish(isNavigateToOnboarding: true)
            }
            .disposed(by: disposeBag)
        
        reactor.pulse(\.$navigateToNicknameEdit)
            .compactMap { $0 }
            .bind(with: self) { owner, value in
                owner.coordinator?.showNicknameEdit(user: value)
            }
            .disposed(by: disposeBag)
        
        reactor.pulse(\.$navigateToPhoneNumberEdit)
            .compactMap { $0 }
            .bind(with: self) { owner, value in
                owner.coordinator?.showPhoneNumberEdit(user: value)
            }
            .disposed(by: disposeBag)
    }
}
