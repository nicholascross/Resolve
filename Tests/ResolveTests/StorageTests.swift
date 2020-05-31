import XCTest
@testable import Resolve

final class StorageTests: XCTestCase {

    var context: ResolutionContext!

    override func setUp() {
        context = ResolutionContext()
        ResolutionContext.clearContainerContext()
    }

    func testLifetimePersistent() {
        context.persistent { Example() }

        var example: Example? = context.resolve() as Example

        // persistent value is not recreated
        XCTAssertTrue(example === context.resolve() as Example)

        // persistent value will not be recreated if existing reference is cleared
        weak var exampleA = example
        example = nil
        XCTAssertTrue(exampleA === context.resolve() as Example)

        let replacement = Example()
        context.store(object: replacement)
        XCTAssertNil(exampleA)
        XCTAssertTrue(replacement === context.resolve() as Example)
    }

    func testLifetimeTransient() {
        context.transient { Example() }

        var example2: Example? = context.resolve() as Example

        XCTAssertTrue(example2 === context.resolve() as Example)

        // transient value will be recreated if existing reference is cleared
        weak var example2a = example2
        example2 = nil
        XCTAssertTrue(example2a !== context.resolve() as Example)

        let replacement = Example()
        context.store(object: replacement)
        XCTAssertNil(example2a)
        XCTAssertTrue(replacement === context.resolve() as Example)

    }

    func testLifetimeEphemeral() {
        context.ephemeral { Example() }

        let example3: Example = context.resolve()

        // ephemeral value is always recreated
        XCTAssertTrue(example3 !== context.resolve() as Example)

        let replacement = Example()
        context.store(object: replacement)
        XCTAssertTrue(replacement !== context.resolve() as Example)
    }

}

private class Example {

}
