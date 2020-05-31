import Foundation

public protocol DependencyRegister {
    func registerDependencies(container: DependencyContainer)
}

public protocol DependencyContainer: class {
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

        let storer: (Type) -> () = { object = $0 }

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

        let storer: (Type) -> () = { object = $0 as AnyObject }

        register(variant: variant, resolver: resolver, storer: storer)
    }

    func ephemeral<Type>(variant: String? = nil, factory: @escaping () -> Type) {
        register(variant: variant, resolver: factory, storer: { _ in })
    }

}
