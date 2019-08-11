import Foundation
import Resolve

//MARK: Resolve

public class EphemeralClass: Resolvable, NoStorage {

    public static func create() -> EphemeralClass {
        return EphemeralClass()
    }
}

public class TransientClass: Resolvable, WeakStorage {
    public static weak var storage: TransientClass?

    public static func create() -> TransientClass {
        return TransientClass()
    }
}

public class PersistentClass: Resolvable, PersistentStorage {
    public static var storage: PersistentClass!

    public static func create() -> PersistentClass {
        return PersistentClass()
    }
}

//MARK: Resolve dependencies

public class EphemeralClassWithDependencies: Resolvable, NoStorage {

    @Resolve var dependency1: EphemeralClass
    @Resolve var dependency2x: TransientClassWithDependencies

    public static func create() -> EphemeralClassWithDependencies {
        return EphemeralClassWithDependencies()
    }
}

public class TransientClassWithDependencies: Resolvable, WeakStorage {
    public static weak var storage: TransientClassWithDependencies?

    @Resolve var dependency1: EphemeralClass
    @Resolve var dependency2: TransientClass
    @Resolve var dependency3x: PersistentClassWithDependencies
    @Resolve var loop: TransientClassWithDependencies

    public static func create() -> TransientClassWithDependencies {
        return TransientClassWithDependencies()
    }
}

public class PersistentClassWithDependencies: Resolvable, PersistentStorage {
    public static var storage: PersistentClassWithDependencies!

    @Resolve var dependency1: EphemeralClass
    @Resolve var dependency2: TransientClass
    @Resolve var dependency3: PersistentClass
    @Resolve var loop: PersistentClassWithDependencies

    public static func create() -> PersistentClassWithDependencies {
        return PersistentClassWithDependencies()
    }
}

//MARK: Resolve variants

private var dateStorage: [String : DateFormatter] = [:]

extension DateFormatter: ResolvableVariant, PersistentVariantStorage {
    public static var storage: [String : DateFormatter] {
        get {
            dateStorage
        }
        set {
            dateStorage = newValue
        }
    }

    public static func create(variant: String) -> DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = variant
        return formatter
    }
}

private var patternStorage: [String: WeakBox<NSRegularExpression>] = [:]

extension NSRegularExpression: ResolvableVariant, WeakVariantStorage {
    public static var storage: [String : WeakBox<NSRegularExpression>] {
        get {
            patternStorage
        }
        set {
            patternStorage = newValue
        }
    }

    public static func create(variant: String) -> NSRegularExpression {
        return try! NSRegularExpression(pattern: variant, options: [])
    }
}

public struct EphemeralVariant: ResolvableVariant, NoVariantStorage, Equatable {

    public let variant: String

    public static func create(variant: String) -> EphemeralVariant {
        return EphemeralVariant(variant: variant)
    }
}

public class TestResolveVariant {
    @ResolveVariant("dd MM yyyy") var dateFormat: DateFormatter
    @ResolveVariant("hi") var dep1: EphemeralVariant
    @ResolveVariant("dog") var regex: NSRegularExpression
}

//MARK: Resolve interfaces

public protocol ExampleRepository {
    func getWidgets<T>()->T?
}

class ExampleService: ExampleRepository, Resolvable, PersistentStorage {

    public static var storage: ExampleService!

    public static func create() -> ExampleService {
        return ExampleService()
    }

    public func getWidgets<T>()->T? {
        return nil
    }
}

public class ExampleUseCase {
    @ResolveInterface public var repository: ExampleRepository
}

public struct Container: Resolvable, PersistentStorage {
    public static var storage: Container!

    public static func create() -> Container {
        let container = Container()
        container.registerAll()
        return container
    }

    @Resolve public var register: ResolutionProvider

    private func registerAll() {
        register.register(interface: ExampleRepository.self, resolvable: ExampleService.self)
    }
}
