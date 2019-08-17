import XCTest
@testable import Resolve

final class SwinjectReadmeTests: XCTestCase {

    func testReadme() {
        let context = ResolutionContext.global
        context.register(variant: "Mimi") { Cat(name: "Mimi") as Animal }
        context.register { PetOwner() as Person }
        let petOwner: Person = context.resolve()
        petOwner.play()
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
