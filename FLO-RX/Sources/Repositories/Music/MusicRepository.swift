//
//  MusicRepository.swift
//  FLO-RX
//
//  Created by 이상준 on 3/16/24.
//

import Alamofire
import RxSwift

protocol MusicRepository {
    func fetchMusic() -> Observable<Music>
}
