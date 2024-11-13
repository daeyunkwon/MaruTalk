//
//  WorkspaceAddViewController.swift
//  MaruTalk
//
//  Created by 권대윤 on 11/12/24.
//

import UIKit
import AVFoundation

import ReactorKit
import RxCocoa

final class WorkspaceAddViewController: BaseViewController<WorkspaceAddView>, View {
    
    //MARK: - Properties
    
    var disposeBag: DisposeBag = DisposeBag()
    weak var coordinator: OnboardingCoordinator?
    private let imagePickerController = UIImagePickerController()
    
    //MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imagePickerController.delegate = self
    }
    
    //MARK: - Configurations
    
    override func setupNavi() {
        navigationItem.title = "워크스페이스 생성"
        
        let closeButton = UIBarButtonItem(image: UIImage(systemName: "xmark")?.applyingSymbolConfiguration(.init(pointSize: 14)), style: .plain, target: self, action: nil)
        navigationItem.leftBarButtonItem = closeButton
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
            // 권한이 아직 설정되지 않았으므로 권한 요청
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
    private func bindAction(reactor: Reactor) {
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
                print(11111)
            }
            .disposed(by: disposeBag)
        
        reactor.state.map { $0.isCameraVisible }
            .filter { $0 == true }
            .bind(with: self) {[weak self] owner, _ in
                guard let self else { return }
                //카메라 권한 체크
                owner.requestCameraPermission { [weak self] granted in
                    if granted {
                        self?.imagePickerController.sourceType = .camera
                        self?.present(owner.imagePickerController, animated: true)
                        
                    } else {
                        owner.showToastMessage(message: "카메라 접근 권한이 거부되었습니다.", backgroundColor: Constant.Color.brandRed)
                    }
                }
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
        
        if let imageData = image.jpegData(compressionQuality: 0.7) {
            reactor?.action.onNext(.selectPhotoImage(imageData))
        }
        
        picker.dismiss(animated: true, completion: nil)
      }
}
