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

}
