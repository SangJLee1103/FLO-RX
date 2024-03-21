//
//  MusicRepositoryImpl.swift
//  FLO-RX
//
//  Created by 이상준 on 3/16/24.
//

import Alamofire
import RxSwift

struct MusicRepositoryImpl: MusicRepository {
    
    static let shared = MusicRepositoryImpl()
    
    func fetchMusic() -> Observable<Music> {
        return Observable.create { observer in
            AF.request(MusicRouter.fetchMusic).responseDecodable(of: Music.self) { response in
                switch response.result {
                case .success(let data):
                    observer.onNext(data)
                    observer.onCompleted()
                case .failure(let error):
                    observer.onError(error)
                }
            }
            return Disposables.create()
        }
    }
}
