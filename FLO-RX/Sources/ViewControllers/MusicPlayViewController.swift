//
//  ViewController.swift
//  FLO-RX
//
//  Created by 이상준 on 3/16/24.
//

import UIKit
import RxSwift
import RxCocoa
import RxGesture
import SnapKit
import Then

final class MusicPlayViewController: UIViewController {
    
    private let viewModel: MusicViewModel
    
    private lazy var indicator = UIActivityIndicatorView().then {
        $0.center = self.splitViewController?.view.center ?? CGPoint()
        $0.style = UIActivityIndicatorView.Style.medium
    }
    
    private let titleLabel = UILabel().then {
        $0.font = .boldSystemFont(ofSize: 17)
        $0.textColor = .black
    }
    
    private let albumLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 13)
        $0.textColor = .darkGray
    }
    
    private let singerLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 15)
        $0.textColor = .black
    }
    
    private let imgView = UIImageView().then {
        $0.contentMode = .scaleAspectFill
        $0.clipsToBounds = true
        $0.layer.cornerRadius = 8
    }
    
    private let lyricsLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 14)
        $0.textColor = .gray
        $0.numberOfLines = 2
    }
    
    private let progressSlider = UISlider().then {
        $0.setThumbImage(UIImage(), for: .normal)
        $0.minimumTrackTintColor = .mainTheme
    }
    
    private let playButton = UIButton().then {
        $0.tintColor = .black
        $0.setImage(UIImage(systemName: "pause.fill"), for: .normal)
    }
    
    private let currentTimeLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 12)
        $0.textColor = .mainTheme
        $0.text = "00:00"
    }
    
    private let durationLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 12)
        $0.textColor = .gray
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        bind()
    }
    
    init(viewModel: MusicViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - About UI
    private func configureUI() {
        view.backgroundColor = .white
        
        [titleLabel, albumLabel, singerLabel,
         imgView, lyricsLabel, progressSlider,
         playButton, currentTimeLabel, durationLabel].forEach {
            view.addSubview($0)
        }
        
        let safeArea = view.safeAreaLayoutGuide
        
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(safeArea).offset(70)
            $0.centerX.equalTo(safeArea)
        }
        
        albumLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(5)
            $0.centerX.equalTo(safeArea)
        }
        
        singerLabel.snp.makeConstraints {
            $0.top.equalTo(albumLabel.snp.bottom).offset(5)
            $0.centerX.equalTo(safeArea)
        }
        
        imgView.snp.makeConstraints {
            $0.top.equalTo(singerLabel.snp.bottom).offset(20)
            $0.leading.trailing.equalTo(safeArea).inset(70)
            $0.height.equalTo(imgView.snp.width)
        }
        
        lyricsLabel.snp.makeConstraints {
            $0.top.equalTo(imgView.snp.bottom).offset(10)
            $0.centerX.equalTo(safeArea)
        }
        
        lyricsLabel.rx.tapGesture()
            .when(.recognized)
            .asDriver { _ in .never() }
            .drive(onNext: { [weak self] _ in
                guard let self = self else { return }
                let lyricsVC = LyricsViewController(viewModel: viewModel)
                lyricsVC.modalPresentationStyle = .fullScreen
                present(lyricsVC, animated: true)
            })
            .disposed(by: rx.disposeBag)
        
        progressSlider.snp.makeConstraints {
            $0.top.equalTo(lyricsLabel.snp.bottom).offset(50)
            $0.leading.trailing.equalTo(safeArea).inset(30)
        }
        
        currentTimeLabel.snp.makeConstraints {
            $0.top.equalTo(progressSlider.snp.bottom).offset(5)
            $0.leading.equalTo(safeArea).inset(30)
        }
        
        durationLabel.snp.makeConstraints {
            $0.top.equalTo(progressSlider.snp.bottom).offset(5)
            $0.trailing.equalTo(safeArea).inset(30)
        }
        
        playButton.snp.makeConstraints {
            $0.top.equalTo(progressSlider.snp.bottom).offset(20)
            $0.centerX.equalTo(safeArea)
            $0.width.height.equalTo(30)
        }
    }
    
    // MARK: - About Bind
    private func bind() {
        viewModel.title
            .bind(to: titleLabel.rx.text)
            .disposed(by: rx.disposeBag)
        
        viewModel.singer
            .bind(to: singerLabel.rx.text)
            .disposed(by: rx.disposeBag)
        
        viewModel.album
            .bind(to: albumLabel.rx.text)
            .disposed(by: rx.disposeBag)
        
        viewModel.image
            .bind(to: imgView.rx.imageURL)
            .disposed(by: rx.disposeBag)
        
        viewModel.currentTime
            .bind(to: currentTimeLabel.rx.text)
            .disposed(by: rx.disposeBag)
        
        viewModel.duration
            .bind(to: durationLabel.rx.text)
            .disposed(by: rx.disposeBag)
        
        viewModel.currentLyricsAttributedString
            .bind(to: lyricsLabel.rx.attributedText)
            .disposed(by: rx.disposeBag)
        
        // MARK: - About Play Button
        playButton.rx.tap
            .bind { [weak self] _ in
                self?.viewModel.togglePlayPause()
            }
            .disposed(by: rx.disposeBag)
        
        viewModel.isPlay
            .map { $0 ? UIImage(systemName: "pause.fill") : UIImage(systemName: "play.fill") }
            .bind(to: playButton.rx.image(for: .normal))
            .disposed(by: rx.disposeBag)
        
        // MARK: - About UISlider
        viewModel.durationTimeObservable
            .bind(to: progressSlider.rx.maximumValue)
            .disposed(by: rx.disposeBag)
        
        
        viewModel.currentTimeToFloat
            .bind(to: progressSlider.rx.value)
            .disposed(by: rx.disposeBag)
        
        progressSlider.rx.value.changed
            .subscribe(onNext: { [weak self] newValue in
                self?.viewModel.seek(to: newValue)
            }).disposed(by: rx.disposeBag)
    }
}
