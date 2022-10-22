import Foundation

public struct Dependency<T>: DependencyRegistering {
    let resolve: () -> T
    let store: (T) -> Void
    let variant: String?
    
    public init(variant: String? = nil, _ resolve: @escaping () -> T, store: ((T) -> Void)? = nil) {
        self.resolve = resolve
        self.store = store ?? { _ in }
        self.variant = variant
    }
    
    public func register(resolver: Resolver) {
        resolver.register(variant: variant, resolver: resolve, storer: store)
    }
}

public struct Persistent<T>: DependencyRegistering {
    let resolve: () -> T
    let variant: String?
    
    public init(variant: String? = nil, _ resolve: @escaping () -> T) {
        self.resolve = resolve
        self.variant = variant
    }
    
    public func register(resolver: Resolver) {
        resolver.persistent(variant: variant, factory: resolve)
    }
}

public struct Transient<T>: DependencyRegistering {
    let resolve: () -> T
    let variant: String?
    
    public init(variant: String? = nil, _ resolve: @escaping () -> T) {
        self.resolve = resolve
        self.variant = variant
    }
    
    public func register(resolver: Resolver) {
        resolver.transient(variant: variant, factory: resolve)
    }
}

public struct Ephemeral<T>: DependencyRegistering {
    let resolve: () -> T
    let variant: String?
    
    public init(variant: String? = nil, _ resolve: @escaping () -> T) {
        self.resolve = resolve
        self.variant = variant
    }
    
    public func register(resolver: Resolver) {
        resolver.ephemeral(variant: variant, factory: resolve)
    }
}
