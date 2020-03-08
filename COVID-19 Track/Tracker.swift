//
//  Tracker.swift
//  COVID-19 Track
//
//  Created by George Tsifrikas on 8/3/20.
//  Copyright © 2020 George Tsifrikas. All rights reserved.
//

import Foundation
import RxSwift


typealias UserID = String
typealias RSSIStrength = Float

struct Interaction {
    
    let other: UserID
    let strength: RSSIStrength
    let dateTime: Date
    
}

protocol Tracker {
    
    var interactions: Observable<Interaction> { get }
    func start() -> Observable<Void>
    func stop() -> Observable<Void>
    
}

class FakeTracker: Tracker {
    
    var interactions: Observable<Interaction> {
        return .from([
            Interaction(other: "id_1", strength: -44.0, dateTime: Date(timeIntervalSince1970: 1583694037)),
            Interaction(other: "id_2", strength: -44.0, dateTime: Date(timeIntervalSince1970: 1583694074)),
            Interaction(other: "id_3", strength: -44.0, dateTime: Date(timeIntervalSince1970: 1583694091)),
            Interaction(other: "id_4", strength: -44.0, dateTime: Date(timeIntervalSince1970: 1583694087))
        ])
    }
    
    func start() -> Observable<Void> {
        return Observable.just(())
    }
    
    func stop() -> Observable<Void> {
        return Observable.just(())
    }
    
}
