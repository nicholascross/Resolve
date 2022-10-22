@testable import Resolve
import XCTest

final class StorageTests: XCTestCase {
    var resolver: DependencyResolver!

    override func setUp() {
        resolver = DependencyResolver()
        DependencyResolver.clearResolvers()
    }

    func testLifetimePersistent() {
        resolver.persistent { Example() }

        var example: Example? = resolver.resolve() as Example

        // persistent value is not recreated
        XCTAssertTrue(example === resolver.resolve() as Example)

        // persistent value will not be recreated if existing reference is cleared
        weak var exampleA = example
        example = nil
        XCTAssertTrue(exampleA === resolver.resolve() as Example)

        let replacement = Example()
        resolver.store(object: replacement)
        XCTAssertNil(exampleA)
        XCTAssertTrue(replacement === resolver.resolve() as Example)
    }

    func testLifetimeTransient() {
        resolver.transient { Example() }

        var example2: Example? = resolver.resolve() as Example

        XCTAssertTrue(example2 === resolver.resolve() as Example)

        // transient value will be recreated if existing reference is cleared
        weak var example2a = example2
        example2 = nil
        XCTAssertTrue(example2a !== resolver.resolve() as Example)

        let replacement = Example()
        resolver.store(object: replacement)
        XCTAssertNil(example2a)
        XCTAssertTrue(replacement === resolver.resolve() as Example)
    }

    func testLifetimeEphemeral() {
        resolver.ephemeral { Example() }

        let example3: Example = resolver.resolve()

        // ephemeral value is always recreated
        XCTAssertTrue(example3 !== resolver.resolve() as Example)

        let replacement = Example()
        resolver.store(object: replacement)
        XCTAssertTrue(replacement !== resolver.resolve() as Example)
    }
}

private class Example {}
