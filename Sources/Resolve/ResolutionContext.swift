import Foundation

public class ResolutionContext: DependencyContainer {
    private var resolvers: [String:()->Any]
    private var storers: [String:(Any)->()]

    private static let containerContext = ResolutionContext()

    public init() {
        self.resolvers = [:]
        self.storers = [:]
    }

    public func tryResolve<T>(variant: String? = nil) throws -> T {
        let key = ResolutionContext.keyName(type:T.self, variant: variant)

        guard let resolver = resolvers[key] else {
            throw ResolutionError.missingResolver
        }

        //Use previously registered resolver

        //It is not be possible to register a resolver that does not return type 'T'
        return resolver() as! T
    }

    public func resolve<T>(variant: String? = nil) -> T {
        guard let resolved = try? tryResolve(variant: variant) as T else {
            fatalError("Cannot resolve unregistered type: \(T.self)")
        }

        return resolved
    }

    public func store<T>(object: T, variant: String? = nil) {
        let key = ResolutionContext.keyName(type: T.self, variant: variant)

        guard let storer = storers[key] else {
            return
        }

        storer(object)
    }

    public func register<T>(variant: String?, resolver: @escaping ()->T, storer: @escaping (T)->()) {
        let key = ResolutionContext.keyName(type:T.self, variant: variant)
        let containerKey = ResolutionContext.keyName(type: DependencyContainer.self, variant: key)

        guard resolvers[key] == nil else {
            // Already has registered resolver
            return
        }

        resolvers[key] = resolver
        storers[key] = { storer($0 as! T) }

        // multiple containers for a single type variant cannot be automatically
        // resolved, only the first container registered will be used
        if !ResolutionContext.containerContext.resolvers.keys.contains(containerKey) {
            // global registration of the container used to resolve this type
            // this allows usage of @Resolve property wrapper without specification
            // of the container to be used when resolving
            ResolutionContext.containerContext.resolvers[containerKey] = { self as DependencyContainer }
        }

        // Registering a dependency register will trigger
        // the registration of the registers dependencies
        if T.self is DependencyRegister.Type {
            let register: DependencyRegister = resolver() as! DependencyRegister
            register.registerDependencies(container: self)
        }
    }

    public func removeResolver<T>(for type: T.Type, variant: String? = nil) {
        let key = ResolutionContext.keyName(type:T.self, variant: variant)
        resolvers[key] = nil
        storers[key] = nil
    }

    public func clearResolvers() {
        resolvers = [:]
        storers = [:]
    }

    static func resolveContainer<T>(type: T.Type, variant: String?) -> DependencyContainer {
        return containerContext.resolve(variant: keyName(type: type, variant: variant))
    }

    static func clearContainerContext() {
        containerContext.clearResolvers()
    }

    private static func keyName<T>(type: T.Type, variant: String?) -> String {
        guard let suffix = variant else {
            return "\(String(describing:T.self))"
        }

        return "\(String(describing:T.self))-\(suffix)"
    }
}

public enum ResolutionError: Error {
    case missingResolver
}
