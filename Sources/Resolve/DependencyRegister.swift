import Foundation

public protocol DependencyRegister {
    func registerDependencies(resolver: Resolver)
}
