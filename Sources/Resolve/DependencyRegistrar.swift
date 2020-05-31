import Foundation

public extension DependencyContainer {

    func persistent<Type>(variant: String? = nil, _ factory: @escaping () -> Type) {
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

    func transient<Type: AnyObject>(variant: String? = nil, _ factory: @escaping () -> Type) {
        weak var object: Type?

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

    func ephemeral<Type>(variant: String? = nil, _ factory: @escaping () -> Type) {
        register(variant: variant, resolver: factory, storer: { _ in })
    }

}

