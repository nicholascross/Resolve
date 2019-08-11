import XCTest
@testable import Resolve

final class ResolveAdvancedTests: XCTestCase {
    func testInterfaceResolution() {
        let container = Container.resolve()
        let repository: ExampleRepository = container.register.resolveInterface()

        XCTAssertTrue(repository is ExampleService)
    }

    func testResolveInterface() {
        let _ = Container.resolve()
        let useCase = ExampleUseCase()

        XCTAssertTrue(useCase.repository is ExampleService)
    }

    func testInterfaceStorage() {
        let _ = Container.resolve()
        let useCase = ExampleUseCase()
        let service = ExampleService()
        useCase.repository = service

        XCTAssert(service === useCase.repository as! ExampleService)
    }

    func testEphemeralDependencies() {
        let a = EphemeralClassWithDependencies.resolve()

        XCTAssert(a.dependency1 !== a.dependency2x.dependency3x.dependency1)
        XCTAssert(a.dependency2x.dependency2 === a.dependency2x.dependency3x.dependency2)
    }

    func testTransientDependenciesAndCycles() {
        var a: TransientClassWithDependencies! = TransientClassWithDependencies.resolve()

        XCTAssert(a.dependency3x.dependency2 === a.dependency2)
        XCTAssert(a.loop.loop.loop.loop === a)

        weak var b = a
        a = nil
        let c = TransientClassWithDependencies.resolve()

        XCTAssert(c !== b)
        XCTAssertNil(b)
    }

    func testPersistentDependenciesAndCycles() {
        let a = PersistentClassWithDependencies.resolve()

        XCTAssert(a.loop.loop.loop.loop === a)
    }

    func testNoStorage() {
        let a = PersistentClassWithDependencies.resolve()
        let b = EphemeralClass()
        a.dependency1 = b

        XCTAssert(b !== a.dependency1)
    }

    func testTransientStorage() {
        let a = PersistentClassWithDependencies.resolve()
        let b = TransientClass()
        a.dependency2 = b

        XCTAssert(b === a.dependency2)
    }

    func testPersistentStorage() {
        let a = PersistentClassWithDependencies.resolve()
        let b = PersistentClass()
        a.dependency3 = b

        XCTAssert(b === a.dependency3)
    }

    static var allTests = [
        ("testInterfaceResolution", testInterfaceResolution),
        ("testResolveInterface", testResolveInterface),
        ("testEphemeralDependencies", testEphemeralDependencies),
        ("testTransientDependenciesAndCycles", testTransientDependenciesAndCycles),
        ("testPersistentDependenciesAndCycles", testPersistentDependenciesAndCycles),
        ("testNoStorage", testNoStorage),
        ("testTransientStorage", testTransientStorage),
        ("testPersistentStorage", testPersistentStorage),
    ]
}
