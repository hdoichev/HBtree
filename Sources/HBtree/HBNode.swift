//
//  HBNode.swift
//  
//
//  Created by Hristo Doichev on 11/28/21.
//

import Foundation

//public protocol HBNodeProtocol {
//    associatedtype Element
//    var height: Int { get set }
//    var count: Int { get } // The count of children (values) contained in the node
//    var key: Int { get }
//    func find(position: Int, current key: Int) -> Element
//    func setValue(element: Element, at position: Int)
//    func insert(_ element: Element, at position: Int, current key: Int) -> (/*left*/HBNodeProtocol?, /*right*/HBNodeProtocol?)
//    //    func directInsert(_ element: Element, at position: Int) { fatalError("Must be implemented in derived class") }
//    func append(_ element: Element) -> (/*left*/HBNodeProtocol?, /*right*/HBNodeProtocol?)
//    func remove(at position: Int, current key: Int) -> Element
//}
//public protocol HBNodeAccessor {
//    associatedtype Element
//    var node: HBNodeProtocol { get }
//}

public struct AnyHBNode<T> {
    typealias Element = T
    let node: HBNodeEntry<T>?
    let leaf: HBNodeLeaf<T>?
    
    public var height: Int {
        if nil != node { return node!.height }
        else { return leaf!.height}
    }
    public var key: Int {
        if nil != node { return node!.key }
        else { return leaf!.key}
    }
    public var count: Int {
        if nil != node { return node!.count }
        else { return leaf!.count}
    }
    init(_ node: HBNodeEntry<T>) {
        self.node = node
        self.leaf = nil
    }
    init(_ leaf: HBNodeLeaf<T>) {
        self.node = nil
        self.leaf = leaf
    }
    func append(_ element: T) -> (/*left*/AnyHBNode<T>?, /*right*/AnyHBNode<T>?) {
        if nil != node { return node!.append(element) }
        else { return leaf!.append(element) }
    }
    func insert(_ element: Element, at position: Int, current key: Int) -> (AnyHBNode<T>?, AnyHBNode<T>?) {
        if nil != node { return node!.insert(element, at: position, current: key) }
        else { return leaf!.insert(element, at: position, current: key) }
    }
    func find(position: Int, current key: Int) -> Element {
        if nil != node { return node!.find(position: position, current: key) }
        else { return leaf!.find(position: position, current: key) }
    }
    func find(position: Int) -> Element {
        if nil != node { return node!.find(position: position) }
        else { return leaf!.find(position: position, current: 0) }
    }
    func setValue(element: Element, at position: Int) {
        if nil != node { return node!.setValue(element: element, at: position) }
        else { return leaf!.setValue(element: element, at: position) }
    }
    func remove(at position: Int, current key: Int) -> Element {
        if nil != node { return node!.remove(at: position, current: key) }
        else { return leaf!.remove(at: position, current: key) }
    }
}

