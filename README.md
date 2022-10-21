# Resolve

A swift package to support dependency resolution with property wrapper support for ease of use.

## Usage Example

This is how you would do something similar to [Swinject basic usage](https://github.com/Swinject/Swinject#basic-usage)

```swift
let context = DependencyResolver()

context.register { Cat(name: "Mimi") as Animal }
context.register { PetOwner() as Person }
let petOwner: Person = context.resolve()
petOwner.play()
// print: I'm playing with Mimi.
```

Where the types are defined as follows.

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
    @Resolve var pet: Animal

    func play() {
        let name = pet.name ?? "someone"
        print("I'm playing with \(name).")
    }
}
```

## What can Resolve do?

### @Resolve property wrapper

Resolving registered dependencies is simple just add the `@Resolve` property wrapper in front of your property.

```swift
@Resolve var pet: Animal
```

This will find the first  `DependencyResolver` that registered this type to resolve the value.

If using a single `DependencyResolver` per type variant is not appropriate for your use case you can include this as part of your property declaration.

```swift
@Resolve(container: someContext) var pet: Animal
```

### Type registration

Before the above will work there must be a defined way to resolve the object that will be returned.  This is done by registering a closure that returns the type to be resolved.

Note the casting to `Animal`, this is allows registration of a new `Cat` instance any time we resolve the `Animal` type.  

```swift
let context = DependencyResolver()
context.register { Cat(name: "Mimi") as Animal }
```

There can be only a single registration for a given type variant this allows the default registrations to be ignored which might be useful for testing purposes.  Earlier registration of mock/stub objects will take precedence allowing you to provide alternate implementation for testing purposes.

If an alternate registration is truly required the old registration can be removed and a new one registered.

```swift
context.removeResolver(for: Person.self)
```

### Variant resolution

There can be multiple variants registered for a single type.

```swift
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
```

```swift
// This will resolve expected date formatter
@Resolve(variant:"long_date") var formatter: DateFormatter
```

### Object lifetime management

Resolve does not require explicit management of the lifetime of any resolved objects.  The above date example would need to be modified in order to prevent a new date formatter being created everytime it was resolved.

```swift
let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "MMM yyyy"
    return formatter
}()

context.register(variant: "long_date") { dateFormatter }
```

Objects lifetime can be specified explictly using the convenience functions `persistent`, `transient`, `ephemeral`.

```swift
// persistent life time will always resolve the same object
context.persistent { Example() }

// transient life time will resolve the same object provided there is a strong reference to it elsewhere
context.transient { Example2() }

// ephemeral life time will always resolve a new object
context.ephemeral { Example3() }
```

### Optional property storage

Assigning to the formatter property would currently be a no-op but backing storage can be updated by implementing a storer closure.

```swift
var dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "MMM yyyy"
    return formatter
}()

context.register(variant: "long_date", resolver: { dateFormatter }, storer: { f in dateFormatter = f })
```

The above registration will allow the following to property to be used as a setter as well.

```swift
// This will resolve expected date formatter
@Resolve(variant:"long_date") var formatter: DateFormatter
```

The property can be set directly or via calling the store function on the `DependencyResolver`.

```swift
self.formatter = someOtherFormatter
// OR
context.store(object: someOtherFormatter, variant: "long_date")
```

Type variants registered with the `persistent` or `transient` functions may have thier stored values replaced.

```swift
let petOwner = context.register { PetOwner() }
let mimi = context.transient(variant: "Mimi") { Cat(name: "Mimi") as Animal }

petOwner.play()
// print: I'm playing with Mimi.

petOwner.pet = Cat(name: "Franky")
petOwner.play()
// print: I'm playing with Franky.
```

### Hierarchical registration

When registering a type conforming to `DependencyRegister` protocol the `registerDependencies` function will be called giving you an opportunity to register any further dependencies.

This allows the distribution of dependency registration through out the application in hierarchical manner, as one register may register another whilst in turn registering its own dependencies.

```swift
final class ExampleRegister: DependencyRegister {
    func registerDependencies(container: Resolver) {
        container.register(variant: "Mimi") { Cat(name: "Mimi") as Animal }
        container.register { PetOwner() as Person }
    }
}

let context = DependencyResolver()
context.register { ExampleObject() }

let petOwner: Person = context.resolve()
petOwner.play()
// print: I'm playing with Mimi.
```
