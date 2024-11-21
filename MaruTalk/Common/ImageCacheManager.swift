//
//  ImageCacheManager.swift
//  MaruTalk
//
//  Created by 권대윤 on 11/22/24.
//

import UIKit

final class ImageCacheManager {
    static let shared = NSCache<NSString, UIImage>()
    private init() { }
}
