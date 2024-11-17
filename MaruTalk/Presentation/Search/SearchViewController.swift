//
//  SearchViewController.swift
//  MaruTalk
//
//  Created by 권대윤 on 11/14/24.
//

import UIKit

import ReactorKit
import RxCocoa

final class SearchViewController: BaseViewController<SearchView> {
    
    //MARK: - Properties
    
    weak var coordinator: SearchCoordinator?
    var disposeBag = DisposeBag()
    
    //MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    //MARK: - Methods
    

}
