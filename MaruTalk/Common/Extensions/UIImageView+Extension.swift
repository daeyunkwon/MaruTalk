//
//  UIImageView+Extension.swift
//  MaruTalk
//
//  Created by 권대윤 on 11/22/24.
//

import UIKit

extension UIImageView {
    func setImage(imagePath: String?) {
        
        guard let path = imagePath else { return }
        
        // 캐시에 저장된 이미지 확인
        if let cachedImage = ImageCacheManager.shared.object(forKey: path as NSString) {
            self.image = cachedImage
            print("DEBUG: 이미지 캐시 히트")
            return
        }
        // 캐시된 이미지 없을 경우 다운로드
        NetworkManager.shared.downloadImageData(imagePath: imagePath) { data in
            DispatchQueue.main.async {
                ImageCacheManager.shared.setObject(UIImage(data: data) ?? UIImage(), forKey: path as NSString)
                self.image = UIImage(data: data)
            }
        }
    }
}
