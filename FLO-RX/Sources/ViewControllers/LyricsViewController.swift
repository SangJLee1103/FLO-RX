//
//  LyricsViewController.swift
//  FLO-RX
//
//  Created by 이상준 on 3/21/24.
//

import UIKit
import SnapKit
import Then
import RxSwift
import RxCocoa

final class LyricsViewController: UIViewController {
    
    private let viewModel: MusicViewModel
    
    private lazy var tableView = UITableView().then {
//        $0.dataSource = self
//        $0.delegate = self
        $0.backgroundColor = .white
        $0.rowHeight = 30
        $0.separatorStyle = .none
        $0.register(LyricsTableViewCell.self, forCellReuseIdentifier: LyricsTableViewCell.identifier)
    }
    
    private let topView = UIView().then {
        $0.backgroundColor = .white
    }
    
    private let titleLabel = UILabel().then {
        $0.font = .boldSystemFont(ofSize: 17)
        $0.numberOfLines = 1
    }
    
    private let singerLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 12)
    }
    
    private let closeButton = UIButton().then {
        $0.setImage(UIImage(systemName: "xmark"), for: .normal)
        $0.tintColor = .black
    }
    
    private let progressSlider = UISlider().then {
        $0.setThumbImage(UIImage(), for: .normal)
        $0.minimumTrackTintColor = .mainTheme
    }
    
    private let playButton = UIButton().then {
        $0.tintColor = .black
        $0.setImage(UIImage(systemName: "pause.fill"), for: .normal)
    }
    
    private let toggleButton = UIButton().then {
        let imageConfig = UIImage.SymbolConfiguration(pointSize: 25)
        $0.setImage(UIImage(systemName: "scope", withConfiguration: imageConfig), for: .normal)
        $0.tintColor = .black
    }
    
    init(viewModel: MusicViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        bind()
    }
    
    // MARK: - About UI
    private func configureUI() {
        view.backgroundColor = .white
        
        [topView, tableView, toggleButton,
         progressSlider, playButton].forEach {
            view.addSubview($0)
        }
        
        let safeArea = view.safeAreaLayoutGuide
        
        topView.snp.makeConstraints {
            $0.top.equalTo(safeArea)
            $0.leading.trailing.equalTo(safeArea)
            $0.height.equalTo(60)
        }
        
        topView.addSubview(closeButton)
        closeButton.snp.makeConstraints {
            $0.top.equalToSuperview().offset(10)
            $0.trailing.equalToSuperview().inset(20)
            $0.width.height.equalTo(24)
        }
        
        topView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(10)
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.equalTo(closeButton.snp.leading).offset(-20)
        }
        
        topView.addSubview(singerLabel)
        singerLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(5)
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.equalTo(closeButton.snp.leading).offset(20)
        }

        tableView.snp.makeConstraints {
            $0.top.equalTo(topView.snp.bottom)
            $0.leading.equalTo(safeArea)
            $0.trailing.equalTo(safeArea).inset(50)
            $0.bottom.equalTo(safeArea).inset(60)
        }
        
        toggleButton.snp.makeConstraints {
            $0.top.equalTo(topView.snp.bottom).offset(40)
            $0.trailing.equalTo(safeArea).inset(15)
            $0.width.height.equalTo(30)
        }
        
        progressSlider.snp.makeConstraints {
            $0.top.equalTo(tableView.snp.bottom)
            $0.leading.trailing.equalTo(safeArea)
        }
        
        playButton.snp.makeConstraints {
            $0.centerX.equalTo(safeArea)
            $0.top.equalTo(progressSlider.snp.bottom).offset(30)
        }
    }
    
    // MARK: - About Bind
    private func bind() {
        closeButton.rx.tap
            .asDriver()
            .drive(onNext: { [weak self] _ in
                self?.dismiss(animated: true)
            })
            .disposed(by: rx.disposeBag)
        
        viewModel.title
            .bind(to: titleLabel.rx.text)
            .disposed(by: rx.disposeBag)
        
        viewModel.singer
            .bind(to: singerLabel.rx.text)
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

// MARK: - About TableView Delegate, DataSource
//extension LyricsViewController: UITableViewDelegate, UITableViewDataSource {
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//
//    }
//    
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        
//    }
//}
