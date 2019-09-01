# Resolve

A swift package to support dependency resolution with property wrapper support for ease of use.

## Usage Example

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

## What can Resolve do?

### @Resolve property wrapper

Resolving registered dependencies is simple just create add the `@Resolve` property wrapper in front of your property.

```swift
@Resolve var pet: Animal
```
This will use the default `ResolutionContext` when resolving dependencies.

There can be only one default context; it can be registered as follows

```swift
let context = ResolutionContext()
context.makeDefault()
```

If using a default context is not appropriate for your use case you can include this as part of your property declaration

```swift
@Resolve(container: someContext) var pet: Animal
```

### Distributed registration

When registering a type conforming to `DependencyRegister` protocol the `registerDependencies` function will be called giving you an opportunity to register any further dependencies.

This allows you to easily distribute the registration of dependency through out your app rather than centralising in a single place.

```swift
let context = ResolutionContext()
context.makeDefault()
context.register { ExampleObject() }

final class ExampleObject: DependencyRegister {
    func registerDependencies(container: DependencyContainer) {
        container.register(variant: "Mimi") { Cat(name: "Mimi") as Animal }
        container.register { PetOwner() as Person }
    }
}

let petOwner: Person = context.resolve()
petOwner.play()
//print: I'm playing with Mimi.
```

There can be only a single registration for given type variant this allows the default registrations to be ignored which might be useful for testing purposes.  Earlier registration of mock/stub objects will take precedence allowing you to provide alternate implementation for testing purposes.

```swift
let context = ResolutionContext()
context.makeDefault()
container.register(variant: "Mimi") { Cat(name: "Betsy") as Animal }
context.register { ExampleObject() }

let petOwner: Person = context.resolve()
petOwner.play()
//print: I'm playing with Betsy.
```

If an alternate registration is truly required the old registration can be removed and a new one registered.

```swift
context.removeResolver(for: Person.self)
```

### Variant resolution

As already revealed in some of the above examples there can be multiple variants registered for a single type.

```swift
container.register(variant: "long_date") { () -> DateFormatter in
    let formatter = DateFormatter()
    formatter.dateFormat = "MMM yyyy"
    return formatter
}

container.register(variant: "short_date") { () -> DateFormatter in
    let formatter = DateFormatter()
    formatter.dateFormat = "dd/MM/yyyy"
    return formatter
}
```

```swift
// This will resolve expected date formatter
@Resolve(variant:"long_date") var formatter: DateFormatter
```

### No object lifetime management

Resolve does not explicitly manage the lifetime of any resolved objects this is left up to the developer.  The above date example would need to be modified in order to prevent a new date formatter being created everytime it was resolved.

```swift
let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "MMM yyyy"
    return formatter
}()

context.register(variant: "long_date") { dateFormatter }
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

The property can be set directly or via calling the store function on the `ResolutionContext`

```swift
self.formatter = someOtherFormatter
// OR
context.store(object: someOtherFormatter, variant: "long_date")
```
