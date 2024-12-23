![Swift](https://img.shields.io/badge/Swift-5.10-orange)
![Xcode](https://img.shields.io/badge/Xcode-15.3-blue)


# 마루톡  <img width="100" alt="image" src="https://github.com/user-attachments/assets/9000de3d-9c3b-4e11-891e-97c04df7ae1c" align="left">
> 개설된 워크스페이스 내 채널에서 그룹 채팅으로 소통하고, 멤버들과 1:1 개인 채팅도 즐길 수 있는 채팅 앱이에요 ✨

<br>

## 📖 프로젝트 정보
- 개발 기간: `2024.10.29 ~ 2024.12.16 (49일)`
- 최소 지원 버전: `iOS 16.0 이상`
- 사용 언어 및 도구: `Swift 5.10` `Xcode 15.3`
- 팀 구성:
  - `iOS 개발(본인)`
  - `서버 개발(SeSAC memolease)`

<br>

## 🛠️ 사용 기술

- 언어: `Swift` `iOS`
- 프레임워크: `UIKit`
- 아키텍처: `MVVM + Coordinator`
- 그 외 기술:
  - `ReactorKit`
  - `RxSwift` `RxCocoa` `RxDataSources`
  - `CodeBaseUI` `SnapKit`
  - `Alamofire` `Socket.IO-Client-Swift`
  - `RealmSwift` `UserDefaults` `Keychain`
  - `AuthenticationServices` `KakaoSDK(RxSwift)`
  - `PhotosUI`
  - `Toast-Swift`
  - `Firebase Analytics` `Firebase Crashlytics`
 
<br>

## 📱 주요 화면 및 기능

### 핵심 기능 소개
> - 애플 및 카카오를 이용한 소셜 로그인 및 이메일 로그인을 통한 인증 방식을 제공합니다.
> - 워크스페이스 및 채널을 조회, 생성, 수정, 삭제할 수 있는 기능을 제공합니다.
> - 관리자와 일반 사용자의 역할에 맞는 접근 권한이 차등 제공됩니다.
> - 채널을 통한 그룹 채팅과 DM을 통한 1:1 실시간 채팅 기능을 제공합니다.

<br>

### 홈 화면
> - 좌측 상단에 현재 워크스페이스명이 표시됩니다.
> - 워크스페이스명을 선택하거나 화면 왼쪽 가장자리에서 스와이프 제스처를 사용해 워크스페이스 목록 화면으로 이동할 수 있습니다.
> - 우측 상단에 현재 사용자의 프로필 이미지가 표시되며, 선택 시 프로필 수정 화면으로 화면 전환됩니다.
> - 현재 사용자가 참여 중인 채널 목록과 채널별 읽지 않은 채팅 개수를 조회할 수 있습니다.
> - 현재 사용자의 DM 방 목록을 조회할 수 있습니다.
> - 채널 및 DM 방 목록은 `화살표(>)` 버튼을 선택하여 펼치거나 숨길 수 있습니다.
> - 채널 목록에서 특정 채널을 선택하면 해당 채널의 채팅 화면으로 화면 전환됩니다.
> - `+ 채널 추가` 버튼을 선택하면 새로운 채널을 생성하거나 참여 중이지 않은 채널 목록을 조회할 수 있습니다.
> - `+ 팀원 추가` 버튼은 워크스페이스 관리자만 사용할 수 있으며, 선택 시 팀원 초대 화면으로 화면 전환됩니다.

| 홈 화면 |
| :---: |
| <img src="https://github.com/user-attachments/assets/52b06702-bbc0-4190-9b52-de3e55dbb39b" width="200"> |

### 워크스페이스 목록 화면
> - 현재 사용자가 속한 워크스페이스 목록을 조회할 수 있습니다.
> - 현재 선택된 워크스페이스는 파란색으로 표시됩니다.
> - 특정 워크스페이스를 선택하면 해당 워크스페이스로 변경되며, 홈 화면에 반영됩니다.
> - 일반 사용자는 `설정` 버튼을 선택하면 워크스페이스 나가기 Action Sheet가 표시됩니다.
>   - "나가기"를 선택하면 해당 워크스페이스에서 탈퇴됩니다.
> - 관리자는 `설정` 버튼을 선택하면 워크스페이스 편집, 관리자 변경, 삭제 Action Sheet가 표시됩니다.
>   - "편집"을 선택하면 워크스페이스 편집 화면으로 화면 전환됩니다.
>   - "관리자 변경"을 선택하면 워크스페이스 관리자 변경 화면으로 화면 전환됩니다.
>   - "삭제"를 선택하면 해당 워크스페이스가 삭제됩니다.
> - `+ 워크스페이스 추가` 버튼을 선택하면 워크스페이스 생성 화면으로 화면 전환됩니다.

| 워크스페이스 목록 화면 |
| :---: |
| <img src="https://github.com/user-attachments/assets/a7db2177-dfbe-48cb-b571-caff1b9cf8ca" width="200"> |

### 채널 채팅 화면
> - 모든 채팅 내역을 조회할 수 있습니다.
> - 새로운 메시지를 실시간으로 수신할 수 있습니다.
> - 화면 상단 중앙에는 채널명과 참여 중인 인원 수가 표시됩니다.
> - 우측 상단에 `설정` 버튼을 선택하면 채널 설정 화면으로 화면 전환됩니다.
> - 메시지 입력 영역 좌측에 있는 `첨부(+)` 버튼을 선택하면 앨범에서 최대 5장의 사진을 첨부할 수 있습니다.
> - 메시지 입력 영역에 첨부된 사진에서 `사진 제거(x)` 버튼을 선택하면 해당 사진을 첨부 취소할 수 있습니다.
> - 메시지 입력 영역 우측에 `전송` 버튼을 선택하여 메시지를 전송할 수 있습니다.
> - 메시지 입력 영역에 내용이 없으면 `전송` 버튼이 비활성화됩니다.

| 채널 채팅 화면 |
| :---: |
| <img src="https://github.com/user-attachments/assets/cd2b70af-0e07-4176-ac65-5f8aab2b4af3" width="200"> | 

### 채널 설정 화면
> - 상단 영역에는 채널명과 채널 설명을 조회할 수 있습니다.
> - 중앙 영역에는 채널에 참여 중인 멤버의 프로필 이미지와 닉네임을 조회할 수 있습니다.
> - 멤버 목록은 `화살표(>)` 버튼을 선택하여 펼치거나 숨길 수 있습니다.
> - 일반 사용자는 하단에 `채널 나가기` 버튼만 표시됩니다.
> - `채널 편집` 버튼을 선택하면 채널 편집 화면으로 화면 전환됩니다.
> - `채널 나가기` 버튼을 선택하면 해당 채널에서 탈퇴됩니다.
> - `채널 관라자 변경` 버튼을 선택하면 채널 관리자 변경 화면으로 화면 전환됩니다.
> - `채널 삭제` 버튼을 선택하면 해당 채널이 삭제됩니다.

| 채널 설정 화면 |
| :---: |
| <img src="https://github.com/user-attachments/assets/61cc3748-f29d-4c56-83c5-80f2605b11f0" width="200"> | 

### DM 목록 화면
> - 우측 상단에 현재 사용자의 프로필 이미지가 표시되며, 선택 시 프로필 수정 화면으로 화면 전환됩니다.
> - 워크스페이스에 소속된 멤버 목록을 좌우 스크롤을 통해 조회할 수 있습니다.
> - 1:1 대화 중인 DM 방 목록과 각 방의 읽지 않은 채팅 개수를 조회할 수 있습니다.
> - 멤버 프로필 또는 DM 방 목록을 선택하면 DM 채팅 화면으로 화면 전환됩니다.

| DM 목록 화면 |
| :---: |
| <img src="https://github.com/user-attachments/assets/69a3b675-0d2f-4c1a-bcd9-0ca65981a46d" width="200"> | 


<br>

## 📡 주요 기술
- MVVM 패턴을 도입해 ViewController와 View는 화면을 그리는 역할에만 집중하게 하고, 데이터 관리와 로직 처리는 ViewModel에서 담당하도록 역할을 분리했습니다.
- Coordinator 패턴을 도입해 화면 전환에 대한 책임을 ViewController에서 분리함으로써 코드의 가독성과 유지보수성을 향상시켰습니다.
- ReactorKit을 도입해 예측 가능한 데이터 흐름을 구축하고, 액션(Action)과 상태(State) 변경을 명확하게 정의했습니다.
- RxSwift와 RxCocoa를 활용하여 비동기 이벤트 스트림을 관리하고, UI와 데이터 간의 반응형 바인딩을 구현했습니다.
- Router 패턴을 도입하여 모든 API를 한 곳에서 관리하기 쉽게 했습니다.
- Socket.IO를 사용해 서버로부터 실시간 이벤트를 수신하여, 실시간 채팅 메시지를 처리할 수 있도록 구현했습니다.
- Access Token이 만료되면 Refresh Token을 사용해 새 토큰을 발급받아 자동으로 요청을 재처리하는 기능을 구현했습니다.
- Access Token과 Refresh Token 등의 민감한 정보는 Keychain에 저장하여 보안성을 강화했습니다.
- NSCache를 이용해 다운로드한 이미지를 캐싱하여 네트워크 요청 횟수를 줄여 성능을 개선했습니다.
- multipart/form-data 타입을 사용하여 서버에 이미지 파일을 전송할 수 있도록 구현했습니다.
- RealmSwift를 사용해 채팅 데이터를 로컬에 저장하고 조회 및 삭제할 수 있도록 구현했습니다.
- PHPickerViewController를 기반으로 접근 권한 요청 및 사진 선택 로직을 캡슐화하여, 여러 화면에서 재사용 가능하도록 설계했습니다.
- 애플과 카카오 소셜 로그인 기능을 구현하여 사용자가 간편하게 앱에 로그인할 수 있도록 했습니다.
- 제네릭을 활용한 BaseViewController 구현을 통해, UIViewController에서 UI 관련 코드를 분리하여 재사용성과 유지보수성을 향상시켰습니다.
- Firebase Analytics와 Crashlytics를 도입해 사용자 행동 데이터 및 앱 크래시 정보를 수집할 수 있도록 구현했습니다.



<br>

## 🚀 문제 및 해결 과정

### 1. 이미지 로딩 지연 문제

#### 문제 상황

채널 설정 화면이나 DM 목록 화면에 진입 시 보여지는 모든 사용자의 프로필 이미지를 표시하는 과정에서 이미지 로딩 시간이 다소 지연되는 문제가 발생했습니다. 이미지 로딩 시간 지연은 사용자 경험에 부정적인 영향을 줄 수 있으므로 해결이 필요한 문제로 판단했습니다.

#### 문제 원인

서버로부터 각 사용자의 프로필 이미지를 요청하고 다운로드하는 통신 작업이 화면에 진입할 때마다 수행되고 있었습니다. 통신 작업이 포함되어 있어 시간이 걸릴 수밖에 없었고, 네트워크 환경이 좋지 않은 경우 이미지 로딩 속도가 더욱 느려지는 경향이 있었습니다.

#### 해결 방법

해당 문제는 NSCache를 사용해 이미 다운로드된 이미지를 캐시하고 재사용함으로써 통신 작업을 최소화하는 방법으로 이미지 로딩 시간을 개선했습니다.

```swift
final class ImageCacheManager {
    static let shared = NSCache<NSString, UIImage>()
    private init() { }
}
```

이미지 URL인 imagePath를 받아서, 이미 캐시된 이미지가 있으면 그것을 사용해 이미지를 표시하고 네트워크 통신 작업은 생략할 수 있었습니다. 

```swift
extension UIImageView {
    func setImage(imagePath: String?) {
        
        guard let path = imagePath else { return }
        
        // 1. 캐시에 저장된 이미지 확인
        if let cachedImage = ImageCacheManager.shared.object(forKey: path as NSString) {
            self.image = cachedImage
            print("DEBUG: 이미지 캐시 히트")
            return
        }
        // 2. 캐시된 이미지 없을 경우 네트워크에서 이미지 다운로드
        NetworkManager.shared.downloadImageData(imagePath: imagePath) { data in
            DispatchQueue.main.async {
                ImageCacheManager.shared.setObject(UIImage(data: data) ?? UIImage(), forKey: path as NSString)
                self.image = UIImage(data: data)
            }
        }
    }
}
```

<br><br>


### 2. 반복되는 사진 선택 로직 개선 고민

#### 문제 상황

앨범에서 사진을 불러오기 위해 PHPickerViewControllerDelegate를 채택하고, PHPickerViewController를 표시한 뒤 선택된 이미지를 JPEG Data로 변환하는, 다음과 같은 로직이 필요했습니다.

```swift
extension ChannelChattingViewController: PHPickerViewControllerDelegate {
    
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        dismiss(animated: true)
        
        var selectedImageDataList: [Data] = []
        let dispatchGroup = DispatchGroup()
        
        for (index, result) in results.enumerated() {
            guard index < 5 else { break }
            
            dispatchGroup.enter()
            result.itemProvider.loadObject(ofClass: UIImage.self) { (object, error) in
                if let image = object as? UIImage {
                    if let data = image.jpegData(compressionQuality: 0.1) {
                        selectedImageDataList.append(data)
                        dispatchGroup.leave()
                    }
                }
            }
        }
        
        dispatchGroup.notify(queue: .main) { [weak self] in
            if !selectedImageDataList.isEmpty {
                self?.selectedImages.accept(selectedImageDataList)
            }
        }
    }
    
    func openPHPicker() {
        var configuration = PHPickerConfiguration()
        configuration.selectionLimit = 5
        configuration.filter = .images
        
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = self
        present(picker, animated: true)
    }
}
```

이 로직은 사진 선택 기능이 필요한 다음 5개의 ViewController에서 거의 동일한 형태로 반복되고 있었습니다.
- ChannelChattingViewController
- DMChattingViewController
- ProfileViewController
- WorkspaceAddViewController
- WorkspaceEditViewController

#### 문제 원인

각각의 ViewController에서 거의 동일한 형태의 코드가 중복되어 사용되고 있었습니다.
각 ViewController마다 해당 로직을 중복으로 작성하는 대신, 코드를 재사용할 수 있는 방법을 고민했습니다.

#### 해결 방법

PHPicker 관련 로직을 하나의 PHPickerManager 클래스로 캡슐화하여 재사용 가능한 구조로 개선했습니다.

```swift
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
```

각 ViewController에서는 PHPickerManager 객체의 `openPhotoPicker(in:limit:completion:)` 메서드만 호출해주면 사진 선택 기능을 사용할 수 있는 방식으로 코드 재사용성을 개선했습니다.

```swift
self.phpickerManager.requestPhotoLibraryPermission { isGranted in
    if isGranted {
        //권한 허용된 경우
        owner.phpickerManager.openPhotoPicker(in: owner, limit: 1) { [weak owner] datas in
            if let imageData = datas.first {
                owner?.rootView.imageSettingButton.setImage(UIImage(data: imageData), for: .normal)
                owner?.reactor?.action.onNext(.selectPhotoImage(imageData))
            }
        }
    } else {
        //권한 거부된 경우
        owner.showToastMessage(message: "카메라 접근 권한이 거부되었습니다.", backgroundColor: Constant.Color.brandRed)
    }
}
```

<br><br>

### 3. 



