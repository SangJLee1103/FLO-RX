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
        $0.font = .systemFont(ofSize: 13)
        $0.textColor = .lightGray
        $0.text = ""
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        addSubview(lyricsLabel)
        lyricsLabel.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.trailing.equalToSuperview().inset(20)
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
    
    private func setCurrentLyricsIndex() {
        lyricsLabel.textColor = .black
        lyricsLabel.font = UIFont.boldSystemFont(ofSize: 13)
    }
    
    private func resetCurrentLyricsUI() {
        lyricsLabel.textColor = .lightGray
        lyricsLabel.font = UIFont.systemFont(ofSize: 13)
    }
}
