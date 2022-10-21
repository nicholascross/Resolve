import Foundation

public protocol Resolver: AnyObject {
    func tryResolve<T>(variant: String?, useGlobalResolvers: Bool) throws -> T
    func resolve<T>(variant: String?) -> T
    func store<T>(object: T, variant: String?, useGlobalResolvers: Bool)
    func register<T>(variant: String?, resolver: @escaping () -> T, storer: @escaping (T) -> Void)
    func removeResolver<T>(for type: T.Type, variant: String?)
    func clearResolvers()
}

public extension Resolver {
    func resolve<T>() -> T {
        resolve(variant: nil)
    }

    func store<T>(object: T) {
        store(object: object, variant: nil, useGlobalResolvers: true)
    }
    
    func store<T>(object: T, variant: String?) {
        store(object: object, variant: variant, useGlobalResolvers: true)
    }
    
    func tryResolve<T>(variant: String?) throws -> T {
        try tryResolve(variant: variant, useGlobalResolvers: true)
    }
    
    func register<T>(resolver: @escaping () -> T) {
        register(variant: nil, resolver: resolver, storer: { _ in })
    }

    func register<T>(variant: String, resolver: @escaping () -> T) {
        register(variant: variant, resolver: resolver, storer: { _ in })
    }

    func removeResolver<T>(for type: T.Type) {
        removeResolver(for: type, variant: nil)
    }

    func persistent<Type>(variant: String? = nil, factory: @escaping () -> Type) {
        var object: Type?

        let resolver: () -> Type = {
            guard let stored = object else {
                let newObject = factory()
                object = newObject
                return newObject
            }
            return stored
        }

        let storer: (Type) -> Void = { object = $0 }

        register(variant: variant, resolver: resolver, storer: storer)
    }

    func transient<Type>(variant: String? = nil, factory: @escaping () -> Type) {
        weak var object: AnyObject?

        let resolver: () -> Type = {
            guard let stored = object else {
                let newObject = factory()
                object = newObject as AnyObject
                return newObject
            }

            return stored as! Type
        }

        let storer: (Type) -> Void = { object = $0 as AnyObject }

        register(variant: variant, resolver: resolver, storer: storer)
    }

    func ephemeral<Type>(variant: String? = nil, factory: @escaping () -> Type) {
        register(variant: variant, resolver: factory, storer: { _ in })
    }
}
