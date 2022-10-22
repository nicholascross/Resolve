import Foundation

public struct Dependency<T>: DependencyRegistering {
    let resolve: () -> T
    let store: (T) -> Void
    let variant: String?
    
    init(variant: String? = nil, _ resolve: @escaping () -> T, store: ((T) -> Void)? = nil) {
        self.resolve = resolve
        self.store = store ?? { _ in }
        self.variant = variant
    }
    
    public func register(resolver: Resolver) {
        resolver.register(variant: variant, resolver: resolve, storer: store)
    }
}
