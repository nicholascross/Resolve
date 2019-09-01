//
//  File.swift
//  
//
//  Created by Nicholas Cross on 25/8/19.
//

import Foundation

public class ResolutionContext: DependencyContainer {

    private var resolvers: [String:(ResolutionContext)->Any]
    private var storers: [String:(Any)->()]

    public static let global = ResolutionContext()

    public init() {
        self.resolvers = [:]
        self.storers = [:]
    }

    public func makeDefault() {
        // @Resolve will now internally use this context when no other is specified
        ResolutionContext.global.register { self as DependencyContainer }
    }

    public func tryResolve<T>(variant: String? = nil) throws -> T {
        let key = ResolutionContext.keyName(type:T.self, variant: variant)

        guard let resolver = resolvers[key] else {
            throw ResolutionError.missingResolver
        }

        //Use previously registered resolver

        //It is not be possible to register a resolver that does not return type 'T'
        return resolver(self) as! T
    }

    public func resolve<T>(variant: String? = nil) -> T {
        guard let resolved = try? tryResolve(variant: variant) as T else {
            fatalError("Cannot resolve unregistered type: \(T.self)")
        }

        return resolved
    }

    public func store<T>(object: T, variant: String? = nil) {
        let key = ResolutionContext.keyName(type: T.self, variant: variant)

        guard let storer = storers[key] else {
            return
        }

        storer(object)
    }

    public func register<T>(variant: String? = nil, resolver: @escaping ()->T) {
        register(variant: variant, resolver: {_ in resolver() }, storer: {_ in})
    }

    public func register<T>(variant: String? = nil, resolver: @escaping (ResolutionContext)->T) {
        register(variant: variant, resolver: resolver, storer: {_ in})
    }

    public func register<T>(variant: String? = nil, resolver: @escaping (ResolutionContext)->T, storer: @escaping (T)->()) {
        let key = ResolutionContext.keyName(type:T.self, variant: variant)

        guard resolvers[key] == nil else {
            // Already has registered resolver
            return
        }

        resolvers[key] = resolver
        storers[key] = { storer($0 as! T) }

        // Registering a dependency register will trigger
        // the registration of the registers dependencies
        if T.self is DependencyRegister.Type {
            let register: DependencyRegister = resolver(self) as! DependencyRegister
            register.registerDependencies()
        }
    }

    public func removeResolver<T>(for type: T.Type, variant: String? = nil) {
        let key = ResolutionContext.keyName(type:T.self, variant: variant)
        resolvers[key] = nil
        storers[key] = nil
    }

    public func clearResolvers() {
        resolvers = [:]
        storers = [:]
    }

    private static func keyName<T>(type: T.Type, variant: String?) -> String {
        guard let suffix = variant else {
            return "\(String(describing:T.self))"
        }

        return "\(String(describing:T.self))-\(suffix)"
    }
}

public enum ResolutionError: Error {
    case missingResolver
}
