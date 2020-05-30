import XCTest
@testable import Resolve

final class SwinjectReadmeTests: XCTestCase {

    func testReadme() {
        let context = ResolutionContext()
        context.makeDefault()

        context.register(variant: "Mimi") { Cat(name: "Mimi") as Animal }
        context.register { PetOwner() as Person }
        let petOwner: Person = context.resolve()
        petOwner.play()
    }

    func testStorage() {
        class Example {

        }

        class Example2 {

        }

        class Example3 {

        }

        let container = ResolutionContext()

        container.registerAll {
            persistent { Example() }
            transient { Example2() }
            ephemeral { Example3() }
        }

        var example: Example? = container.resolve() as Example
        var example2: Example2? = container.resolve() as Example2
        let example3: Example3 = container.resolve()

        // persistent value is not recreated
        XCTAssertTrue(example === container.resolve() as Example)

        // persistent value will not be recreated if existing reference is cleared
        weak var exampleA = example
        example = nil
        XCTAssertTrue(exampleA === container.resolve() as Example)


        XCTAssertTrue(example2 === container.resolve() as Example2)

        // transient value will be recreated if existing reference is cleared
        weak var example2a = example2
        example2 = nil
        XCTAssertTrue(example2a !== container.resolve() as Example2)

        // ephemeral value is always recreated
        XCTAssertTrue(example3 !== container.resolve() as Example3)
    }
}

protocol Animal {
    var name: String? { get }
}

class Cat: Animal {
    let name: String?

    init(name: String?) {
        self.name = name
    }
}

protocol Person {
    func play()
}

class PetOwner: Person {

    @Resolve(variant: "Mimi") var pet: Animal

    func play() {
        let name = pet.name ?? "someone"
        print("I'm playing with \(name).")
    }
}
