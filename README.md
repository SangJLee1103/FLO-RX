# FLO App
> 프로그래머스의 과제테스트로 음악 서비스인 FLO App을 클론합니다.<br>
https://school.programmers.co.kr/skill_check_assignments/2

https://user-images.githubusercontent.com/76645463/204234992-7e65e83b-e556-4f89-94fb-a57d1f347545.mov

## 1. 화면구성
![Simulator Screenshot - iPhone 15 Pro - 2024-07-01 at 22 47 20](https://github.com/SangJLee1103/FLO-RX/assets/76645463/23195f3a-8b67-48fb-ad63-e2e6d8fb0504)
![Simulator Screenshot - iPhon![Simulator Screenshot - iPhone 15 Pro - 2024-07-01 at 22 47 44](https://github.com/SangJLee1103/FLO-RX/assets/76645463/14f3b925-65f7-4523-bce5-c4a1a5a91d13)
e 15 Pro - 2024-07-01 at 22 47 30](https://github.com/SangJLee1103/FLO-RX/assets/76645463/80ecc955-3f9b-49dd-9682-46fcc5e7a28b)

-> 앱 실행 영상
https://github.com/SangJLee1103/FLO-RX/assets/76645463/39017bde-a872-4da3-98a7-b7c4e1fc8f48



- 음악 재생 화면
  - 재생 중인 음악 정보(제목, 가수, 앨범 커버 이미지, 앨범명)
  - 현재 재생 중인 부분의 가사 하이라이팅
  - Seekbar
  - Play/Stop 버튼


- 전체 가사 보기 화면
  - 특정 가사로 이동할 수 있는 토글 버튼
  - 전체 가사 화면 닫기 버튼
  - Seekbar
  - Play/Stop 버튼

## 2. 프레임워크
- UIKit
- SnapKit
- Then
- Alamofire
- RxSwift
- RxCocoa
- RxGesture
- RxAVFoundation
- SDWebImage


## 3. 프로젝트 구조

```
├── Resources
│    └── Assets
└── Sources
     ├── Delegates
     │     ├── AppDelegate
     │     └── SceneDelegate
     ├── Extensions
     │     └── UIColor+Extension
     ├── Models
     │     └── Music
     ├── Repositories
     │     ├── Music
     │     │    ├── MusicRouter
     │     │    ├── MusicRepository
     │     │    └── MusicRepositoryImpl             
     ├── ViewModels
     │     └── MusicViewModel
     ├── Views
     │     └── LyricsTableViewCell
     ├── ViewControllers
     │     ├── MusicPlayViewController
     │     └── LyricsViewController
     └── LaunchScreen.storyboard
```
