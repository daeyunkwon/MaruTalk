//
//  OnboardingViewController.swift
//  MaruTalk
//
//  Created by 권대윤 on 10/29/24.
//

import UIKit

import RxCocoa
import RxSwift

final class OnboardingViewController: BaseViewController<OnboardingView> {
    
    //MARK: - Properties
    
    weak var coordinator: OnboardingCoordinator?
    private let disposeBag = DisposeBag()
    
    //MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    //MARK: - Configurations
    
    override func setupNavi() {
        navigationController?.navigationBar.isHidden = true
    }
    
    //MARK: - Bind
    
    override func bind() {
        rootView.startButton.rx.tap
            .bind(with: self) { owner, _ in
                owner.coordinator?.showAuth()
            }
            .disposed(by: disposeBag)
    }
}

