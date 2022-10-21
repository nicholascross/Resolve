@testable import Resolve
import XCTest

final class ResolveTests: XCTestCase {
    var context: DependencyContainer!

    override func setUp() {
        context = DependencyResolver()
        DependencyResolver.clearContainerContext()
        Example2.context.clearResolvers()

        context.transient(variant: "number") { TestExample() }
        context.transient { TestExample() }
        context.persistent { Example() }
    }

    func testResolve() {
        let example = context.resolve() as Example
        XCTAssertEqual(example.test.value, "abc")
        XCTAssertEqual(example.test2.value, "abc")

        let testExample = TestExample()
        testExample.value = "123"
        example.test = testExample
        example.test2 = testExample
        let example2 = context.resolve() as Example
        XCTAssertEqual(example2.test.value, "123")
        XCTAssertEqual(example2.test2.value, "123")

        let testExample2 = context.resolve() as TestExample
        XCTAssertTrue(testExample === testExample2)
    }

    func testRegistrationRemoval() {
        let example = context.resolve() as Example
        XCTAssertEqual(example.test.value, "abc")

        do {
            let example2 = try context.tryResolve(variant: nil) as Example
            XCTAssertTrue(example === example2)
        } catch {
            XCTFail()
        }

        context.removeResolver(for: Example.self)
        XCTAssertNil(try? context.tryResolve(variant: nil) as Example)
    }

    func testResolveWithContainer() {
        let context = Example2.context
        context.transient(variant: "number") { TestExample(value: "qwe") }
        context.transient { TestExample(value: "rty") }
        context.persistent { Example2() }

        let example = context.resolve() as Example2
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
    static let context: DependencyContainer = DependencyResolver()

    @Resolve(container: Example2.context) var test: TestExample
    @Resolve(container: Example2.context, variant: "number") var test2: TestExample
}
