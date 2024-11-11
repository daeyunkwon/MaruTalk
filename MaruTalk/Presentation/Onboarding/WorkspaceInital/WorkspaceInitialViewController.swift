//
//  WorkspaceInitialViewController.swift
//  MaruTalk
//
//  Created by 권대윤 on 11/11/24.
//

import UIKit

final class WorkspaceInitialViewController: BaseViewController<WorkspaceInitialView> {
    
    //MARK: - Properties
    
    weak var coordinator: OnboardingCoordinator?
    
    //MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    //MARK: - Configurations
    
    override func setupNavi() {
        navigationItem.title = "시작하기"
        
        let closeButton = UIBarButtonItem(image: UIImage(systemName: "xmark")?.applyingSymbolConfiguration(.init(pointSize: 14)), style: .plain, target: self, action: nil)
        navigationItem.leftBarButtonItem = closeButton
    }
    
    
    //MARK: - Methods
    

}
