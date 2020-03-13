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
    
    public static var centralManager = CentralManager(
        queue: .global(qos: .background),
        options: [CBCentralManagerOptionRestoreIdentifierKey: NSString("Coronavirus_Scanner")],
        onWillRestoreCentralManagerState: { (restoreState) in
            print("RESTORED")
            print(restoreState.centralManager)
    })
    
    lazy var interactions: Observable<Interaction> = { _interactions.asObservable() }()
    var _interactions = PublishSubject<Interaction>()
    private let scheduler: ConcurrentDispatchQueueScheduler
    private var disposeBag = DisposeBag()

    
    init() {
        let timerQueue = DispatchQueue(label: "com.gtsifrikas.rxbluetoothkit.timer")
        scheduler = ConcurrentDispatchQueueScheduler(queue: timerQueue)
    }
    
    func start() -> Observable<Void> {
        
        func listenForService() {
            let bluetoothReady: Observable<Void> = BluetoothTracker.centralManager.observeState()
            .startWith(BluetoothTracker.centralManager.state)
            .filter {
                $0 == .poweredOn
            }
            .subscribeOn(MainScheduler.instance)
            .share(replay: 1, scope: .forever)
            .map{ _ in }
            
            bluetoothReady
                .flatMap { _ -> Observable<ScannedPeripheral> in
                    return BluetoothTracker.centralManager.scanForPeripherals(withServices: [BluetoothBeacon.serviceUUID])
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
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            listenForService()
        }
        
        
        
        return .just(())
    }
    
    func stop() -> Observable<Void> {
        disposeBag = DisposeBag()
        return .just(())
    }
    
    
}
