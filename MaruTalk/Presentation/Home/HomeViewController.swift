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
    }
    
    //MARK: - Methods
    

}