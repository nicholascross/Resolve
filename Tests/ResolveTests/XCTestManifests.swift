import XCTest

#if !canImport(ObjectiveC)
public func allTests() -> [XCTestCaseEntry] {
    return [
        SwinjectReadmeTests.allTests,
        StorageTests.allTests,
        ResolveTests.allTests
    ]
}
#endif
