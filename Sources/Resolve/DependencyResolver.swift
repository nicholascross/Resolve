import Foundation

public class DependencyResolver: Resolver {
    private var resolvers: [String: () -> Any]
    private var storers: [String: (Any) -> Void]

    private static let resolver = DependencyResolver()

    public init() {
        resolvers = [:]
        storers = [:]
    }

    public func tryResolve<T>(variant: String? = nil, useGlobalResolvers: Bool = true) throws -> T {
        let key = DependencyResolver.keyName(type: T.self, variant: variant)
        let resolverKey = DependencyResolver.keyName(type: Resolver.self, variant: key)
        
        guard let resolver = resolvers[key] else {
            if useGlobalResolvers,
               DependencyResolver.resolver.resolvers.keys.contains(resolverKey) {
                let resolver = DependencyResolver.resolveResolver(type: T.self, variant: variant)
                return try resolver.tryResolve(variant: variant, useGlobalResolvers: false)
            }
            
            throw DependencyResolverError.missingResolver
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

    public func store<T>(object: T, variant: String? = nil, useGlobalResolvers: Bool = true) {
        let key = DependencyResolver.keyName(type: T.self, variant: variant)
        let resolverKey = DependencyResolver.keyName(type: Resolver.self, variant: key)

        if useGlobalResolvers,
           DependencyResolver.resolver.resolvers.keys.contains(resolverKey) {
            let resolver = DependencyResolver.resolveResolver(type: T.self, variant: variant)
            resolver.store(object: object, variant: variant, useGlobalResolvers: false)
            return
        }
        
        guard let storer = storers[key] else {
            return
        }

        storer(object)
    }

    public func register<T>(variant: String?, resolver: @escaping () -> T, storer: @escaping (T) -> Void) {
        let key = DependencyResolver.keyName(type: T.self, variant: variant)
        let resolverKey = DependencyResolver.keyName(type: Resolver.self, variant: key)

        guard resolvers[key] == nil else {
            // Already has registered resolver
            return
        }

        resolvers[key] = resolver
        storers[key] = { storer($0 as! T) }

        // multiple resolvers for a single type variant cannot be automatically
        // resolved, only the first resolver registered will be used
        if !DependencyResolver.resolver.resolvers.keys.contains(resolverKey) {
            // global registration of the resolver used to resolve this type
            // this allows usage of @Resolve property wrapper without specification
            // of the resolver to be used when resolving
            DependencyResolver.resolver.resolvers[resolverKey] = { self as Resolver }
        }

        // Registering a dependency register will trigger
        // the registration of the registers dependencies
        if T.self is DependencyRegister.Type {
            let register: DependencyRegister = resolver() as! DependencyRegister
            register.registerDependencies(resolver: self)
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

    private static func resolveResolver<T>(type: T.Type, variant: String?) -> Resolver {
        return resolver.resolve(variant: keyName(type: type, variant: variant))
    }

    public static func clearResolvers() {
        resolver.clearResolvers()
    }

    private static func keyName<T>(type _: T.Type, variant: String?) -> String {
        guard let suffix = variant else {
            return "\(String(describing: T.self))"
        }

        return "\(String(describing: T.self))-\(suffix)"
    }
}
