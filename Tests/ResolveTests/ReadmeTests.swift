import XCTest
@testable import Resolve

final class ReadmeTests: XCTestCase {

    func testReadme() {
        let _ = ExampleContainer.resolve()
        let petOwner: Person = PetOwner.resolve()
        petOwner.play()
    }
}

protocol Animal {
    var name: String? { get }
}

class Cat: Animal, Resolvable, NoStorage {
    let name: String?

    init(name: String?) {
        self.name = name
    }

    static func create() -> Cat {
        return Cat(name: "Mimi")
    }
}

protocol Person {
    func play()
}

class PetOwner: Person, Resolvable, NoStorage {
    @ResolveInterface var pet: Animal

    init(pet: Animal) {
        self.pet = pet
    }

    init() {}

    static func create() -> PetOwner {
        PetOwner()
    }

    func play() {
        let name = pet.name ?? "someone"
        print("I'm playing with \(name).")
    }
}

private struct ExampleContainer: Resolvable, PersistentStorage {
    static var storage: ExampleContainer!

    @Resolve var registrar: ResolutionProvider

    static func create() -> ExampleContainer {
        let container = ExampleContainer()
        container.registrar.register(interface: Person.self, resolvable: PetOwner.self)
        container.registrar.register(interface: Animal.self, resolvable: Cat.self)
        return container
    }
}
