//
//  OnboardingViewController.swift
//  MaruTalk
//
//  Created by 권대윤 on 10/29/24.
//

import UIKit

import RxSwift
import RxCocoa

final class OnboardingViewController: BaseViewController<OnboardingView> {
    
    //MARK: - Properties
    
    private let disposeBag = DisposeBag()
    
    //MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    //MARK: - Methods
    
    override func bind() {
        rootView.startButton.rx.tap
            .bind(with: self) { owner, _ in
                
                let viewControllerToPresent = AuthViewController()
                if let sheet = viewControllerToPresent.sheetPresentationController {
                    sheet.detents = [.custom { _ in 260}]
                    sheet.prefersGrabberVisible = true
                    
                    //배경 어둡게 설정 해제
                    viewControllerToPresent.willDisappear = { [weak self] in
                        
                        self?.view.subviews.forEach({ subview in
                            if subview.backgroundColor == UIColor.black {
                                
                                subview.alpha = 0.5
                                
                                UIView.animate(withDuration: 0.3) {
                                    subview.alpha = 0.0
                                } completion: { _ in
                                    subview.removeFromSuperview()
                                }
                            }
                        })
                    }
                    
                    //배경 어둡게 설정
                    let backgroundView = UIView(frame: owner.view.bounds)
                    backgroundView.backgroundColor = UIColor.black
                    backgroundView.alpha = 0.0
                    owner.view.addSubview(backgroundView)

                    UIView.animate(withDuration: 0.3) {
                        backgroundView.alpha = 0.5
                    }
                }
                owner.present(viewControllerToPresent, animated: true, completion: nil)
            }
            .disposed(by: disposeBag)
    }
}

