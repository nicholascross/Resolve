//
//  File.swift
//  
//
//  Created by Nicholas Cross on 17/8/19.
//

import Foundation

@propertyWrapper
public struct Resolve<T> {
    private var container: DependencyContainer
    private var variant: String?

    public init(container: DependencyContainer, variant: String) {
        self.container = container
        self.variant = variant
    }

    public init(container: DependencyContainer) {
        self.container = container
        self.variant = nil
    }

    public init() {
        self.container = ResolutionContext.global.resolve()
        self.variant = nil
    }

    public init(variant: String) {
        self.container = ResolutionContext.global.resolve()
        self.variant = variant
    }

    public var wrappedValue:T {
        get {
            return self.container.resolve(variant: variant) as T
        }
        set {
            self.container.store(object: newValue, variant: variant)
        }
    }
}
