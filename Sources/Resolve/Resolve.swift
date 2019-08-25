//
//  File.swift
//  
//
//  Created by Nicholas Cross on 17/8/19.
//

import Foundation

@propertyWrapper
public struct Resolve<T> {
    private var register: DependencyRegister
    private var variant: String?

    public init(register: DependencyRegister, variant: String) {
        self.register = register
        self.variant = variant
        register.registerDependencies()
    }

    public init(register: DependencyRegister) {
        self.register = register
        self.variant = nil
        register.registerDependencies()
    }

    public init() {
        self.register = DefaultRegister()
        self.variant = nil
    }

    public init(variant: String) {
        self.register = DefaultRegister()
        self.variant = variant
    }

    public var wrappedValue:T {
        get {
            return self.register.container.resolve(variant: variant) as T
        }
        set {
            self.register.container.store(object: newValue, variant: variant)
        }
    }

    private struct DefaultRegister: DependencyRegister {
        var container: DependencyContainer = ResolutionContext.global.resolve()

        func registerDependencies() {
            // do nothing
        }
    }
}
