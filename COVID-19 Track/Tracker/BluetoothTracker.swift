//
//  BluetoothTracker.swift
//  COVID-19 Track
//
//  Created by George Tsifrikas on 8/3/20.
//  Copyright © 2020 George Tsifrikas. All rights reserved.
//

import Foundation
import RxSwift
import RxBluetoothKit
import CoreBluetooth
import RxRelay


class BluetoothTracker: Tracker {
    
    private let centralManager = CentralManager(queue: .main)
    
    lazy var interactions: Observable<Interaction> = { _interactions.asObservable() }()
    var _interactions = PublishSubject<Interaction>()
    private let scheduler: ConcurrentDispatchQueueScheduler
    private var disposeBag = DisposeBag()

    
    init() {
        let timerQueue = DispatchQueue(label: "com.gtsifrikas.rxbluetoothkit.timer")
        scheduler = ConcurrentDispatchQueueScheduler(queue: timerQueue)
    }
    
    func start() -> Observable<Void> {
        
        let bluetoothReady: Observable<Void> = centralManager.observeState()
        .startWith(centralManager.state)
        .filter {
            $0 == .poweredOn
        }
        .subscribeOn(MainScheduler.instance)
        .share(replay: 1, scope: .forever)
        .map{ _ in }
        
        bluetoothReady
            .flatMap { [weak self] _ -> Observable<ScannedPeripheral> in
                guard let `self` = self else { return .empty() }
                return self.centralManager.scanForPeripherals(withServices: [BluetoothBeacon.serviceUUID])
            }
            .flatMap({ (peripheral) -> Observable<Interaction> in
                
                let id = peripheral.peripheral.identifier.uuidString + (peripheral.peripheral.name ?? "")
                
                return .just(Interaction(
                    other: id,
                    strength: peripheral.rssi.floatValue,
                    dateTime: Date()))
            })
            .catchError({ (error) -> Observable<Interaction> in
                if let error = error as? RxError, error.debugDescription == "Sequence timeout." {
                    return .empty()
                }
                throw error
            })
            .subscribe(_interactions).disposed(by: disposeBag)
        
        return bluetoothReady
    }
    
    func stop() -> Observable<Void> {
        disposeBag = DisposeBag()
        return .just(())
    }
    
    
}
