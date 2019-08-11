import Foundation

public protocol NoStorage { }

public protocol WeakStorage {
    associatedtype ResolvedType: AnyObject = Self
    static var storage: ResolvedType? { get set }
}

public protocol PersistentStorage {
    associatedtype ResolvedType = Self
    static var storage: ResolvedType! { get set }
}

public extension NoStorage where Self: Resolvable {
    static func store(object: ResolvedType) { /*do nothing*/ }

    static func resolve() -> ResolvedType {
        return Self.create()
    }
}

public extension WeakStorage where Self: Resolvable {
    static func store(object: ResolvedType) {
        creationLock.sync { storage = object }
    }

    static func resolve() -> ResolvedType {
        guard let resolved = storage else {
            return creationLock.sync {
                guard let resolved = storage else {
                    let newValue = Self.create()
                    storage = newValue

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

public extension PersistentStorage where Self: Resolvable {
    static func store(object: ResolvedType) {
        creationLock.sync { storage = object }
    }

    static func resolve() -> ResolvedType {
        guard let resolved = storage else {
            return creationLock.sync {
                guard let resolved = storage else {
                    let newValue = Self.create()
                    storage = newValue

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

