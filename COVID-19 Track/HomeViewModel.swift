//
//  HomeViewModel.swift
//  COVID-19 Track
//
//  Created by George Tsifrikas on 8/3/20.
//  Copyright © 2020 George Tsifrikas. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa

class HomeViewModel {
    
    @Injected private var tracker: Tracker
    
    lazy var switchValue: Driver<Bool> = {
        return _switchValue.asDriver(onErrorJustReturn: false)
    }()
    
    private var _switchValue: Driver<Bool>!
    
    lazy var activityIsSpinning: Driver<Bool> = {
        return _activityIsSpinning.asDriver(onErrorJustReturn: false)
    }()
    private var _activityIsSpinning = PublishRelay<Bool>()
    
    lazy var readyLabelValue: Driver<String> = {
        _readyLabelValue.asDriver(onErrorJustReturn: "Something went really wrong!")
    }()
    private var _readyLabelValue = PublishRelay<String>()
    
    var debug: Driver<String>!
    
    private let disposeBag = DisposeBag()
    
    private enum Action {
        case switchValue(newValue: Bool)
        case newInteraction(interaction: Interaction)
    }
    
    func configure(switchValue: Observable<Bool>) {
        tracker.start().subscribe().disposed(by: disposeBag)
        
        let interactions = tracker.interactions.map(Action.newInteraction)
        let switchPressed = switchValue.map(Action.switchValue)
        
        let actions = Observable.merge([interactions, switchPressed])
        
        
    }
}
