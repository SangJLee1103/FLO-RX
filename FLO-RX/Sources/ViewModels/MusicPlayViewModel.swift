//
//  MusicPlayViewModel.swift
//  FLO-RX
//
//  Created by 이상준 on 3/16/24.
//

import AVFoundation
import RxSwift
import RxCocoa
import RxAVFoundation
import NSObject_Rx
import SDWebImage

final class MusicPlayViewModel: HasDisposeBag {
    
    var player = AVPlayer()
    var isPlay = BehaviorRelay(value: false)
    
    private let music = BehaviorRelay<Music?>(value: nil)
    
    var musicObservable: Observable<Music?> {
        return music.asObservable()
    }
    
    var title: Observable<String> { musicObservable.map { $0?.title ?? "" } }
    var singer: Observable<String> { musicObservable.map { $0?.singer ?? "" } }
    var album: Observable<String> { musicObservable.map { $0?.album ?? "" } }
    var image: Observable<String> { musicObservable.map { $0?.imageUrl ?? "" } }
    
    var duration: Observable<String> { musicObservable.map { self.formatTime(time: Double($0?.duration ?? 0)) } }
    var durationTimeObservable: Observable<Float> { musicObservable.map { Float($0?.duration ?? 0) } }
    
    
    var currentTime: Observable<String> {
        return Observable.create { observer in
            let interval = CMTime(seconds: 1, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
            let mainQueue = DispatchQueue.main
            _ = self.player.addPeriodicTimeObserver(forInterval: interval, queue: mainQueue) { [weak self] time in
                let currentTime = self?.player.currentTime().seconds ?? 0
                let timeString = self?.formatTime(time: currentTime) ?? "00:00"
                observer.onNext(timeString)
            }
            return Disposables.create()
        }
    }
    
    // 현재 재생 시간을 Float로 반환하는 Observable
    var currentTimeToFloat: Observable<Float> {
        return Observable.create { observer in
            let interval = CMTime(seconds: 1, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
            let mainQueue = DispatchQueue.main
            _ = self.player.addPeriodicTimeObserver(forInterval: interval, queue: mainQueue) { [weak self] time in
                let currentTime = Float(self?.player.currentTime().seconds ?? 0.0)
                observer.onNext(currentTime)
            }
            return Disposables.create()
        }
    }
    
    var currentLyricsAttributedString: Observable<NSAttributedString> {
        return currentTimeToFloat
            .flatMapLatest { [weak self] currentTime -> Observable<NSAttributedString> in
                guard let self = self, let lyrics = self.music.value?.lyrics else {
                    return Observable.just(NSAttributedString(string: ""))
                }
                let styledLyrics = self.styledCurrentLyrics(currentTime, lyrics: lyrics)
                return Observable.just(styledLyrics)
            }
    }
    
    init() {
        fetchMusic()
    }
    
    private func fetchMusic() {
        MusicRepositoryImpl.shared.fetchMusic()
            .subscribe(onNext: { [weak self] music in
                self?.music.accept(music)
                self?.prepareAndPlayMusic(url: music.fileUrl)
            }, onError: { error in
                print(error.localizedDescription)
            }).disposed(by: disposeBag)
    }
    
    private func convertMusicData(url: String) {
        if let url = URL(string: url) {
            let playerItem = AVPlayerItem(url: url)
            player.replaceCurrentItem(with: playerItem)
        }
    }
    
    private func formatTime(time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    // 분:초 치환
    private func getTime(time: Double) -> Observable<String> {
        return Observable.create { observer in
            let minute = Int(time / 60)
            let second = Int(time.truncatingRemainder(dividingBy: 60))
            let timeString = String(format: "%02ld:%02ld", minute, second)
            
            observer.onNext(timeString)
            observer.onCompleted()
            
            return Disposables.create()
        }
    }
    
    // 음원 URL을 통해 음원 데이터로 converting
    private func prepareAndPlayMusic(url: String) {
        guard let url = URL(string: url) else { return }
        
        let playerItem = AVPlayerItem(url: url)
        player.replaceCurrentItem(with: playerItem)
        
        playerItem.rx.status
            .filter { $0 == .readyToPlay }
            .take(1)
            .subscribe(onNext: { [weak self] _ in
                self?.togglePlayPause()
            })
            .disposed(by: disposeBag)
    }
    
    // 원하는 지점을 찾고 이동하는 함수
    public func seek(to seconds: Float) {
        let seekTime = CMTimeMake(value: Int64(seconds), timescale: 1)
        player.seek(to: seekTime)
    }
    
    public func togglePlayPause() {
        if isPlay.value {
            player.pause()
        } else {
            player.play()
        }
        isPlay.accept(!isPlay.value)
    }
    
    // 가사 파싱 및 NSAttributed
    private func styledCurrentLyrics(_ currentTime: Float, lyrics: String) -> NSAttributedString {
        let lyricLines = lyrics.split(separator: "\n").map { String($0) }
        let currentAndNextLyric = NSMutableAttributedString()
        var currentIndex: Int?
        
        // 현재 재생 시간에 맞는 가사 인덱스 찾기
        for (index, line) in lyricLines.enumerated() {
            guard let timePart = line.split(separator: "]").first?.trimmingCharacters(in: CharacterSet(charactersIn: "[]")),
                  let time = timeStringToSeconds(timePart),
                  currentTime >= time else { continue }
            
            currentIndex = index
        }
        
        // 현재 및 다음 가사 선택 및 스타일링
        if let currentIndex = currentIndex, currentIndex < lyricLines.count {
            let currentLine = lyricLines[currentIndex].split(separator: "]").map { String($0) }.last ?? ""
            let nextLine = currentIndex + 1 < lyricLines.count ? lyricLines[currentIndex + 1].split(separator: "]").map { String($0) }.last ?? "" : ""
            
            let currentAttributedLine = NSAttributedString(string: currentLine + "\n", attributes: [.foregroundColor: UIColor.black])
            currentAndNextLyric.append(currentAttributedLine)
            
            if !nextLine.isEmpty {
                let nextAttributedLine = NSAttributedString(string: nextLine, attributes: [.foregroundColor: UIColor.lightGray])
                currentAndNextLyric.append(nextAttributedLine)
            }
        }
        return currentAndNextLyric
    }
    
    private func timeStringToSeconds(_ timeString: String) -> Float? {
        let components = timeString.split(separator: ":")
        guard components.count == 3,
              let minutes = Float(components[0]),
              let seconds = Float(components[1]),
              let milliseconds = Float(components[2]) else { return nil }

        return minutes * 60 + seconds + milliseconds / 1000.0
    }
}

// MARK: - About ImageView Custom Binder
extension Reactive where Base: UIImageView {
    public var imageURL: Binder<String> {
        return Binder(self.base) { imageView, urlString in
            guard let url = URL(string: urlString) else { return }
            imageView.sd_setImage(with: url)
        }
    }
}
