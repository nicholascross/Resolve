import Foundation

public extension Resolver {

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
