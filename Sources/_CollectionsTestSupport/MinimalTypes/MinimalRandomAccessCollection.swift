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

/// A minimal implementation of `RandomAccessCollection` with extra checks.
struct MinimalRandomAccessCollection<Element> {
  internal var _core: _MinimalCollectionCore<Element>

  let timesMakeIteratorCalled = ResettableValue(0)
  let timesUnderestimatedCountCalled = ResettableValue(0)
  let timesRangeChecksCalled = ResettableValue(0)
  let timesIndexNavigationCalled = ResettableValue(0)
  let timesSubscriptCalled = ResettableValue(0)
  let timesRangeSubscriptCalled = ResettableValue(0)

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

extension MinimalRandomAccessCollection: Sequence {
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

extension MinimalRandomAccessCollection: RandomAccessCollection {
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
    timesSubscriptCalled.increment()
    return _core[i]
  }

  subscript(bounds: Range<MinimalIndex>) -> SubSequence {
    timesRangeSubscriptCalled.increment()
    _core.assertValid(bounds)
    return Slice(base: self, bounds: bounds)
  }
}
