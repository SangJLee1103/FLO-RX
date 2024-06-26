//
//  LyricsTableViewCell.swift
//  FLO-RX
//
//  Created by 이상준 on 3/22/24.
//

import UIKit
import Then
import SnapKit

final class LyricsTableViewCell: UITableViewCell {
    
    static let identifier = "LyricsTableViewCell"
    
    private let lyricsLabel = UILabel().then {
        $0.textAlignment = .left
        $0.font = .systemFont(ofSize: 16)
        $0.textColor = .lightGray
        $0.text = ""
    }
    
    var isCurrentLyrics: Bool = false {
        didSet {
            if isCurrentLyrics {
                setCurrentLyricsUI()
            } else {
                resetCurrentLyricsUI()
            }
        }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        addSubview(lyricsLabel)
        lyricsLabel.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.equalToSuperview().inset(50)
            $0.bottom.equalToSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        resetCurrentLyricsUI()
    }
    
    public func setLyrics(text: String) {
        lyricsLabel.text = text
    }
    
    public func setCurrentLyricsUI() {
        lyricsLabel.textColor = .black
        lyricsLabel.font = UIFont.boldSystemFont(ofSize: 16)
    }
    
    public func resetCurrentLyricsUI() {
        lyricsLabel.textColor = .lightGray
        lyricsLabel.font = UIFont.systemFont(ofSize: 16)
    }
}
