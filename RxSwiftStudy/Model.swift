//
//  Model.swift
//  RxSwiftStudy
//
//  Created by 히재 on 2023/03/09.
//

import Foundation

struct Post: Codable {
  let postId: Int
  let id: Int
  let name: String
  let email: String
  let body: String
}
