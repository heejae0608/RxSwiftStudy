//
//  ViewController.swift
//  RxSwiftStudy
//
//  Created by 히재 on 2023/03/09.
//

import UIKit
import RxSwift
import RxCocoa

class ViewController: UIViewController {
  
  private let viewModel = ViewModel()
  private let count = BehaviorRelay<Int>(value: 0)

  @IBOutlet weak var rxTestButton: UIButton!
  var disposedBag = DisposeBag()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    rxTestButton.rx.tap
      .scan(0) { (lastCount, newValue) in
        return lastCount + 1
      }
      .bind(to: viewModel.input.trigger)
      .disposed(by: disposedBag)
    
    bind()
  }
  
  private func bind() {
    viewModel.output.state.bind(onNext: {
      switch $0 {
      case .loading:
        print("loading")
      case .done:
        print("done")
      case .error(let error):
        print(error)
      }
    }).disposed(by: disposedBag)
    
    viewModel.output.posts.bind(onNext: {
      print($0.map { $0.postId })
    }).disposed(by: disposedBag)
    
  }
}

