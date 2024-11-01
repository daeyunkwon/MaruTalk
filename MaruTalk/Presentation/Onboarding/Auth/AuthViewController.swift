//
//  AuthViewController.swift
//  MaruTalk
//
//  Created by 권대윤 on 10/31/24.
//

import UIKit

final class AuthViewController: BaseViewController<AuthView> {
    
    //MARK: - Properties
    
    var willDisappear: () -> Void = { }
    
    //MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        willDisappear()
    }
    
    //MARK: - Methods
    

}
