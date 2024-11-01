//
//  BaseViewController.swift
//  MaruTalk
//
//  Created by 권대윤 on 10/30/24.
//

import UIKit

class BaseViewController<View: UIView>: UIViewController {
    
    let rootView: View
    
    init() {
        self.rootView = View()
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        self.view = rootView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavi()
        bind()
    }
    
    func setupNavi() { }
    
    func bind() { }
}
