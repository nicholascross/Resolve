# Resolve

A swift package to support dependency resolution with property wrapper support for ease of use.

__This is an experimental project it might not be maintained in the future, feel free to use/reference it in your own implementation__  👍

## Examples

This is how you would do something similar to [Swinject basic usage](https://github.com/Swinject/Swinject#basic-usage)

```swift
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

let context = ResolutionContext()
context.makeDefault()

context.register(variant: "Mimi") { Cat(name: "Mimi") as Animal }
context.register { PetOwner() as Person }
let petOwner: Person = context.resolve()
petOwner.play()
//print: I'm playing with Mimi.
```
