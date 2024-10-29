//
//  ViewController.swift
//  MaruTalk
//
//  Created by 권대윤 on 10/29/24.
//

import UIKit

import SnapKit

class ViewController: UIViewController {
    
    let label = UILabel()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = Constant.Color.viewSeparator
        
            
        view.addSubview(label)
        label.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        label.text = "가나다라"
        label.layer.borderWidth = 1
        label.layer.borderColor = UIColor.red.cgColor
//        label.font = UIFont.systemFont(ofSize: 12)
        label.font = Constant.Font.title1.0
        label.setTextWithLineHeight(text: "새싹톡은 모두가 함꼐 있을 때 유용합니다.", lineHeight: Constant.Font.title1.1)
        
        
    }
    
    


}

