//
//  SignUpViewController.swift
//  MaruTalk
//
//  Created by 권대윤 on 11/2/24.
//

import UIKit

import RxSwift
import RxCocoa

final class SignUpViewController: BaseViewController<SignUpView> {
    
    //MARK: - Properties
    
    weak var coordinator: SignUpCoordinator?
    private let disposeBag = DisposeBag()
    
    
    //MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        coordinator?.didFinish()
    }
    
    //MARK: - Configurations
    
    override func setupNavi() {
        navigationController?.navigationBar.isHidden = true
        
        let titleItem = UINavigationItem(title: "회원가입")
        let closeButton = UIBarButtonItem(image: UIImage(systemName: "xmark")?.applyingSymbolConfiguration(.init(pointSize: 14)), style: .plain, target: self, action: #selector(closeButtonTapped))
        titleItem.leftBarButtonItem = closeButton
        // 네비게이션 아이템 추가
        rootView.customNaviBar.items = [titleItem]
        
//        rootView.customNaviBar.items?[0].leftBarButtonItem?.rx.tap
//            .bind(with: self, onNext: { owner, _ in
//                print(1111111)
//            })
//            .disposed(by: disposeBag)
    }
    
    //MARK: - Methods
    
    @objc func closeButtonTapped() {
        
    }
    
    //MARK: - Bind
    

}
