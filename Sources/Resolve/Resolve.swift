import Foundation

@propertyWrapper
public struct Resolve<T> {
    private var resolver: Resolver
    private var variant: String?

    public init(resolver: Resolver, variant: String) {
        self.resolver = resolver
        self.variant = variant
    }

    public init(resolver: Resolver) {
        self.resolver = resolver
        variant = nil
    }

    public init() {
        resolver = DependencyResolver()
        variant = nil
    }

    public init(variant: String) {
        resolver = DependencyResolver()
        self.variant = variant
    }

    public var wrappedValue: T {
        get {
            return resolver.resolve(variant: variant) as T
        }
        set {
            resolver.store(object: newValue, variant: variant)
        }
    }
}
