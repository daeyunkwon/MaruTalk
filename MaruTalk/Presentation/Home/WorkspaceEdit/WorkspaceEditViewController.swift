//
//  WorkspaceEditViewController.swift
//  MaruTalk
//
//  Created by 권대윤 on 12/5/24.
//

import UIKit
import PhotosUI

import ReactorKit
import RxCocoa

final class WorkspaceEditViewController: BaseViewController<WorkspaceAddView>, View {
    
    //MARK: - Properties
    
    var disposeBag: DisposeBag = DisposeBag()
    weak var coordinator: HomeCoordinator?
    
    init(reactor: WorkspaceEditReactor) {
        super.init()
        self.reactor = reactor
    }
    
    private let xMarkButton: UIBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "xmark")?.applyingSymbolConfiguration(.init(pointSize: 14)), style: .plain, target: nil, action: nil)
    
    //MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    //MARK: - Configurations
    
    override func setupNavi() {
        navigationItem.title = "워크스페이스 편집"
        navigationItem.leftBarButtonItem = xMarkButton
    }
    
    //MARK: - Methods
    
    func bind(reactor: WorkspaceEditReactor) {
        bindAction(reactor: reactor)
        bindState(reactor: reactor)
    }
}

//MARK: - Bind Action

extension WorkspaceEditViewController {
    private func bindAction(reactor: WorkspaceEditReactor) {
        rootView.nameFieldView.inputTextField.rx.text.orEmpty
            .skip(1)
            .map { Reactor.Action.inputName($0) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        rootView.descriptionFieldView.inputTextField.rx.text.orEmpty
            .skip(1)
            .map { Reactor.Action.inputDescription($0) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        rootView.doneButton.rx.tap
            .map { Reactor.Action.doneButtonTapped }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        xMarkButton.rx.tap
            .map { Reactor.Action.xMarkButtonTapped }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        rootView.imageSettingButton.rx.tap
            .bind(with: self) { owner, _ in
                owner.openPhotoPicker()
            }
            .disposed(by: disposeBag)
    }
}

//MARK: - Bind State

extension WorkspaceEditViewController {
    private func bindState(reactor: WorkspaceEditReactor) {
        reactor.pulse(\.$workspaceName)
            .compactMap { $0 }
            .bind(to: rootView.nameFieldView.inputTextField.rx.text)
            .disposed(by: disposeBag)
        
        reactor.pulse(\.$workspaceDescription)
            .compactMap { $0 }
            .bind(to: rootView.descriptionFieldView.inputTextField.rx.text)
            .disposed(by: disposeBag)
        
        reactor.pulse(\.$workspaceImagePath)
            .compactMap { $0 }
            .bind(with: self) { owner, value in
                let tempImageView = UIImageView()
                tempImageView.setImage(imagePath: value)
                
                //초기 이미지 데이터 파일 전달해두기
                let image = tempImageView.image ?? UIImage()
                if let imageData = image.jpegData(compressionQuality: 0.1) {
                    owner.reactor?.action.onNext(.selectPhotoImage(imageData))
                }
                
                owner.rootView.imageSettingButton.setImage(image, for: .normal)
            }
            .disposed(by: disposeBag)
        
        reactor.pulse(\.$isDoneButtonEnabled)
            .compactMap { $0 }
            .bind(to: rootView.doneButton.rx.isEnabled)
            .disposed(by: disposeBag)
        
        reactor.pulse(\.$shouldNavigateToWorkspaceLit)
            .compactMap { $0 }
            .bind(with: self) { owner, _ in
                owner.coordinator?.didFinishWorkspaceEdit()
            }
            .disposed(by: disposeBag)
        
        reactor.pulse(\.$networkError)
            .compactMap { $0 }
            .bind(with: self) { owner, value in
                owner.showToastForNetworkError(api: value.0, errorCode: value.1)
            }
            .disposed(by: disposeBag)
    }
}

//MARK: - PHPickerViewControllerDelegate

extension WorkspaceEditViewController: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true, completion: nil)
        
        if let itemProvider = results.first?.itemProvider, itemProvider.canLoadObject(ofClass: UIImage.self) {
                itemProvider.loadObject(ofClass: UIImage.self) {[weak self] object, error in
                    if let image = object as? UIImage {
                        DispatchQueue.main.async {
                            self?.rootView.imageSettingButton.setImage(image, for: .normal)
                            
                            if let imageData = image.jpegData(compressionQuality: 0.1) {
                                self?.reactor?.action.onNext(.selectPhotoImage(imageData))
                            }
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
}
