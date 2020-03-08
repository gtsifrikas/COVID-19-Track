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
typealias RSSIStrengt = Float

struct Interaction {
    
    let other: UserID
    let strength: RSSIStrengt
    let dateTime: Date
    
}

protocol Tracker {
    
    var interactions: Observable<Interaction> { get }
    func start() -> Observable<Void>
    func stop() -> Observable<Void>
    
}
