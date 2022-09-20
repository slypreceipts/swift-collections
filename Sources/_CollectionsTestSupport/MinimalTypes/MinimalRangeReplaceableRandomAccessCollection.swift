//===----------------------------------------------------------------------===//
//
// This source file is part of the Swift.org open source project
//
// Copyright (c) 2014 - 2021 Apple Inc. and the Swift project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
// See https://swift.org/CONTRIBUTORS.txt for the list of Swift project authors
//
//===----------------------------------------------------------------------===//

// Loosely adapted from https://github.com/apple/swift/tree/main/stdlib/private/StdlibCollectionUnittest

/// A minimal implementation of `RandomAccessCollection & RangeReplaceableCollection` with extra checks.
struct MinimalRangeReplaceableRandomAccessCollection<Element> {
  internal var _core: _MinimalCollectionCore<Element>

  let timesMakeIteratorCalled = ResettableValue(0)
  let timesUnderestimatedCountCalled = ResettableValue(0)
  let timesRangeChecksCalled = ResettableValue(0)
  let timesIndexNavigationCalled = ResettableValue(0)
  let timesSubscriptGetterCalled = ResettableValue(0)
  let timesSubscriptSetterCalled = ResettableValue(0)
  let timesRangeSubscriptGetterCalled = ResettableValue(0)
  let timesRangeSubscriptSetterCalled = ResettableValue(0)
  let timesSwapCalled = ResettableValue(0)
  let timesPartitionCalled = ResettableValue(0)

  init<S: Sequence>(
    _ elements: S,
    context: TestContext = TestContext.current,
    underestimatedCount: UnderestimatedCountBehavior = .value(0)
  ) where S.Element == Element {
    self._core = _MinimalCollectionCore(context: context, elements: elements, underestimatedCount: underestimatedCount)
  }

  var _context: TestContext {
    _core.context
  }
}

extension MinimalRangeReplaceableRandomAccessCollection: Sequence {
  typealias Iterator = MinimalIterator<Element>

  func makeIterator() -> MinimalIterator<Element> {
    timesMakeIteratorCalled.increment()
    return MinimalIterator(_core.elements)
  }

  var underestimatedCount: Int {
    timesUnderestimatedCountCalled.increment()
    return _core.underestimatedCount
  }
}

extension MinimalRangeReplaceableRandomAccessCollection: RandomAccessCollection {
  typealias Index = MinimalIndex
  typealias SubSequence = Slice<Self>
  typealias Indices = DefaultIndices<Self>

  var startIndex: MinimalIndex {
    timesIndexNavigationCalled.increment()
    return _core.startIndex
  }

  var endIndex: MinimalIndex {
    timesIndexNavigationCalled.increment()
    return _core.endIndex
  }

  var isEmpty: Bool {
    timesIndexNavigationCalled.increment()
    return _core.isEmpty
  }

  var count: Int {
    timesIndexNavigationCalled.increment()
    return _core.count
  }

  func _failEarlyRangeCheck(
    _ index: MinimalIndex,
    bounds: Range<MinimalIndex>
  ) {
    timesRangeChecksCalled.increment()
    _core._failEarlyRangeCheck(index, bounds: bounds)
  }

  func _failEarlyRangeCheck(
    _ range: Range<MinimalIndex>,
    bounds: Range<MinimalIndex>
  ) {
    timesRangeChecksCalled.increment()
    _core._failEarlyRangeCheck(range, bounds: bounds)
  }

  func index(after i: MinimalIndex) -> MinimalIndex {
    timesIndexNavigationCalled.increment()
    return _core.index(after: i)
  }

  func index(before i: MinimalIndex) -> MinimalIndex {
    timesIndexNavigationCalled.increment()
    return _core.index(before: i)
  }

  func distance(from start: MinimalIndex, to end: MinimalIndex)
    -> Int {
    timesIndexNavigationCalled.increment()
    return _core.distance(from: start, to: end)
  }

  func index(_ i: Index, offsetBy n: Int) -> Index {
    timesIndexNavigationCalled.increment()
    return _core.index(i, offsetBy: n)
  }

  subscript(i: MinimalIndex) -> Element {
    timesSubscriptGetterCalled.increment()
    return _core[i]
  }

  subscript(bounds: Range<MinimalIndex>) -> SubSequence {
    timesRangeSubscriptGetterCalled.increment()
    _core.assertValid(bounds)
    return Slice(base: self, bounds: bounds)
  }

  static func _coreSlice(from slice: SubSequence) -> ArraySlice<Element> {
    slice.base._core.assertValid(slice.startIndex ..< slice.endIndex)
    return slice.base._core.elements[slice.startIndex._offset ..< slice.endIndex._offset]
  }
}

extension MinimalRangeReplaceableRandomAccessCollection: RangeReplaceableCollection {
  init() {
    self.init([])
  }

  mutating func replaceSubrange<C: Collection>(
    _ subrange: Range<Index>,
    with newElements: C
  ) where C.Element == Element {
    _core.replaceSubrange(subrange, with: newElements)
  }

  mutating func reserveCapacity(_ n: Int) {
    _core.reserveCapacity(minimumCapacity: n)
  }

  init<S: Sequence>(_ elements: S) where S.Element == Element {
    self.init(elements, context: TestContext.current)
  }

  mutating func append(_ newElement: Element) {
    _core.append(newElement)
  }

  mutating func append<S: Sequence>(
    contentsOf newElements: S
  ) where S.Element == Element {
    _core.append(contentsOf: newElements)
  }

  mutating func insert(_ newElement: Element, at i: Index) {
    _core.insert(newElement, at: i)
  }

  @discardableResult
  mutating func remove(at i: Index) -> Element {
    return _core.remove(at: i)
  }

  mutating func removeSubrange(_ bounds: Range<Index>) {
    _core.removeSubrange(bounds)
  }

  mutating func _customRemoveLast() -> Element? {
    return _core._customRemoveLast()
  }

  mutating func _customRemoveLast(_ n: Int) -> Bool {
    return _core._customRemoveLast(n)
  }

  @discardableResult
  mutating func removeFirst() -> Element {
    return _core.removeFirst()
  }

  mutating func removeFirst(_ n: Int) {
    _core.removeFirst(n)
  }

  mutating func removeAll(keepingCapacity keepCapacity: Bool) {
    _core.removeAll(keepingCapacity: keepCapacity)
  }

  mutating func removeAll(
    where shouldBeRemoved: (Element) throws -> Bool) rethrows {
    try _core.removeAll(where: shouldBeRemoved)
  }
}
