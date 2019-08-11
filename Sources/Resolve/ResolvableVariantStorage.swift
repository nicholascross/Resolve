import Foundation

public protocol WeakVariantStorage {
    associatedtype ResolvedType: AnyObject = Self
    static var storage: [String: WeakBox<ResolvedType>] { get set }
}

public protocol PersistentVariantStorage {
    associatedtype ResolvedType = Self
    static var storage: [String: ResolvedType] { get set }
}

public protocol NoVariantStorage { }

public extension NoVariantStorage where Self: ResolvableVariant {
    static func store(object: ResolvedType, variant: String) { /*do nothing*/ }

    static func resolve(variant: String) -> ResolvedType {
        return Self.create(variant: variant)
    }
}

public extension WeakVariantStorage where Self: ResolvableVariant {
    static func store(object: ResolvedType, variant: String) {
        creationLock.sync { storage[variant] = WeakBox(item: object) }
    }

    static func resolve(variant: String) -> ResolvedType {
        guard let resolved = storage[variant]?.item else {
            return creationLock.sync {
                guard let resolved = storage[variant]?.item else {
                    let newValue = Self.create(variant: variant)
                    storage[variant] = WeakBox(item: newValue)

                    //Newly resolved
                    return newValue
                }

                //Resolved whilst waiting for lock
                return resolved
            }
        }

        //Previously resolved
        return resolved
    }
}

public struct WeakBox<T: AnyObject> {
    weak var item: T?
}

public extension PersistentVariantStorage where Self: ResolvableVariant {
    static func store(object: ResolvedType, variant: String) {
        creationLock.sync { storage[variant] = object }
    }

    static func resolve(variant: String) -> ResolvedType {
        guard let resolved = storage[variant] else {
            return creationLock.sync {
                guard let resolved = storage[variant] else {
                    let newValue = Self.create(variant: variant)
                    storage[variant] = newValue

                    //Newly resolved
                    return newValue
                }

                //Resolved whilst waiting for lock
                return resolved
            }
        }

        //Previously resolved
        return resolved
    }
}
