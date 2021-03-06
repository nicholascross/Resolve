import Foundation

@propertyWrapper
public struct Resolve<T> {
    private var container: DependencyContainer
    private var variant: String?

    public init(container: DependencyContainer, variant: String) {
        self.container = container
        self.variant = variant
    }

    public init(container: DependencyContainer) {
        self.container = container
        variant = nil
    }

    public init() {
        container = ResolutionContext.resolveContainer(type: T.self, variant: variant)
        variant = nil
    }

    public init(variant: String) {
        container = ResolutionContext.resolveContainer(type: T.self, variant: variant)
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
