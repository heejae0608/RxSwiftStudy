//
//  ViewModel.swift
//  RxSwiftStudy
//
//  Created by 히재 on 2023/03/09.
//

import Foundation
import RxSwift
import RxRelay

enum State {
  case loading
  case done
  case error(String)
}

protocol ViewModelType {
  associatedtype Input
  associatedtype Output
  
  var disposeBag: DisposeBag { get set }
}

final class ViewModel: ViewModelType {
  struct Input {
    let trigger = BehaviorRelay<Int>(value: 0)
  }
  
  struct Output {
    let state = BehaviorRelay<State>(value: .done)
    let posts = BehaviorRelay<[Post]>(value: [])
  }
  
  var input: Input
  var output: Output
  
  let apiService = NetworkService.shared
  var disposeBag = DisposeBag()
  
  init(
    input: Input = Input(),
    output: Output = Output(),
    disposeBag: DisposeBag = DisposeBag()) {
      self.input = input
      self.output = output
      self.disposeBag = disposeBag
      transform()
    }
  
  private func transform() {
    input.trigger.bind(
      onNext: { [weak self] id in
        self?.fetchPost(id: id)
      }
    )
    .disposed(by: disposeBag)
  }
  
  private func fetchPost(id: Int) {
    self.output.state.accept(.loading)
    self.apiService.fetchPost(with: id)
      .subscribe { response in
        switch response {
        case .next(let data):
          self.output.posts.accept(data)
        case .error(let error):
          self.output.state.accept(.error(error.localizedDescription))
        case .completed:
          self.output.state.accept(.done)
        }
      }
      .disposed(by: disposeBag)
  }
}
