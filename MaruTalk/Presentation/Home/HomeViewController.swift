//
//  HomeViewController.swift
//  MaruTalk
//
//  Created by 권대윤 on 11/14/24.
//

import UIKit

import ReactorKit
import RxCocoa

final class HomeViewController: BaseViewController<HomeView> {
    
    //MARK: - Properties
    
    weak var coordinator: HomeCoordinator?
    var disposeBag = DisposeBag()
    
    //MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        rootView.doneButton.rx.tap
            .bind(with: self) { owner, _ in
                owner.coordinator?.didFinish()
                print(1111)
            }
            .disposed(by: disposeBag)
    }
    
    //MARK: - Methods
    

}
