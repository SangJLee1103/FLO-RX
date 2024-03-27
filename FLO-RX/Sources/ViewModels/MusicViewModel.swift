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

final class MusicViewModel: HasDisposeBag {
    
    private let player = AVPlayer()
    private let music = BehaviorRelay<Music?>(value: nil)
    
    var musicObservable: Observable<Music?> { return music.asObservable() }
    var title: Observable<String> { musicObservable.map { $0?.title ?? "" } }
    var singer: Observable<String> { musicObservable.map { $0?.singer ?? "" } }
    var album: Observable<String> { musicObservable.map { $0?.album ?? "" } }
    var image: Observable<String> { musicObservable.map { $0?.imageUrl ?? "" } }
    var isPlay = BehaviorRelay(value: false)
    var duration: Observable<String> { musicObservable.map { self.formattedTime(time: Double($0?.duration ?? 0)) } }
    var durationTimeObservable: Observable<Float> { musicObservable.map { Float($0?.duration ?? 0) } }
    
    var isToggle = BehaviorRelay(value: false)
    
    // About Lyrics
    var lyricsDict = [Int: String]()
    private var lyricsArray = [String]()
    private let lyricsArrayRelay = BehaviorRelay<[String]>(value: [])
    var lyricsArrayObservable: Observable<[String]> { lyricsArrayRelay.asObservable() }
    
    var currentTime: Observable<String> {
        return Observable.create { observer in
            let interval = CMTime(seconds: 1, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
            let mainQueue = DispatchQueue.main
            _ = self.player.addPeriodicTimeObserver(forInterval: interval, queue: mainQueue) { [weak self] time in
                let currentTime = self?.player.currentTime().seconds ?? 0
                let timeString = self?.formattedTime(time: currentTime) ?? "00:00"
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
                self?.classifyAndSetLyrics(music.lyrics)
            }, onError: { error in
                print(error.localizedDescription)
            }).disposed(by: disposeBag)
    }
    
    // 분:초 치환
    private func formattedTime(time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%02d:%02d", minutes, seconds)
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
    
    private func classifyAndSetLyrics(_ lyrics: String) {
        lyrics.split(separator: "\n").forEach { line in
            let components = line.split(separator: "]", maxSplits: 1, omittingEmptySubsequences: false)
            guard components.count > 1,
                  let timeComponent = components.first,
                  let lyricText = components.last else { return }
            
            let timeString = timeComponent.trimmingCharacters(in: CharacterSet(charactersIn: "[]"))
            if let time = timeStringToSeconds(timeString) {
                lyricsDict[Int(time)] = String(lyricText).trimmingCharacters(in: .whitespacesAndNewlines)
            }
        }
        lyricsArray = lyricsDict.sorted { $0.key < $1.key }.map { $0.value }
        lyricsArrayRelay.accept(lyricsArray)
    }
    
    private func styledCurrentLyrics(_ currentTime: Float, lyrics: String) -> NSAttributedString {
        let attributedString = NSMutableAttributedString()
        let index = getCurrentLyricsIndex(for: currentTime)
        
        let firstLyricTime = lyricsDict.keys.sorted().first ?? 0
        
        let currentLyric = index >= 0 ? lyricsArray[index] : ""
        
        // 간주 중일 때는 하이라이팅을 적용 X
        if currentTime < Float(firstLyricTime) {
            attributedString.append(NSAttributedString(string: currentLyric + "\n", attributes: [.foregroundColor: UIColor.lightGray]))
        } else {
            // 간주 중이 아닐 때는 현재 가사에 하이라이팅 적용 O
            attributedString.append(NSAttributedString(string: currentLyric + "\n", attributes: [.foregroundColor: UIColor.black]))
        }
        
        
        if index + 1 < lyricsArray.count {
            let nextLyric = lyricsArray[index + 1]
            attributedString.append(NSAttributedString(string: nextLyric, attributes: [.foregroundColor: UIColor.lightGray]))
        }
        return attributedString
    }
    
    func getCurrentLyricsIndex(for currentTime: Float) -> Int {
        let sortedTimes = lyricsDict.keys.sorted()
        var low = 0
        var high = sortedTimes.count - 1
        
        while low <= high {
            let mid = low + (high - low) / 2
            let time = Float(sortedTimes[mid])
            
            if time == currentTime {
                return mid
            } else if time < currentTime {
                low = mid + 1
            } else {
                high = mid - 1
            }
        }
        
        // 찾고자 하는 시간이 모든 가사의 시간보다 클 때, 마지막 가사의 인덱스를 반환
        if low >= sortedTimes.count {
            return sortedTimes.count - 1
        }
        
        // 현재 시간보다 직전의 가사 인덱스를 반환
        return max(0, low - 1)
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
