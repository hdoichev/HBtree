import XCTest
@testable import HBtree

typealias TestBTree = HBTree<Int>

final class HBtreeTests: XCTestCase {
    func testAppend() throws {
        let bt = TestBTree(maxElementsPerNode: 32)
        bt.append(1)
        XCTAssertEqual(bt[0], 1, "Value should be 1")
    }
    ///
    func testAppendMany() {
        let bt = TestBTree(maxElementsPerNode: 32)
        for i in 0 ..< 1_000 {
            bt.append(i)
        }
        for i in 0 ..< 1_000 {
            XCTAssertEqual(bt[i], i, "Value should be \(i)")
        }
    }
    ///
    func testModify() {
        let bt = TestBTree(maxElementsPerNode: 32)
        for i in 0 ..< 1_000 {
            bt.append(i)
        }
        for i in 0 ..< 1_000 {
            bt[i] *= 2
        }
        for i in 0 ..< 1_000 {
            XCTAssertEqual(bt[i], i * 2, "Value should be \(i * 2)")
        }
    }
    ///
    func testSort() {
        var bt = TestBTree(maxElementsPerNode: 32)
        var a = [1, 5, 2, 9, 6, 8, 7, 4, 3]
        bt.append(a)
        bt.sort()
        a.sort()
        for i in 0 ..< a.count {
            XCTAssertEqual(bt[i], a[i], "Value should be \(a[i])")
        }
        bt.visit { print(" \($0) ", terminator: "") }
        print()
        print(a)
    }
    ///
    func testInsert() {
        let bt = TestBTree(maxElementsPerNode: 32)
        for i in 0 ..< 1_000 {
            bt.append(i)
        }
        for i in 0 ..< 1_000 {
            bt.insert(i, at: 1 + (i * 2))
        }
        for i in stride(from: 0, to: bt.count - 1, by: 2) {
            XCTAssertEqual(bt[i], bt[i+1])
        }
        bt.visit { print(" \($0) ", terminator: "") }
        print()
    }
    ///
    func testInsert_Performance() {
        let bt = TestBTree(maxElementsPerNode: 32)
        for i in 0 ..< 100_000 {
            bt.append(i)
        }
        measure {
            for i in 0 ..< 100_000 {
                bt.insert(i, at: 1 + (i * 2))
            }
        }
        print(bt)
    }

}
