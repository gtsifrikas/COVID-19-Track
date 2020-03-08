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
import RxRelay



class HomeViewModel {
    
    @Injected private var tracker: Tracker
    
    lazy var switchValue: Driver<Bool> = {
        return _switchValue.asDriver(onErrorJustReturn: false)
    }()
    
    private var _switchValue = BehaviorRelay<Bool>(value: false)
    
    lazy var activityIsSpinning: Driver<Bool> = {
        return _activityIsSpinning.asDriver(onErrorJustReturn: false)
    }()
    private var _activityIsSpinning = BehaviorRelay<Bool>(value: false)
    
    lazy var readyLabelValue: Driver<String> = {
        _readyLabelValue.asDriver(onErrorJustReturn: "Something went really wrong!")
    }()
    private var _readyLabelValue = BehaviorRelay<String>(value: "Not ready yet.")
    
    var debug: Driver<String>!
    
    private let disposeBag = DisposeBag()
    
    private enum Action {
        case switchValue(newValue: Bool)
        case newInteraction(interaction: Interaction)
    }
    
    private struct State {
        var interactionsSoFar: [Interaction]
        let debugLabel: String
        
        static var initial = State(interactionsSoFar: [], debugLabel: "")
    }
    
    func configure(switchValue: Observable<Bool>) {
        _switchValue.accept(false)
        _activityIsSpinning.accept(false)
        _readyLabelValue.accept("Idle")
        
        let switchValue = switchValue.skip(1)
        
        switchValue.flatMap {[weak self] (value) -> Observable<Void> in
            if value {
                return self!.tracker.start()
            } else {
                return self!.tracker.stop()
            }
        }
            .subscribe(
                onNext: {[weak self] _ in
                    self?._readyLabelValue.accept("Started!")
                    self?._switchValue.accept(true)
                    self?._activityIsSpinning.accept(true)
                    self?._activityIsSpinning.accept(false)
                },
                onError: {[weak self] (error) in
                    self?._readyLabelValue.accept("Failed")
                    self?._switchValue.accept(false)
                    self?._activityIsSpinning.accept(false)
            })
            .disposed(by: disposeBag)
        
        
        let interactions = tracker.interactions.map(Action.newInteraction)
        
        let actions = Observable.merge([interactions])
        
        let behavior = actions.scan(State.initial) { (currentState, newAction) -> State in
            var newState = currentState
            
            switch newAction {
                
            case .switchValue(newValue: _):
                break
            case .newInteraction(interaction: let interaction):
                newState.interactionsSoFar += [interaction]
            }
            
            return newState
        }.share(replay: 1, scope: .forever)
        
        debug = behavior
            .map({ $0.interactionsSoFar })
            .map({ (interactions) -> String in
                return "#\(interactions.count) interactions so far \n \(interactions.map{ $0.other }.reduce("", { "\($0)\n\($1)" }))"
            })
            .debug()
            .asDriver(onErrorJustReturn: "Whoops!")
        
        
    }
}
