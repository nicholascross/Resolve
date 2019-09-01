//
//  File.swift
//  
//
//  Created by Nicholas Cross on 25/8/19.
//

import Foundation

public protocol DependencyRegister {
    func registerDependencies(container: DependencyContainer)
}

public protocol DependencyContainer {
    func tryResolve<T>(variant: String?) throws -> T
    func resolve<T>(variant: String?) -> T
    func store<T>(object: T, variant: String?)
    func register<T>(variant: String?, resolver: @escaping ()->T, storer: @escaping (T)->())
    func removeResolver<T>(for type: T.Type, variant: String?)
    func clearResolvers()
}

public extension DependencyContainer {

    func resolve<T>() -> T {
        self.resolve(variant: nil)
    }

    func store<T>(object: T) {
        self.store(object: object, variant: nil)
    }

    func register<T>(resolver: @escaping ()->T) {
        self.register(variant: nil, resolver: resolver, storer: {_ in})
    }

    func register<T>(variant: String, resolver: @escaping ()->T) {
        self.register(variant: variant, resolver: resolver, storer: {_ in})
    }

    func removeResolver<T>(for type: T.Type) {
        self.removeResolver(for: type, variant: nil)
    }
}
