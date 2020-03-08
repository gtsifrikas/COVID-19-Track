//
//  Inject.swift
//  workable
//
//  Created by George Tsifrikas on 5/3/20.
//  Copyright © 2020 Workable. All rights reserved.
//

import Foundation

@propertyWrapper
public struct Injected<Service> {
    
    private var service: Service?
    public var container: Resolver?
    public var name: String?
    public var wrappedValue: Service {
        mutating get {
            if service == nil {
                service = try? (container ?? Resolver.root)?.resolve(name: name)
            }
            return service!
        }
        mutating set {
            service = newValue
        }
    }
    public var projectedValue: Injected<Service> {
        get {
            return self
        }
        mutating set {
            self = newValue
        }
    }
    
    public init() {}
}
