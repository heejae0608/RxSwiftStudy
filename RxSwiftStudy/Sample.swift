//
//  Sample.swift
//  RxSwiftStudy
//
//  Created by 히재 on 2023/03/09.
//

import Foundation
import RxSwift
import RxRelay

enum SampleError: Error {
  case anError
}


final class Sample {
  func study() {
    
    // 단일요소 (배열 가능)
    example(of: "Just") {
      let observable = Observable.just("Just Test")
      observable.subscribe { str in
        print(str)
      }
    }
    
    // 다중요소
    example(of: "Of") {
      let observable = Observable.of("1","2")
      observable.subscribe { str in
        print(str)
      }
    }
    
    // Array 타입을 하나씩
    example(of: "Of") {
      let observable = Observable.from(["1","2"])
      observable.subscribe { str in
        print(str)
      }
    }
    
    example(of: "Create") {
      let disposeBag = DisposeBag()
      
      let observable = Observable<String>.create({ (observer) -> Disposable in
        
        observer.onNext("1")
        
        observer.onCompleted()
        // 완료가 호출 되서 밑에 실행되지 않음
        observer.onNext("2")
        
        return Disposables.create()
      })
      // 이렇게하면 밑에와는 다르게 onNext 만 호출
      observable.subscribe(onNext: { str in
        print(str)
      })
      
      //      observable.subscribe { str in
      //        print(str)
      //      }
    }
    
    // Completed 만 출력
    example(of: "Empty") {
      let observable = Observable<Void>.empty()
      observable.subscribe(
        onNext: { element in
          print(element)
        },
        onCompleted: {
          print("Completed")
        }
      )
    }
    // 둘 다 출력되지 않음
    example(of: "never") {
      let observable = Observable<Any>.never()
      
      observable
        .subscribe(
          onNext: { (element) in
            print(element)
          },
          onCompleted: {
            print("Completed")
          }
        )
    }
    
    // 인수
    example(of: "Range") {
      let observable = Observable<Int>.range(start: 1, count: 3)
      
      observable
        .subscribe(onNext: { (i) in
          print(i)
        })
    }
    
    // 취소
    example(of: "Dispose") {
      let observable = Observable.of("1", "2", "3")
      let subscription = observable.subscribe({ (event) in
        print(event)
      })
      subscription.dispose()
    }
    
    // Dispose 객체 담기
    example(of: "DisposeBag") {
      let disposeBag = DisposeBag()
      Observable.of("1", "2", "3")
        .subscribe{
          print($0)
        }
        .disposed(by: disposeBag)
      print(disposeBag)
    }
    
    // lazy 변수와 같이 구독하는 순간 생성
    example(of: "deferred") {
      let disposeBag = DisposeBag()
      
      var flip = false
      
      let factory: Observable<Int> = Observable.deferred(){
        
        flip = !flip
        
        if flip {
          return Observable.of(1,2,3)
        } else {
          return Observable.of(4,5,6)
        }
      }
      
      for _ in 0...3 {
        factory.subscribe(onNext: {
          print($0, terminator: "")
        })
        .disposed(by: disposeBag)
        
        print()
      }
    }
    
    // Observable 에 값을 추가해서 emit이 발생하게 해줌
    // 현재 구독 요청한 대상만 호출
    example(of: "PublishSubject") {
      
      let subject = PublishSubject<String>()
      
      // 구독 전이기 때문에 출력되지 않음
      subject.onNext("frist")
      
      let subscriptionOne = subject
        .subscribe(onNext: { (string) in
          print(string)
        })
      
      subject.on(.next("1"))
      subject.onNext("2")
      
      subscriptionOne.dispose()
      
      let subscriptionTwo = subject
        .subscribe({ (event) in
          print("2)", event.element ?? event)
        })
      
      subject.onNext("3")
      
      subject.onNext("4")
      
      subject.onCompleted()
      
      subject.onNext("5")
      
      subscriptionTwo.dispose()
      
      let disposeBag = DisposeBag()
      
      subject
        .subscribe {
          print("3)", $0.element ?? $0)
        }
        .disposed(by: disposeBag)
      
      subject.onNext("?")
    }
    
    // 항상 저장되어있는 최산값을 emit
    example(of: "BehaviorSubject") {
      
      // BehaviorSubject는 초기값이 필수 이므로 초기화값을 삽입
      let subject = BehaviorSubject(value: "Initial value")
      let disposeBag = DisposeBag()
      
      subject.onNext("X")
      
      subject
        .subscribe{
          print("1)", $0)
        }
        .disposed(by: disposeBag)
      
      subject.onError(SampleError.anError)
      
      subject
        .subscribe {
          print("2)", $0)
        }
        .disposed(by: disposeBag)
    }
    
    // 버퍼사이즈에 맞게 emit
    example(of: "ReplaySubject") {
      
      let subject = ReplaySubject<String>.create(bufferSize: 2)
      let disposeBag = DisposeBag()
      
      subject.onNext("1")
      subject.onNext("2")
      subject.onNext("3")
      
      subject
        .subscribe {
          print("1)", $0)
        }
        .disposed(by: disposeBag)
      
      subject
        .subscribe {
          print("2)", $0)
        }
        .disposed(by: disposeBag)
      
      subject.onNext("4")
      
      subject.onError(SampleError.anError)
      
      subject.subscribe {
        print("3)", $0)
      }
      .disposed(by: disposeBag)
    }
    
    // 오직 next 이벤트만 emit, 기능은 PublishSubject
    example(of: "PublishRelay") {
      let relay = PublishRelay<String>()
      
      let disposeBag = DisposeBag()
      
      relay.accept("first")
      
      relay
        .subscribe(onNext: {
          print($0)
        })
        .disposed(by: disposeBag)
      
      relay.accept("1")
    }
  }
  
  public func example(of description: String,
                      action: () -> Void) {
    print("\n--- Example of:", description, "---")
    action()
  }

}

