import Foundation

class RecursiveLock {
    private let lock: NSRecursiveLock = .init()

    func sync<Result>(_ operation: () -> Result) -> Result {
        lock.lock()
        defer { lock.unlock() }
        return operation()
    }
}

let creationLock: RecursiveLock = .init()
