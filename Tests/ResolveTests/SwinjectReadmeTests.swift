@testable import Resolve
import XCTest

final class SwinjectReadmeTests: XCTestCase {
    var resolver: DependencyResolver!

    override func setUp() {
        resolver = DependencyResolver()
        DependencyResolver.clearResolvers()
    }

    func testReadme() {
        let resolver = DependencyResolver()

        resolver.register(variant: "Mimi") { Cat(name: "Mimi") as Animal }
        resolver.register { PetOwner() as Person }
        let petOwner: Person = resolver.resolve()
        petOwner.play()
        // print: I'm playing with Mimi.
    }

    func testReadme2() {
        let resolver = DependencyResolver()
        resolver.register { Cat(name: "Mimi") as Animal }
    }

    func testReadme3() {
        resolver.register(variant: "long_date") { () -> DateFormatter in
            let formatter = DateFormatter()
            formatter.dateFormat = "MMM yyyy"
            return formatter
        }

        resolver.register(variant: "short_date") { () -> DateFormatter in
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

        resolver.register(variant: "long_date") { dateFormatter }
    }

    func testReadme5() {
        class Example {}
        class Example2 {}
        class Example3 {}

        // persistent life time will always resolve the same object
        resolver.persistent { Example() }

        // transient life time will resolve the same object provided there is a strong reference to it elsewhere
        resolver.transient { Example2() }

        // ephemeral life time will always resolve a new object
        resolver.ephemeral { Example3() }
    }

    func testReadme6() {
        var dateFormatter: DateFormatter = {
            let formatter = DateFormatter()
            formatter.dateFormat = "MMM yyyy"
            return formatter
        }()

        resolver.register(variant: "long_date", resolver: { dateFormatter }, storer: { f in dateFormatter = f })
    }

    func testReadme7() {
        resolver.register { PetOwner() }
        resolver.transient(variant: "Mimi") { Cat(name: "Mimi") as Animal }

        let petOwner: PetOwner = resolver.resolve()
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
