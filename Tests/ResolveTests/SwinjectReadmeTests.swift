@testable import Resolve
import XCTest

final class SwinjectReadmeTests: XCTestCase {
    var context: DependencyResolver!

    override func setUp() {
        context = DependencyResolver()
        DependencyResolver.clearContainerContext()
    }

    func testReadme() {
        let context = DependencyResolver()

        context.register(variant: "Mimi") { Cat(name: "Mimi") as Animal }
        context.register { PetOwner() as Person }
        let petOwner: Person = context.resolve()
        petOwner.play()
        // print: I'm playing with Mimi.
    }

    func testReadme2() {
        let context = DependencyResolver()
        context.register { Cat(name: "Mimi") as Animal }
    }

    func testReadme3() {
        context.register(variant: "long_date") { () -> DateFormatter in
            let formatter = DateFormatter()
            formatter.dateFormat = "MMM yyyy"
            return formatter
        }

        context.register(variant: "short_date") { () -> DateFormatter in
            let formatter = DateFormatter()
            formatter.dateFormat = "dd/MM/yyyy"
            return formatter
        }

        class Example {
            // This will resolve expected date formatter
            @Resolve(variant: "long_date") var formatter: DateFormatter
        }
    }

    func testReadme4() {
        let dateFormatter: DateFormatter = {
            let formatter = DateFormatter()
            formatter.dateFormat = "MMM yyyy"
            return formatter
        }()

        context.register(variant: "long_date") { dateFormatter }
    }

    func testReadme5() {
        class Example {}
        class Example2 {}
        class Example3 {}

        // persistent life time will always resolve the same object
        context.persistent { Example() }

        // transient life time will resolve the same object provided there is a strong reference to it elsewhere
        context.transient { Example2() }

        // ephemeral life time will always resolve a new object
        context.ephemeral { Example3() }
    }

    func testReadme6() {
        var dateFormatter: DateFormatter = {
            let formatter = DateFormatter()
            formatter.dateFormat = "MMM yyyy"
            return formatter
        }()

        context.register(variant: "long_date", resolver: { dateFormatter }, storer: { f in dateFormatter = f })
    }

    func testReadme7() {
        context.register { PetOwner() }
        context.transient(variant: "Mimi") { Cat(name: "Mimi") as Animal }

        let petOwner: PetOwner = context.resolve()
        petOwner.play()
        // print: I'm playing with Mimi.

        petOwner.pet = Cat(name: "Franky")
        petOwner.play()
        // print: I'm playing with Franky.
    }
}

protocol Animal: AnyObject {
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
