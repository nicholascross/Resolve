public protocol ResolvableType {
    associatedtype ResolvedType

    static func create() -> ResolvedType

    static func resolve() -> ResolvedType

    static func store(object: ResolvedType)
}

public protocol Resolvable: ResolvableType where ResolvedType == Self {

}

@propertyWrapper
public struct Resolve<T: Resolvable> {
    var resolved: T.ResolvedType?

    public init() {
        self.resolved = nil
    }

    public var wrappedValue:T {
        get {
            T.resolve()
        }
        set {
            T.store(object: newValue)
        }
    }
}
