import Foundation

public class DependencyResolver: Resolver {
    private var resolvers: [String: () -> Any]
    private var storers: [String: (Any) -> Void]

    private static let containerContext = DependencyResolver()

    public init() {
        resolvers = [:]
        storers = [:]
    }

    public func tryResolve<T>(variant: String? = nil, useGlobalContainers: Bool = true) throws -> T {
        let key = DependencyResolver.keyName(type: T.self, variant: variant)
        let containerKey = DependencyResolver.keyName(type: Resolver.self, variant: key)
        
        guard let resolver = resolvers[key] else {
            if useGlobalContainers,
               DependencyResolver.containerContext.resolvers.keys.contains(containerKey) {
                let container = DependencyResolver.resolveContainer(type: T.self, variant: variant)
                return try container.tryResolve(variant: variant, useGlobalContainers: false)
            }
            
            throw ResolutionError.missingResolver
        }

        // Use previously registered resolver

        // It is not be possible to register a resolver that does not return type 'T'
        return resolver() as! T
    }

    public func resolve<T>(variant: String? = nil) -> T {
        guard let resolved = try? tryResolve(variant: variant) as T else {
            fatalError("Cannot resolve unregistered type: \(T.self)")
        }

        return resolved
    }

    public func store<T>(object: T, variant: String? = nil, useGlobalContainers: Bool = true) {
        let key = DependencyResolver.keyName(type: T.self, variant: variant)
        let containerKey = DependencyResolver.keyName(type: Resolver.self, variant: key)

        if useGlobalContainers,
           DependencyResolver.containerContext.resolvers.keys.contains(containerKey) {
            let container = DependencyResolver.resolveContainer(type: T.self, variant: variant)
            container.store(object: object, variant: variant, useGlobalContainers: false)
            return
        }
        
        guard let storer = storers[key] else {
            return
        }

        storer(object)
    }

    public func register<T>(variant: String?, resolver: @escaping () -> T, storer: @escaping (T) -> Void) {
        let key = DependencyResolver.keyName(type: T.self, variant: variant)
        let containerKey = DependencyResolver.keyName(type: Resolver.self, variant: key)

        guard resolvers[key] == nil else {
            // Already has registered resolver
            return
        }

        resolvers[key] = resolver
        storers[key] = { storer($0 as! T) }

        // multiple containers for a single type variant cannot be automatically
        // resolved, only the first container registered will be used
        if !DependencyResolver.containerContext.resolvers.keys.contains(containerKey) {
            // global registration of the container used to resolve this type
            // this allows usage of @Resolve property wrapper without specification
            // of the container to be used when resolving
            DependencyResolver.containerContext.resolvers[containerKey] = { self as Resolver }
        }

        // Registering a dependency register will trigger
        // the registration of the registers dependencies
        if T.self is DependencyRegister.Type {
            let register: DependencyRegister = resolver() as! DependencyRegister
            register.registerDependencies(container: self)
        }
    }

    public func removeResolver<T>(for _: T.Type, variant: String? = nil) {
        let key = DependencyResolver.keyName(type: T.self, variant: variant)
        resolvers[key] = nil
        storers[key] = nil
    }

    public func clearResolvers() {
        resolvers = [:]
        storers = [:]
    }

    private static func resolveContainer<T>(type: T.Type, variant: String?) -> Resolver {
        return containerContext.resolve(variant: keyName(type: type, variant: variant))
    }

    static func clearContainerContext() {
        containerContext.clearResolvers()
    }

    private static func keyName<T>(type _: T.Type, variant: String?) -> String {
        guard let suffix = variant else {
            return "\(String(describing: T.self))"
        }

        return "\(String(describing: T.self))-\(suffix)"
    }
}

public enum ResolutionError: Error {
    case missingResolver
}
