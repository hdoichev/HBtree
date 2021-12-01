//
//  File.swift
//  
//
//  Created by Hristo Doichev on 11/28/21.
//

import Foundation

///
final internal class HBNodeLeaf<T> {
    typealias Element = T
    typealias Values = ContiguousArray<T>
    final var height: Int = 1
    final var values = Values()
    final let maxValues: Int
    ///
    final var count: Int { values.count }
    final var key: Int { values.count }
    ///
    init(_ element: Element, maxValues: Int) {
        values.append(element)
        self.maxValues = maxValues
    }
    ///
    init(_ values: Values, maxValues: Int) {
        self.values = values
        self.maxValues = maxValues
    }
    ///
    final func directInsert(_ element: Element, at position: Int) {
        self.values.insert(element, at: position)
    }
    @inlinable
    final func find(position: Int, current key: Int) -> Element {
        let index = position - key
        guard index >= 0 && index < values.count else { fatalError("Position out of range") }
        return values[position - key]
    }
    ///
    final func remove(at position: Int, current key: Int) -> Element {
        let valuePosition = position - key
        guard valuePosition >= 0 else { fatalError("Invalid position/key combo") }
        guard valuePosition < self.values.count else { fatalError("Invalid insert position for leaf node: \(valuePosition)") }
        return values.remove(at: valuePosition)
    }
    ///
    final func append(_ element: Element) -> (/*left*/AnyHBNode<T>?, /*right*/AnyHBNode<T>?) {
        if values.count < maxValues {
            values.append(element)
        } else {
            let halfPosition = 1 + (self.values.count / 2)
            let newLeft = HBNodeLeaf(Values(self.values[0..<halfPosition]), maxValues: maxValues)
            let newRight = HBNodeLeaf(Values(self.values[halfPosition..<self.values.count]), maxValues: maxValues)
            _=newRight.append(element)
            return (AnyHBNode<T>(newLeft), AnyHBNode<T>(newRight))
        }
        return (nil, nil)
    }
    ///
    final func insert(_ element: T, at position: Int, current key: Int) -> (AnyHBNode<T>?, AnyHBNode<T>?) {
        let valuePosition = position - key
        guard valuePosition >= 0 else { fatalError("Invalid position/key combo") }
        guard valuePosition <= values.count else { fatalError("Invalid insert position for leaf node: \(valuePosition)") }
        if values.count < maxValues {
            values.insert(element, at: valuePosition)
        } else {
            var halfPosition = maxValues/2
            if valuePosition > halfPosition { halfPosition += 1 }
            else if valuePosition < halfPosition { halfPosition -= 1 }
            let newLeft = HBNodeLeaf(Values(values[0..<halfPosition]), maxValues: maxValues)
            let newRight = HBNodeLeaf(Values(values[halfPosition..<maxValues]), maxValues: maxValues)
            if valuePosition <= halfPosition {
                newLeft.directInsert(element, at: valuePosition)
            } else {
                newRight.directInsert(element, at: valuePosition - halfPosition)
            }
            return (AnyHBNode<T>(newLeft), AnyHBNode<T>(newRight))
        }
        return (nil, nil)
    }
    ///
    final func setValue(element: Element, at position: Int) {
        guard position >= 0 && position < values.count else { fatalError("Position out of range") }
        values[position] = element
    }
}
///
extension HBNodeLeaf: CustomStringConvertible {
    var description: String {
        "count: \(values.count), values: \(values)"
    }
}
