//
//  HBNode.swift
//  
//
//  Created by Hristo Doichev on 11/28/21.
//

import Foundation

///
public class HBNode<T> {
    typealias Element = T
    public var height: Int = 1
    var count: Int { 0 } // The count of children (values) contained in the node
    var key: Int { 1 }
    func setValue(element: Element, at position: Int) { fatalError("Must be implemented in derived class") }
    func insert(_ element: Element, at position: Int, current key: Int) -> (/*left*/HBNode<T>?, /*right*/HBNode<T>?) { fatalError("Must be implemented in derived class") }
    func directInsert(_ element: Element, at position: Int) { fatalError("Must be implemented in derived class") }
    func append(_ element: Element) -> (/*left*/HBNode<T>?, /*right*/HBNode<T>?) { return (nil, nil) }
    func remove(at position: Int, current key: Int) -> Element { fatalError("Must be implemented in derived class") }
}
