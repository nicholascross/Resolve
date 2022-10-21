import Foundation

@propertyWrapper
public struct Resolve<T> {
    private var container: Resolver
    private var variant: String?

    public init(container: Resolver, variant: String) {
        self.container = container
        self.variant = variant
    }

    public init(container: Resolver) {
        self.container = container
        variant = nil
    }

    public init() {
        container = DependencyResolver()
        variant = nil
    }

    public init(variant: String) {
        container = DependencyResolver()
        self.variant = variant
    }

    public var wrappedValue: T {
        get {
            return container.resolve(variant: variant) as T
        }
        set {
            container.store(object: newValue, variant: variant)
        }
    }
}
