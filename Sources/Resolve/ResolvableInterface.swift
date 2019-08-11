//
//  File.swift
//  
//
//  Created by Nicholas Cross on 11/8/19.
//

import Foundation

public class ResolutionProvider: Resolvable, PersistentStorage {

    private var resolvers: [String:()->Any] = [:]
    private var storers: [String:(Any)->()] = [:]

    static let provider = ResolutionProvider()
    public static var storage: ResolutionProvider!

    public static func create() -> ResolutionProvider {
        provider
    }

    public func resolveInterface<T>() -> T! {
        guard let resolver = resolvers[String(describing:T.self)] else {
            return nil
        }

        return resolver() as? T
    }

    public func storeInterface<T>(object: T) {
        guard let storer = storers[String(describing: T.self)] else {
            return
        }

        storer(object)
    }

    public func register<InterfaceType, ResolvedType: Resolvable>(interface: InterfaceType.Type, resolvable: ResolvedType.Type) {
        let resolver: () -> InterfaceType = {
            guard let resolved = ResolvedType.resolve() as? InterfaceType else {
                fatalError("resolved type \(ResolvedType.self) does not conform to interface type \(InterfaceType.self)")
            }
            return resolved
        }

        let storer: (InterfaceType) -> () = { (newValue: InterfaceType) in
            guard let object = newValue as? ResolvedType else {
                fatalError("unexpected resolved type \(ResolvedType.self) conforming to interface type \(InterfaceType.self)")
            }
            ResolvedType.store(object: object)
        }

        register(resolver: resolver, storer: storer)
    }

    private func register<T>(resolver: @escaping ()->T, storer: @escaping (T)->()) {
        resolvers[String(describing:T.self)] = resolver
        storers[String(describing:T.self)] = { storer($0 as! T) }
    }
}

@propertyWrapper
public struct ResolveInterface<T> {
    @Resolve var resolutionProvider: ResolutionProvider
    var resolved: T?

    public init() {
        self.resolved = nil
    }

    public var wrappedValue:T {
        get {
            resolutionProvider.resolveInterface()
        }
        set {
            resolutionProvider.storeInterface(object: newValue)
        }
    }
}
