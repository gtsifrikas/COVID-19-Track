//
//  Resolver.swift
//  workable
//
//  Created by George Tsifrikas on 6/3/20.
//  Copyright © 2020 Workable. All rights reserved.
//

import Foundation

public class Resolver {
    
    public typealias Registration = () -> Any
    
    public static var root: Resolver = Resolver()
    
    private var registrations: [String: Registration] = [:]
    
    public func resolve<Service>(name: String? = nil) throws -> Service? {
        
        let type = Service.self
        let name = lookupName(with: name, for: type)
        
        guard let registration = registrations[name] else { throw ResolvingError.couldNotFindDependency }
        guard let dependency = registration() as? Service else { throw ResolvingError.typeMissmatch }
        
        return dependency
    }
 
    public func register<Service>(
        _ type: Service.Type = Service.self,
        name: String? = nil,
        registration: @escaping () -> Service) {
        
        let name = lookupName(with: name, for: type)
        registrations[name] = registration
    }
    
    private func lookupName<Service>(
        with namedDependency: String? = nil,
        for type: Service.Type = Service.self) -> String {
        
        if let namedDependency = namedDependency {
            return "named-\(namedDependency)-\(String(describing: type))"
        } else {
            return "default-\(String(describing: type))"
        }
    }
}

public enum ResolvingError: Error {
    case couldNotFindDependency
    case typeMissmatch
}
