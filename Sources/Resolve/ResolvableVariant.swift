public protocol ResolvableVariantType {
    associatedtype ResolvedType

    static func create(variant: String) -> ResolvedType

    static func resolve(variant: String) -> ResolvedType

    static func store(object: ResolvedType, variant: String)
}

public protocol ResolvableVariant: ResolvableVariantType where ResolvedType == Self {

}

@propertyWrapper
public struct ResolveVariant<T: ResolvableVariant> {
    let variant: String
    var resolved: T.ResolvedType?

    public init(_ variant: String) {
        self.variant = variant
    }

    public var wrappedValue:T {
        get {
            T.resolve(variant: variant)
        }
        set {
            T.store(object: newValue, variant: variant)
        }
    }
}
