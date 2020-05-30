import Foundation

public typealias Storage = (DependencyContainer) -> Void

@_functionBuilder
public struct DependencyRegistrar {
    static func buildBlock(_ resolvers: Storage...) -> [Storage] {
        resolvers
    }
}

public extension DependencyContainer {
    func registerAll(@DependencyRegistrar storage: () -> [Storage]) {
        storage().forEach { register in register(self) }
    }
}

public func persistent<Type>(_ factory: @escaping () -> Type) -> Storage {
    var object: Type?
    let storer: Storage = { container in
        container.register { () -> Type in
            guard let stored = object else {
                let newObject = factory()
                object = newObject
                return newObject
            }
            return stored
        }
    }
    return storer
}

public func transient<Type: AnyObject>(_ factory: @escaping () -> Type) -> Storage {
    weak var object: Type?
    let storer: Storage = { container in
        container.register { [weak object] () -> Type in
            guard let stored = object else {
                let newObject = factory()
                object = newObject
                return newObject
            }
            return stored
        }
    }
    return storer
}

public func ephemeral<Type>(_ factory: @escaping () -> Type) -> Storage {
    let storer: Storage = { container in
        container.register(resolver: factory)
    }

    return storer
}
