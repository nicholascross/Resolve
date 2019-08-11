import XCTest

#if !canImport(ObjectiveC)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(ResolveTests.allTests),
        testCase(ResolveInterfaceTests.allTests),
    ]
}
#endif
