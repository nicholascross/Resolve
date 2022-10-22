import Foundation

public protocol DependencyRegistering {
    func register(resolver: Resolver)
}

extension DependencyResolver {
    public static func register(@RegisterBuilder _ registers: ()->[DependencyRegistering]) {
        let resolver = DependencyResolver()
        registers().forEach { $0.register(resolver: resolver) }
    }
}
