@testable import Resolve
import XCTest

final class ResolveTests: XCTestCase {
    var resolver: Resolver!

    override func setUp() {
        resolver = DependencyResolver()
        DependencyResolver.clearResolvers()
        Example2.resolver.clearResolvers()

        resolver.transient(variant: "number") { TestExample() }
        resolver.transient { TestExample() }
        resolver.persistent { Example() }
    }

    func testResolve() {
        let example = resolver.resolve() as Example
        XCTAssertEqual(example.test.value, "abc")
        XCTAssertEqual(example.test2.value, "abc")

        let testExample = TestExample()
        testExample.value = "123"
        example.test = testExample
        example.test2 = testExample
        let example2 = resolver.resolve() as Example
        XCTAssertEqual(example2.test.value, "123")
        XCTAssertEqual(example2.test2.value, "123")

        let testExample2 = resolver.resolve() as TestExample
        XCTAssertTrue(testExample === testExample2)
    }

    func testRegistrationRemoval() {
        let example = resolver.resolve() as Example
        XCTAssertEqual(example.test.value, "abc")

        do {
            let example2 = try resolver.tryResolve(variant: nil) as Example
            XCTAssertTrue(example === example2)
        } catch {
            XCTFail()
        }

        resolver.removeResolver(for: Example.self)
        XCTAssertNil(try? resolver.tryResolve(variant: nil) as Example)
    }

    func testResolveWithResolver() {
        let resolver = Example2.resolver
        resolver.transient(variant: "number") { TestExample(value: "qwe") }
        resolver.transient { TestExample(value: "rty") }
        resolver.persistent { Example2() }

        let example = resolver.resolve() as Example2
        XCTAssertEqual(example.test2.value, "qwe")
        XCTAssertEqual(example.test.value, "rty")
    }
}

private class Example {
    @Resolve var test: TestExample
    @Resolve(variant: "number") var test2: TestExample
}

private class TestExample {
    var value = "abc"

    init() {}

    init(value: String) {
        self.value = value
    }
}

private class Example2 {
    static let resolver: Resolver = DependencyResolver()

    @Resolve(resolver: Example2.resolver) var test: TestExample
    @Resolve(resolver: Example2.resolver, variant: "number") var test2: TestExample
}
