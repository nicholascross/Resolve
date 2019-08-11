import XCTest
@testable import Resolve

final class ResolveTests: XCTestCase {
    func testResolveWithNoStorage() {
        let a = EphemeralClass.resolve()
        let b = EphemeralClass.resolve()

        XCTAssert(a !== b)
    }

    func testResolveWithWeakStorage() {
        var a: TransientClass? = TransientClass.resolve()
        var b: TransientClass? = TransientClass.resolve()
        weak var c = b

        XCTAssert(a === b)

        a = nil
        b = nil
        let d = TransientClass.resolve()

        XCTAssert(c !== d)
        XCTAssertNil(c)
        XCTAssertNotNil(d)
    }

    func testResolveWithPersistentStorage() {
        var a: PersistentClass? = PersistentClass.resolve()
        var b: PersistentClass? = PersistentClass.resolve()
        weak var c = b

        XCTAssert(a === b)

        a = nil
        b = nil
        let d = PersistentClass.resolve()

        XCTAssert(c === d)
        XCTAssertNotNil(c)
        XCTAssertNotNil(d)
    }

    func testResolveVariantWithNoStorage() {
        func testResolveWithNoStorage() {
            let a = EphemeralVariant.resolve(variant: "boop")
            let b = EphemeralVariant.resolve(variant: "bop")
            let c = EphemeralVariant.resolve(variant: "boop")

            XCTAssertEqual(a, c)
            XCTAssertNotEqual(a, b)
        }
    }

    func testResolveVariantWithWeakStorage() {
        var expression = NSRegularExpression.resolve(variant: #"\w\w\w\w-\d\d\d\d"#)
        var anotherExpression = NSRegularExpression.resolve(variant: #"\w\w\w\w-\d\d\d\d"#)
        weak var weakExpression = expression

        XCTAssertEqual(expression.pattern, #"\w\w\w\w-\d\d\d\d"#)
        XCTAssertEqual(anotherExpression.pattern, #"\w\w\w\w-\d\d\d\d"#)
        XCTAssert(expression === anotherExpression)

        expression = NSRegularExpression.resolve(variant: "dog")
        anotherExpression = NSRegularExpression.resolve(variant: "cat")
        let theOldExpression = NSRegularExpression.resolve(variant: #"\w\w\w\w-\d\d\d\d"#)

        XCTAssert(weakExpression !== theOldExpression)
        XCTAssertNil(weakExpression)
        XCTAssertNotNil(theOldExpression)
        XCTAssertEqual(expression.pattern, "dog")
        XCTAssertEqual(anotherExpression.pattern, "cat")
        XCTAssertEqual(theOldExpression.pattern, #"\w\w\w\w-\d\d\d\d"#)
    }

    func testResolveVariantWithPersistentStorage() {
        var a: DateFormatter? = DateFormatter.resolve(variant: "dd MM yyyy")
        var b: DateFormatter? = DateFormatter.resolve(variant: "dd MM yyyy")
        weak var c = b

        XCTAssert(a === b)

        a = nil
        b = nil
        let d = DateFormatter.resolve(variant: "dd MM yyyy")

        XCTAssert(c === d)
        XCTAssertNotNil(c)
        XCTAssertNotNil(d)
    }

    func testResolveVariant() {
        let a = TestResolveVariant()

        XCTAssertEqual(a.dateFormat.dateFormat, "dd MM yyyy")
        XCTAssertEqual(a.dep1.variant, "hi")
        XCTAssertEqual(a.regex.pattern, "dog")

        a.dep1 = EphemeralVariant(variant: "world")
        XCTAssertEqual(a.dep1.variant, "hi") //no storage

        a.dateFormat = DateFormatter()
        XCTAssertNotEqual(a.dateFormat.dateFormat, "dd MM yyyy")

        var newExpression = try? NSRegularExpression(pattern: "cat", options: [])
        a.regex = newExpression!
        XCTAssertEqual(a.regex.pattern, "cat")
        newExpression = nil
        XCTAssertEqual(a.regex.pattern, "dog") // weak storage
    }

    static var allTests = [
        ("testResolveWithNoStorage", testResolveWithNoStorage),
        ("testResolveWithWeakStorage", testResolveWithWeakStorage),
        ("testResolveWithPersistentStorage", testResolveWithPersistentStorage),
        ("testResolveVariantWithNoStorage", testResolveVariantWithNoStorage),
        ("testResolveVariantWithWeakStorage", testResolveVariantWithWeakStorage),
        ("testResolveVariantWithPersistentStorage", testResolveVariantWithPersistentStorage),
        ("testResolveVariant", testResolveVariant),
    ]
}
