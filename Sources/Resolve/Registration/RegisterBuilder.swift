import Foundation

@resultBuilder
public struct RegisterBuilder {
    public static func buildBlock(_ components: DependencyRegistering...) -> [DependencyRegistering] {
        components
    }
}
