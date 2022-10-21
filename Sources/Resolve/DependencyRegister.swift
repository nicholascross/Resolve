import Foundation

public protocol DependencyRegister {
    func registerDependencies(container: Resolver)
}
