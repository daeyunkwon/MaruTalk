//
//  ProfileViewController.swift
//  MaruTalk
//
//  Created by 권대윤 on 12/2/24.
//

import UIKit
import PhotosUI

import ReactorKit
import RxCocoa
import RxDataSources

final class ProfileViewController: BaseViewController<ProfileView>, View {
    
    //MARK: - Properties
    
    var disposeBag: DisposeBag = DisposeBag()
    weak var coordinator: Coordinator?
    
    init(reactor: ProfileReactor) {
        super.init()
        self.reactor = reactor
    }
    
    private var dataSource: RxTableViewSectionedAnimatedDataSource<ProfileSectionModel>?
    
    //MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        tabBarController?.tabBar.isHidden = false
    }
    
    //MARK: - Configurations
    
    override func setupNavi() {
        navigationItem.title = "내 정보 수정"
    }
    
    //MARK: - Methods
    
    func bind(reactor: ProfileReactor) {
        bindAction(reactor: reactor)
        bindState(reactor: reactor)
    }
}

//MARK: - Bind Action

extension ProfileViewController {
    private func bindAction(reactor: ProfileReactor) {
        rx.methodInvoked(#selector(viewWillAppear(_:)))
            .map { _ in Reactor.Action.fetch }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        rootView.profileImageSettingButton.rx.tap
            .bind(with: self) { owner, _ in
                owner.requestPhotoLibraryPermission()
            }
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
    }
}

//MARK: - PHPickerViewControllerDelegate

extension ProfileViewController: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true, completion: nil)
        
        if let itemProvider = results.first?.itemProvider, itemProvider.canLoadObject(ofClass: UIImage.self) {
            itemProvider.loadObject(ofClass: UIImage.self) {[weak self] object, error in
                if let image = object as? UIImage {
                    if let imageData = image.jpegData(compressionQuality: 0.1) {
                        self?.reactor?.action.onNext(.profileImageChange(imageData))
                    }
                }
            }
        }
    }
    
    private func openPhotoPicker() {
        var configuration = PHPickerConfiguration()
        configuration.selectionLimit = 1 // 최대 선택 가능 수
        configuration.filter = .images
        
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = self
        
        present(picker, animated: true, completion: nil)
    }
    
    private func requestPhotoLibraryPermission() {
        let status = PHPhotoLibrary.authorizationStatus(for: .readWrite)
        
        switch status {
        case .notDetermined:
            //권한 요청
            PHPhotoLibrary.requestAuthorization {[weak self] status in
                guard let self else { return }
                
                DispatchQueue.main.async {
                    self.handlePhotoLibraryAuthorizationStatus(status)
                }
            }
        case .restricted, .denied:
            self.showToastMessage(message: "앨범 접근 권한이 거부되었습니다.", backgroundColor: Constant.Color.brandRed)
        case .authorized, .limited:
            self.openPhotoPicker()
        @unknown default:
            break
        }
    }
    
    private func handlePhotoLibraryAuthorizationStatus(_ status: PHAuthorizationStatus) {
        switch status {
        case .authorized, .limited:
            self.openPhotoPicker()
        case .denied, .restricted:
            self.showToastMessage(message: "앨범 접근 권한이 거부되었습니다.", backgroundColor: Constant.Color.brandRed)
        case .notDetermined:
            break
        @unknown default:
            break
        }
    }
}
