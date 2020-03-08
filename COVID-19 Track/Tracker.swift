//
//  Tracker.swift
//  COVID-19 Track
//
//  Created by George Tsifrikas on 8/3/20.
//  Copyright © 2020 George Tsifrikas. All rights reserved.
//

import Foundation
import RxSwift

protocol Tracker {
    func start() -> Observable<Void>
}
