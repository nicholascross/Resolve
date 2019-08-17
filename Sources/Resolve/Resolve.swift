//
//  File.swift
//  
//
//  Created by Nicholas Cross on 17/8/19.
//

import Foundation

public class ResolutionContext {

    private var resolvers: [String:(ResolutionContext)->Any] = [:]
    private var storers: [String:(Any)->()] = [:]

    public static let global = ResolutionContext()

    public func resolve<T>(variant: String? = nil) -> T {
        let key = ResolutionContext.keyName(type:T.self, variant: variant)

        guard let resolver = resolvers[key] else {
            fatalError("Cannot resolve unregistered type: \(T.self)")
        }

        //Use previously registered resolver

        //It is not be possible to register a resolver that does not return type 'T'
        return resolver(self) as! T
    }

    public func store<T>(object: T, variant: String? = nil) {
        let key = ResolutionContext.keyName(type:T.self, variant: variant)

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
        resolvers[key] = resolver
        storers[key] = { storer($0 as! T) }
    }

    public static func keyName<T>(type: T.Type, variant: String?) -> String {
        guard let suffix = variant else {
            return "\(String(describing:T.self))"
        }

        return "\(String(describing:T.self))-\(suffix)"
    }
}

@propertyWrapper
public struct Resolve<T> {
    private var resolver: ResolutionContext
    private var variant: String?

    public init() {
        self.resolver = .global
        self.variant = nil
    }

    public init(resolver: ResolutionContext, variant: String) {
        self.resolver = resolver
        self.variant = variant
    }

    public init(resolver: ResolutionContext) {
        self.resolver = resolver
        self.variant = nil
    }

    public init(variant: String) {
        self.resolver = .global
        self.variant = variant
    }

    public var wrappedValue:T {
        get {
            return self.resolver.resolve(variant: variant) as T
        }
        set {
            self.resolver.store(object: newValue, variant: variant)
        }
    }
}
