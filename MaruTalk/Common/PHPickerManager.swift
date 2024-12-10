//
//  PHPickerManager.swift
//  MaruTalk
//
//  Created by 권대윤 on 12/10/24.
//

import UIKit
import PhotosUI

final class PHPickerManager: PHPickerViewControllerDelegate {
    
    private var completion: (([Data]) -> Void)?
    
    private var limit: Int = 1
    
    func requestPhotoLibraryPermission(completion: @escaping (Bool) -> Void) {
        let status = PHPhotoLibrary.authorizationStatus(for: .readWrite)
        
        switch status {
        case .notDetermined:
            // 권한 요청
            PHPhotoLibrary.requestAuthorization { status in
                DispatchQueue.main.async {
                    switch status {
                    case .authorized, .limited:
                        completion(true)
                    case .denied, .restricted:
                        //self.showToastMessage(message: "앨범 접근 권한이 거부되었습니다.", backgroundColor: Constant.Color.brandRed)
                        completion(false)
                    case .notDetermined:
                        break
                    @unknown default:
                        break
                    }
                    completion(status == .authorized || status == .limited)
                }
            }
        case .authorized, .limited:
            completion(true)
        case .denied, .restricted:
            completion(false)
        @unknown default:
            completion(false)
        }
    }
    
    func openPhotoPicker(in viewController: UIViewController, limit: Int, completion: @escaping ([Data]) -> Void) {
        self.completion = completion
        self.limit = limit
        
        var configuration = PHPickerConfiguration()
        configuration.selectionLimit = limit
        configuration.filter = .images
        
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = self
        
        viewController.present(picker, animated: true, completion: nil)
    }
    
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true, completion: nil)
        
        var selectedImageDataList: [Data] = []
        let dispatchGroup = DispatchGroup()
        
        for (index, result) in results.enumerated() {
            guard index < self.limit else { break }
            
            dispatchGroup.enter()
            result.itemProvider.loadObject(ofClass: UIImage.self) { (object, error) in
                if let image = object as? UIImage, let data = image.jpegData(compressionQuality: 0.1) {
                    selectedImageDataList.append(data)
                }
                dispatchGroup.leave()
            }
        }
        
        dispatchGroup.notify(queue: .main) { [weak self] in
            self?.completion?(selectedImageDataList)
        }
    }
}
