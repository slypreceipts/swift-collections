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

/// A minimal implementation of `BidirectionalCollection` with extra checks.
struct MinimalBidirectionalCollection<Element> {
  internal var _core: _MinimalCollectionCore<Element>

  let timesMakeIteratorCalled = ResettableValue(0)
  let timesUnderestimatedCountCalled = ResettableValue(0)
  let timesStartIndexCalled = ResettableValue(0)
  let timesEndIndexCalled = ResettableValue(0)
  let timesRangeChecksCalled = ResettableValue(0)
  let timesIndexAfterCalled = ResettableValue(0)
  let timesIndexBeforeCalled = ResettableValue(0)
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

extension MinimalBidirectionalCollection: Sequence {
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

extension MinimalBidirectionalCollection: BidirectionalCollection {
  typealias Index = MinimalIndex
  typealias SubSequence = Slice<MinimalBidirectionalCollection>
  typealias Indices = DefaultIndices<MinimalBidirectionalCollection>

  var startIndex: MinimalIndex {
    timesStartIndexCalled.increment()
    return _core.startIndex
  }

  var endIndex: MinimalIndex {
    timesEndIndexCalled.increment()
    return _core.endIndex
  }

  var isEmpty: Bool {
    // Pretend this is implemented as `startIndex == endIndex`.
    timesStartIndexCalled.increment()
    timesEndIndexCalled.increment()
    return _core.isEmpty
  }

  var count: Int {
    // Pretend this is implemented by counting elements using `index(after:)`.
    let result = _core.count
    timesIndexAfterCalled.increment(by: result)
    return result
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
    timesIndexAfterCalled.increment()
    return _core.index(after: i)
  }

  func index(before i: MinimalIndex) -> MinimalIndex {
    timesIndexBeforeCalled.increment()
    return _core.index(before: i)
  }

  func distance(from start: MinimalIndex, to end: MinimalIndex)
    -> Int {
    // Pretend this is implemented by counting elements using `index(after:)`/`index(before:).
    let result = _core.distance(from: start, to: end)
    if result >= 0 {
      timesIndexAfterCalled.increment(by: result)
    } else {
      timesIndexBeforeCalled.increment(by: -result)
    }
    return result
  }

  func index(_ i: Index, offsetBy n: Int) -> Index {
    // Pretend this is implemented by iterating elements using `index(after:)`/`index(before:)`.
    if n >= 0 {
      timesIndexAfterCalled.increment(by: n)
    } else {
      timesIndexBeforeCalled.increment(by: -n)
    }
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
