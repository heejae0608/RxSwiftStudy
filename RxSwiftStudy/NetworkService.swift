//
//  NetworkService.swift
//  RxSwiftStudy
//
//  Created by 히재 on 2023/03/09.
//

import Foundation
import Alamofire
import RxSwift

final class NetworkService {
  
  enum HTTPHeader: String {
    case accept = "Accept"
    case contentType = "Content-Type"
  }
  
  static let baseHeaders: HTTPHeaders = [
    HTTPHeader.accept.rawValue: "application/json",
    HTTPHeader.contentType.rawValue: "application/json",
  ]
  
  static let shared = NetworkService()
  
  func fetchPost(with id: Int) -> Observable<[Post]> {
    let baseUrl = "https://jsonplaceholder.typicode.com/comments?postId="
    let pageId = String(id)
    let reqUrl = baseUrl + pageId
    return Observable.create { observer -> Disposable in
      AF.request(
        reqUrl,
        method: .get,
        parameters: nil,
        encoding: URLEncoding.default,
        headers: NetworkService.baseHeaders)
      .responseDecodable(of: [Post].self) { response in
        switch response.result {
        case .success(let data):
          observer.onNext(data)
        case .failure(let error):
          observer.onError(error)
        }
        observer.onCompleted()
      }
      return Disposables.create()
    }
  }
}
