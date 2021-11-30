
///
public final class HBTree<T: Equatable & Comparable> {
    public typealias Element = T
    typealias BNodeEntries = HBNodeEntry<T>.BNodeEntries
    typealias BNode = HBNodeEntry<T>
    ///
    final var _root: AnyHBNode<T>
    final var _maxNodes: Int
    ///
    public var count: Int { return _root.key }
    public var height: Int { return _root.height }
    ///
    public init(maxElementsPerNode: Int = 3) {
        _maxNodes = maxElementsPerNode
        _root = AnyHBNode<T>(BNode(children: BNodeEntries(), maxChildren: _maxNodes))
    }
    ///
    /// @inlinable
    public func find(position: Int) -> Element {
        return _root.find(position: position)
    }
    ///
    func setValue(element: Element, at position: Index) {
        _root.setValue(element: element, at: position)
    }
    ///
    public func append(_ element: Element) {
        self.insert(element, at: self.count)
    }
    ///
    public func insert(_ element: Element, at position: Int) {
        let splitRoot = _root.insert(element, at: position, current: 0)
        guard nil != splitRoot.0 else { return }
        _root = AnyHBNode<T>(HBNodeEntry(children: [(splitRoot.0!.key, splitRoot.0!), (splitRoot.1!.key, splitRoot.1!)],
                                         maxChildren: _maxNodes))
    }
    ///
    @discardableResult
    public func remove(at position: Int) -> Element {
        let ret = _root.remove(at: position, current: 0)
        if _root.count == 1 {
            if nil != _root.node!.children.first?.1.node {
                _root = _root.node!.children.first!.1
            }
        }
        return ret
    }
    ///
    func _visit(_ bne: AnyHBNode<T>, _ block: (Element)->Void) {
        if let inner = bne.node {
            inner.children.forEach { _visit($0.1, block) }
        } else if let leaf = bne.leaf {
            leaf.values.forEach { block($0) }
        }
    }
    public func visit(_ block: (Element)->Void) {
        _visit(_root, block)
    }
    ///
    func _visitNodes(_ bne: AnyHBNode<T>, _ block: (AnyHBNode<T>)->Void) {
        block(bne)
        if let inner = bne.node {
            inner.children.forEach { _visitNodes($0.1, block) }
        }
    }
    ///
    public func visitNodes(_ block: (AnyHBNode<T>)->Void) {
        _visitNodes(_root, block)
    }
}
///
extension HBTree : MutableCollection {
    public typealias Index = Int

    public func index(after i: Int) -> Int {
        i + 1
    }
    
    public var startIndex: Int { 0 }
    
    public var endIndex: Int { count }
    ///
    public subscript(position: Int) -> Element {
        set(newValue) {
            setValue(element: newValue, at: position)
        }
        get {
            return find(position: position)
        }
    }
    ///
    public func append(_ elements: [Element]) {
        for e in elements {
            append(e)
        }
    }
}
///
extension HBTree : RandomAccessCollection {
}
