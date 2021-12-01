
///
public final class HBTree<T: Equatable & Comparable> {
    public typealias Element = T
    typealias BNodeEntries = HBNodeEntry<T>.BNodeEntries
    typealias BNode = HBNodeEntry<T>
    ///
    final var _root: AnyHBNode<T>
    final var _maxNodes: Int
    ///
    public final var count: Int { return _root.key }
    public final var height: Int { return _root.height }
    ///
    public init(maxElementsPerNode: Int = 3) {
        _maxNodes = maxElementsPerNode
        _root = AnyHBNode<T>(BNode(children: BNodeEntries(), maxChildren: _maxNodes))
    }
    ///
    /// @inlinable
    final func find(position: Int) -> Element {
        return _root.find(position: position)
    }
    ///
    final func setValue(element: Element, at position: Index) {
        _root.setValue(element: element, at: position)
    }
    ///
    final func _visit(_ bne: AnyHBNode<T>, _ block: (Element)->Void) {
        if let inner = bne.node {
            inner.children.forEach { _visit($0.1, block) }
        } else if let leaf = bne.leaf {
            leaf.values.forEach { block($0) }
        }
    }
    ///
    final func _visitNodes(_ bne: AnyHBNode<T>, _ block: (AnyHBNode<T>)->Void) {
        block(bne)
        if let inner = bne.node {
            inner.children.forEach { _visitNodes($0.1, block) }
        }
    }
}
/// Visitor
extension HBTree {
    ///
    public final func visit(_ block: (Element)->Void) {
        _visit(_root, block)
    }
    ///
    public final func visitNodes(_ block: (AnyHBNode<T>)->Void) {
        _visitNodes(_root, block)
    }
}
///
extension HBTree : MutableCollection, RandomAccessCollection {
    public typealias Index = Int

    public final func index(after i: Int) -> Int {
        i + 1
    }
    
    public final var startIndex: Int { 0 }
    
    public final var endIndex: Int { count }
    ///
    public final subscript(position: Int) -> Element {
        set(newValue) {
            setValue(element: newValue, at: position)
        }
        get {
            return find(position: position)
        }
    }
    ///
    public final func append(_ elements: [Element]) {
        for e in elements {
            append(e)
        }
    }
    ///
    public final func append(_ element: Element) {
        self.insert(element, at: self.count)
    }
    ///
    public final func insert(_ element: Element, at position: Int) {
        let splitRoot = _root.insert(element, at: position, current: 0)
        guard nil != splitRoot.0 else { return }
        _root = AnyHBNode<T>(HBNodeEntry(children: [(splitRoot.0!.key, splitRoot.0!), (splitRoot.1!.key, splitRoot.1!)],
                                         maxChildren: _maxNodes))
    }
    ///
    @discardableResult
    public final func remove(at position: Int) -> Element {
        let ret = _root.remove(at: position, current: 0)
        if _root.count == 1 {
            if nil != _root.node!.children.first?.1.node {
                _root = _root.node!.children.first!.1
            }
        }
        return ret
    }
}
