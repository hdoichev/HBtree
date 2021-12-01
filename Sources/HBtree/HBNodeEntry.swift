//
//  File.swift
//  
//
//  Created by Hristo Doichev on 11/28/21.
//

import Foundation

///
final internal class HBNodeEntry<T> {
    typealias Element = T
    typealias BNodeEntries = ContiguousArray<(Int,AnyHBNode<T>)>

    final var height: Int = 1
    final var children: BNodeEntries
    final let maxChildren: Int
    final var _key: Int = 0
    final var count: Int { children.count }
    final var key: Int { _key = children.reduce(0) { $0 + $1.0 }; return _key }
    //
    init(children: BNodeEntries, maxChildren: Int) {
        self.children = children
        self.maxChildren = maxChildren
        self.height = 2
        if self.children.count > 0 {
            self.updateHeight()
        }
    }
    init(child: HBNodeEntry, maxChildren: Int) {
        self.children = BNodeEntries()
        self.maxChildren = maxChildren

        children.append((_key, AnyHBNode<T>(child)))
        _key = key

        self.updateHeight()
    }
    @discardableResult
    final func updateHeight() -> Int {
        self.height = children.reduce(1, { r, bn in Swift.max(r, bn.1.height + 1) })
        return self.height
    }
    ///
    final func insertSplitNodes(_ newNodes:(/*left*/AnyHBNode<T>?, /*right*/AnyHBNode<T>?), at position: Int) -> (/*left*/AnyHBNode<T>?, /*right*/AnyHBNode<T>?){
        guard nil != newNodes.0 else { return (nil, nil) }
        let childrenCount = children.count
        children[position] = (newNodes.0!.key,  newNodes.0!)
        if childrenCount + 1 <= maxChildren {
            children.insert((newNodes.1!.key, newNodes.1!), at: position + 1)
        } else {
            let rightInsertPos = position + 1
            var halfPosition = maxChildren/2
            if rightInsertPos > halfPosition { halfPosition += 1 }
            else if rightInsertPos < halfPosition { halfPosition -= 1 }
            let newLeft = HBNodeEntry(children: BNodeEntries(children[0..<halfPosition]), maxChildren: maxChildren)
            let newRight = HBNodeEntry(children: BNodeEntries(children[halfPosition..<maxChildren]), maxChildren: maxChildren)
            if rightInsertPos <= halfPosition {
                newLeft.children.insert((newNodes.1!.key, newNodes.1!), at: rightInsertPos)
            } else {
                newRight.children.insert((newNodes.1!.key, newNodes.1!), at: rightInsertPos - halfPosition)
            }
            return (AnyHBNode<T>(newLeft), AnyHBNode<T>(newRight))
        }
        return (nil, nil)
    }
    ///
    final func append(_ element: Element) -> (/*left*/AnyHBNode<T>?, /*right*/AnyHBNode<T>?) {
        _key += 1
        if let bn = children.last?.1  {
            let newNodes = bn.append(element)
            if nil != newNodes.0 {
                return insertSplitNodes(newNodes, at: children.count - 1)
            } else {
                children[children.count - 1].0 += 1
            }
        } else {
            children.append((1, AnyHBNode<T>(HBNodeLeaf(element, maxValues: maxChildren))))
        }
        return (nil, nil)
    }
    ///
    final func insert(_ element: Element, at position: Int, current key: Int) -> (AnyHBNode<T>?, AnyHBNode<T>?) {
        var currentKey = key
        let childrenCount = children.count
        for i in 0..<childrenCount {
            let childKey = children[i].0
            if position < currentKey + childKey {
                let newNodes = children[i].1.insert(element, at: position, current: currentKey)
                _key += 1
                if nil != newNodes.0 {
                    return insertSplitNodes(newNodes, at: i)
                } else {
                    children[i].0 += 1
                }
                return (nil, nil)
            }
            currentKey += childKey
        }
        /// position is greater than all contained positions.
        return append(element)
    }
    ///
    @inlinable
    final func find(position: Int, current key: Int) -> Element {
        if position < key + (_key / 2) {
            var currentKeyLeft = key
            for n in children {
                if position < currentKeyLeft + n.0 {
                    return n.1.find(position: position, current: currentKeyLeft)
                }
                currentKeyLeft += n.0
            }
        } else {
            var currentKeyRight = key + _key
            for i in (0 ..< children.count).reversed() {
                currentKeyRight -= children[i].0
                if position >= currentKeyRight {
                    return children[i].1.find(position: position, current: currentKeyRight)
                }
            }
        }
        fatalError("Invalid position")
    }
    @inlinable
    final func find(position: Int) -> Element {
        return find(position: position, current: 0)
    }
    ///
    final func setValue(element: Element, at position: Int) {
        var currentKey = 0
        var currentNode = self
        while true {
            var searching = false
            for n in currentNode.children {
                if position < currentKey + n.0 {
                    if let inner = n.1.node {
                        currentNode = inner
                    } else if let leaf = n.1.leaf {
                        leaf.setValue(element: element, at: position - currentKey)
                        return
                    } else {
                        fatalError("What is this???")
                    }
                    searching = true
                    break
                }
                currentKey += n.0
            }
            if !searching {
                fatalError("Invalid position")
            }
        }
    }
    ///
    final func shiftFromLeft(at position: Int) -> Bool {
        guard position > 1 else { return false }
        if let lnode = children[position-1].1.node,
           let rnode = children[position].1.node {
            if lnode.children.count <= maxChildren/2 {
                if !shiftFromLeft(at: position - 1) { return false }
            }
            rnode.children.insert(lnode.children.removeLast(), at: 0)
            children[position-1].0 = lnode.key
            children[position].0 = rnode.key
        } else if let lnode = children[position-1].1.leaf,
                  let rnode = children[position].1.leaf {
            if lnode.values.count <= maxChildren/2 {
                if !shiftFromLeft(at: position - 1) { return false }
            }
            rnode.values.insert(lnode.values.removeLast(), at: 0)
            children[position-1].0 = lnode.key
            children[position].0 = rnode.key
        } else {
            fatalError("Node mismatch during \(#function)")
        }
        return true
    }
    ///
    final func shiftFromRight(at position: Int) -> Bool {
        guard position < children.count - 1 else { return false }
        if let lnode = children[position].1.node,
           let rnode = children[position+1].1.node {
            if rnode.children.count <= maxChildren/2 {
                if !shiftFromRight(at: position + 1) { return false }
            }
            lnode.children.append(rnode.children.removeFirst())
            children[position].0 = lnode.key
            children[position+1].0 = rnode.key
        } else if let lnode = children[position].1.leaf,
                  let rnode = children[position+1].1.leaf {
            if rnode.values.count <= maxChildren/2 {
                if !shiftFromRight(at: position + 1) { return false }
            }
            lnode.values.append(rnode.values.removeFirst())
            children[position].0 = lnode.key
            children[position+1].0 = rnode.key
        } else {
            fatalError("Node mismatch during \(#function)")
        }
        return true
    }
    ///
    @discardableResult
    final func shiftLeft(itemsCount: Int, at position: Int) -> Int {
        guard position > 1 else { return 0 }
        var availableOnLeft = (self.maxChildren - children[position-1].1.count)
        let toRelocate = itemsCount > availableOnLeft ? itemsCount - availableOnLeft: 0
        if toRelocate > 0 {
            availableOnLeft += shiftLeft(itemsCount: toRelocate, at: position - 1)
        }
        let toMove = (itemsCount > availableOnLeft) ? availableOnLeft: itemsCount
        
        if let lnode = children[position-1].1.node,
           let snode = children[position].1.node {
            lnode.children.append(contentsOf: snode.children[0..<toMove])
            snode.children.removeSubrange((0..<toMove))
            children[position-1].0 = lnode.key
            children[position].0 = snode.key
        } else if let lnode = children[position-1].1.leaf,
                  let snode = children[position].1.leaf {
            lnode.values.append(contentsOf: snode.values[0..<toMove])
            snode.values.removeSubrange((0..<toMove))
            children[position-1].0 = lnode.key
            children[position].0 = snode.key
        } else {
            fatalError("Node mismatch during \(#function)")
        }
        return toMove
    }
    ///
    @discardableResult
    final func shiftRight(itemsCount: Int, at position: Int) -> Int {
        guard position < children.count - 1 else { return 0 }
        var availableOnRight = (self.maxChildren - children[position+1].1.count)
        let toRelocate = itemsCount > availableOnRight ? itemsCount - availableOnRight: 0
        if toRelocate > 0 {
            availableOnRight += shiftRight(itemsCount: toRelocate, at: position + 1)
        }
        let toMove = (itemsCount > availableOnRight) ? availableOnRight: itemsCount
        
        if let rnode = children[position+1].1.node,
           let snode = children[position].1.node {
            let startPos = snode.children.count - toMove
            rnode.children.insert(contentsOf: snode.children[startPos..<snode.children.count], at: 0)
            snode.children.removeSubrange((startPos..<snode.children.count))
            children[position+1].0 = rnode.key
            children[position].0 = snode.key
        } else if let rnode = children[position+1].1.leaf,
                  let snode = children[position].1.leaf {
            let startPos = snode.values.count - toMove
            rnode.values.insert(contentsOf: snode.values[startPos..<snode.values.count], at: 0)
            snode.values.removeSubrange((startPos..<snode.values.count))
            children[position+1].0 = rnode.key
            children[position].0 = snode.key
        } else {
            fatalError("Node mismatch during \(#function)")
        }
        return toMove
    }
    ///
    final func fillOrRedistributeUsingNeighbours(at position: Int) -> Bool {
        var freeLeft = 0
        var freeRight = 0
        if position > 0 {
            freeLeft = maxChildren - children[position-1].1.count
            if children[position-1].1.count > maxChildren/2 {
                shiftFromLeft(at: position)
                return true
            }
        }
        if position + 1 < children.count {
            freeRight = maxChildren - children[position+1].1.count
            if children[position+1].1.count > maxChildren/2 {
                shiftFromRight(at: position)
                return true
            }
        }
        let redistributeCount = children[position].1.count
        if freeLeft + freeRight > redistributeCount {
            let leftCount = Swift.min(freeLeft, redistributeCount)
            if leftCount > 0 {
                shiftLeft(itemsCount: leftCount, at: position)
            }
            let rightCount = Swift.min(freeRight, redistributeCount - leftCount)
            if rightCount > 0 {
                shiftRight(itemsCount: rightCount, at: position)
            }
            return children[position].1.count == 0
        }
        return false
    }
    ///
    final func remove(at position: Int, current key: Int) -> Element {
        var currentKey = key
        
        for i in 0..<children.count {
            let curNodeKey = children[i].0
            if position < currentKey + curNodeKey {
                let curHeight = children[i].1.height
                let element = children[i].1.remove(at: position, current: currentKey)
                children[i].0 -= 1
                let halfFull = maxChildren / 2
                if children[i].1.count < halfFull {
                    if fillOrRedistributeUsingNeighbours(at: i) {
                        if children[i].1.count == 0 {
                            children.remove(at: i)
                        }
                    }
                }
                if curHeight == self.height {
                    updateHeight()
                }
                _key -= 1
                return element
            }
            currentKey += curNodeKey
        }
        fatalError("Invaid position")
    }
}

///
extension HBNodeEntry: CustomStringConvertible {
    var description: String {
        "key: \(key):\(_key), height: \(height),  children: \(children.count ?? 0)"
        //        """
        //        key: \(key)
        //        height: \(height)
        //        children: \(children?.count ?? 0)
        //        value: \(value)
        //        """
    }
}
