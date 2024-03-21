//
//  MusicRouter.swift
//  FLO-RX
//
//  Created by 이상준 on 3/16/24.
//

import Alamofire

enum MusicRouter: URLRequestConvertible {
    
    case fetchMusic
    
    var path: String {
        switch self {
        case .fetchMusic:
            return "2020-flo/song.json"
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .fetchMusic:
            return .get
        }
    }
    
    func asURLRequest() throws -> URLRequest {
        let url = try URL(string: "https://grepp-programmers-challenges.s3.ap-northeast-2.amazonaws.com/"
            .asURL()
            .appendingPathComponent(path)
            .absoluteString
            .removingPercentEncoding!)
        
        var request = URLRequest(url: url!)
        request.httpMethod = method.rawValue
        return request
    }
}
