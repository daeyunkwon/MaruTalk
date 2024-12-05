//
//  WorkspaceEditViewController.swift
//  MaruTalk
//
//  Created by 권대윤 on 12/5/24.
//

import UIKit

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
                
                let image = tempImageView.image
                
                owner.rootView.imageSettingButton.setImage(image, for: .normal)
            }
            .disposed(by: disposeBag)
    }
}
