//
//  WorkspaceAddViewController.swift
//  MaruTalk
//
//  Created by 권대윤 on 11/12/24.
//

import AVFoundation
import UIKit

import ReactorKit
import RxCocoa

final class WorkspaceAddViewController: BaseViewController<WorkspaceAddView>, View {
    
    //MARK: - Properties
    
    var disposeBag: DisposeBag = DisposeBag()
    weak var coordinator: WorkspaceCoordinator?
    
    private let imagePickerController = UIImagePickerController()
    
    private let xMarkButton: UIBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "xmark")?.applyingSymbolConfiguration(.init(pointSize: 14)), style: .plain, target: nil, action: nil)
    
    init(reactor: WorkspaceAddReactor) {
        super.init()
        self.reactor = reactor
    }
    
    private let phpickerManager = PHPickerManager()
    
    //MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imagePickerController.delegate = self
    }
    
    //MARK: - Configurations
    
    override func setupNavi() {
        navigationItem.title = "워크스페이스 생성"
        navigationItem.leftBarButtonItem = xMarkButton
    }
    
    //MARK: - Methods
    
    func bind(reactor: WorkspaceAddReactor) {
        bindAction(reactor: reactor)
        bindState(reactor: reactor)
    }
    
    private func showActionSheetForPhoto(reactor: WorkspaceAddReactor) {
        let alert = UIAlertController(title: "이미지 설정", message: nil, preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "앨범에서 사진 선택", style: .default, handler: { albumAction in
            reactor.action.onNext(.selectPhotoFromAlbum)
        }))
        
        alert.addAction(UIAlertAction(title: "카메라로 사진 선택", style: .default, handler: { cameraAction in
            reactor.action.onNext(.selectPhotoFromCamera)
        }))
        
        alert.addAction(UIAlertAction(title: "취소", style: .cancel))
        
        self.present(alert, animated: true)
    }
    
    private func requestCameraPermission(completion: @escaping (Bool) -> Void) {
        let cameraAuthorizationStatus = AVCaptureDevice.authorizationStatus(for: .video)
        
        switch cameraAuthorizationStatus {
        case .notDetermined:
            //권한 요청
            AVCaptureDevice.requestAccess(for: .video) { granted in
                DispatchQueue.main.async {
                    completion(granted)
                }
            }
            
        case .restricted, .denied:
            // 권한이 거부되거나 제한된 경우
            completion(false)
            
        case .authorized:
            // 권한이 이미 허용된 경우
            completion(true)
            
        @unknown default:
            // 예외 처리
            completion(false)
        }
    }
}

//MARK: - Bind Action

extension WorkspaceAddViewController {
    private func bindAction(reactor: WorkspaceAddReactor) {
        rootView.nameFieldView.inputTextField.rx.text.orEmpty
            .map { Reactor.Action.inputName($0) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        rootView.descriptionFieldView.inputTextField.rx.text.orEmpty
            .map { Reactor.Action.inputDescription($0) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        rootView.imageSettingButton.rx.tap
            .map { Reactor.Action.imageSettingButtonTapped }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        xMarkButton.rx.tap
            .map { Reactor.Action.xButtonTapped }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        rootView.doneButton.rx.tap
            .map { Reactor.Action.doneButtonTapped }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
    }
}

//MARK: - Bind State

extension WorkspaceAddViewController {
    private func bindState(reactor: WorkspaceAddReactor) {
        reactor.state.map { $0.isDoneButtonEnabled }
            .distinctUntilChanged()
            .bind(with: self) { owner, value in
                owner.rootView.doneButton.setButtonEnabled(isEnabled: value)
            }
            .disposed(by: disposeBag)
        
        reactor.state.map { $0.isActionSheetVisible }
            .filter { $0 == true }
            .bind(with: self) { owner, _ in
                owner.showActionSheetForPhoto(reactor: reactor)
            }
            .disposed(by: disposeBag)
        
        reactor.state.map { $0.isAlbumVisible }
            .filter { $0 == true }
            .bind(with: self) { owner, _ in
                owner.phpickerManager.requestPhotoLibraryPermission { isGranted in
                    if isGranted {
                        //권한 허용된 경우
                        owner.phpickerManager.openPhotoPicker(in: owner, limit: 1) { [weak owner] datas in
                            if let imageData = datas.first {
                                owner?.rootView.imageSettingButton.setImage(UIImage(data: imageData), for: .normal)
                                owner?.reactor?.action.onNext(.selectPhotoImage(imageData))
                            }
                        }
                    } else {
                        //권한 거부된 경우
                        owner.showToastMessage(message: "카메라 접근 권한이 거부되었습니다.", backgroundColor: Constant.Color.brandRed)
                    }
                }
            }
            .disposed(by: disposeBag)
        
        reactor.state.map { $0.isCameraVisible }
            .filter { $0 == true }
            .bind(with: self) { owner, _ in
                //카메라 권한 체크
                owner.requestCameraPermission { granted in
                    if granted {
                        owner.imagePickerController.sourceType = .camera
                        owner.present(owner.imagePickerController, animated: true)
                        
                    } else {
                        owner.showToastMessage(message: "카메라 접근 권한이 거부되었습니다.", backgroundColor: Constant.Color.brandRed)
                    }
                }
            }
            .disposed(by: disposeBag)
        
        reactor.state.map { $0.navigateToHome }
            .filter { $0 == true }
            .distinctUntilChanged()
            .bind(with: self) { owner, _ in
                owner.coordinator?.didFinishWorkspaceAdd()
                owner.coordinator?.didFinish()
            }
            .disposed(by: disposeBag)
        
        reactor.pulse(\.$toastMessage)
            .compactMap { $0 }
            .bind(with: self) { owner, value in
                owner.showToastMessage(message: value, backgroundColor: Constant.Color.brandRed)
            }
            .disposed(by: disposeBag)
        
        reactor.state.map { $0.networkError }
            .filter { $0.0 != .empty }
            .bind(with: self) { owner, value in
                owner.rootView.endEditing(true) //토스트 확인을 위해 키보드 닫기
                owner.showToastForNetworkError(api: value.0, errorCode: value.1)
            }
            .disposed(by: disposeBag)
        
        reactor.state.map { $0.isCreateWorkspaceSuccess }
            .filter { $0 == true }
            .bind(with: self) { owner, _ in
                owner.coordinator?.didFinishWorkspaceAdd()
                owner.coordinator?.didFinish()
            }
            .disposed(by: disposeBag)
    }
}

//MARK: - UIImagePickerControllerDelegate

extension WorkspaceAddViewController: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else {
            picker.dismiss(animated: true)
            return
        }
        
        rootView.imageSettingButton.setImage(image, for: .normal)
        
        if let imageData = image.jpegData(compressionQuality: 0.1) {
            reactor?.action.onNext(.selectPhotoImage(imageData))
        }
        
        picker.dismiss(animated: true, completion: nil)
      }
}
