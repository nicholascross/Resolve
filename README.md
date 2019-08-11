# Resolve

A swift 5.1 package enabling decentralised dependency resolution through protocol conformance, with property wrapper support for ease of use.

## Features

- Supports dependency resolution without prior registration of the type
- Supports resolution of the same object based on storage protocol implemented by resolved type
- Supports both reference and value types
- Supports resolution of multiple variants of the same type differentiated by key
- Supports registration of interface types to allow for resolving dependencies where the implementing class is not directly available
- Supports resolution of interdependant classes with cyclic dependencies
- Use `@Resolve` property wrappers for resolving concrete types 
- Use `@ResolveVariant` property wrappers for resolving concrete type variants 
- Use `@ResolveInterface` property wrappers for resolving a concrete type from a registered interface type

## Trade-offs and limitations

- Registrationless resolution requires visibility of the exact type being resolved
- Resolving via an interface works around the need for visibility of the type being resolved at the expense of requiring registration, this registration is not enforced at compile time, meaning it can fail at runtime if the registration was ommitted
- Coupling between dependency injection framework and injected types through protocol conformance

## Pending development

- TODO: Support variant registration and resolution for interfaces
- TODO: Use `@ResolveInterfaceVariant` property wrappers for resolving a concrete type variant from a registered interface type

## Examples

This is how you would do something similar to [Swinject basic usage](https://github.com/Swinject/Swinject#basic-usage)

```
import Foundation
import Resolve

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

let _ = ExampleContainer.resolve()
let petOwner: Person = PetOwner.resolve()
petOwner.play()
//print: I'm playing with Mimi.
```

