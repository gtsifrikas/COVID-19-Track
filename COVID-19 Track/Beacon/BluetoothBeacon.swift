//
//  BluetoothBeacon.swift
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

class BluetoothBeacon: Beacon {
    
    public static let serviceUUID = CBUUID(string: "acd58b70-d2c5-4612-91d6-eb4f385c2414")
    
    private var disposeBag = DisposeBag()
    private static var peripheralManager = PeripheralManager(
        queue: .global(qos: .background),
        options: [CBPeripheralManagerOptionRestoreIdentifierKey: NSString("Coronavirus_Advertiser")])
    
    public required init() {
        // This is used to start the peripheral manager before we beacon our signal
        _ = BluetoothBeacon.peripheralManager
    }
    
    func startBroadcasting() {
        BluetoothBeacon.peripheralManager.startAdvertising([
            CBAdvertisementDataLocalNameKey: "Coronavirus Tracking",
            CBAdvertisementDataServiceUUIDsKey: [BluetoothBeacon.serviceUUID]
        ])
        .subscribe()
        .disposed(by: disposeBag)
    }
        
    func stopBroadcasting() {
        disposeBag = DisposeBag()
    }
}
