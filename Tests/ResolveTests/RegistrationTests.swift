import Foundation
import XCTest
@testable import Resolve

final class RegistrationTests: XCTestCase {
    
    override func tearDown() {
        DependencyResolver.clearResolvers()
    }

    func testRegistration() {
        var x: Int = 4
        DependencyResolver.register {
            Dependency { 3 }
            Dependency(variant: "test") { 2 }
            Dependency(variant: "boop") { x } store: { a in
                x = a
            }
        }
        
        let resolver = DependencyResolver()
        XCTAssertEqual(resolver.resolve() as Int, 3)
        XCTAssertEqual(resolver.resolve(variant: "test") as Int, 2)
        XCTAssertEqual(resolver.resolve(variant: "boop") as Int, 4)
        
        resolver.store(object: 5, variant: "boop")
        XCTAssertEqual(resolver.resolve(variant: "boop") as Int, 5)
    }
    
    func testLifetime() {
        DependencyResolver.register {
            Persistent(variant: "a") { 6 }
            Transient(variant: "b") { 5 }
            Ephemeral(variant: "c") { 4 }
        }
        
        let resolver = DependencyResolver()
        XCTAssertEqual(resolver.resolve(variant: "a") as Int, 6)
        XCTAssertEqual(resolver.resolve(variant: "b") as Int, 5)
        XCTAssertEqual(resolver.resolve(variant: "c") as Int, 4)
    }
}
