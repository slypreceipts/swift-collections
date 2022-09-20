//===----------------------------------------------------------------------===//
//
// This source file is part of the Swift Collections open source project
//
// Copyright (c) 2021 Apple Inc. and the Swift project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
//
//===----------------------------------------------------------------------===//

extension OrderedSet._UnstableInternals {
  var capacity: Int { base._capacity }
  var minimumCapacity: Int { base._minimumCapacity }
  var scale: Int { base._scale }
  var reservedScale: Int { base._reservedScale }
  var bias: Int { base._bias }
}

extension OrderedSet {

  @_alwaysEmitIntoClient
  static var _minimumScale: Int {
    _HashTable.minimumScale
  }


  @_alwaysEmitIntoClient
  static func _minimumCapacity(forScale scale: Int) -> Int {
    _HashTable.minimumCapacity(forScale: scale)
  }


  @_alwaysEmitIntoClient
  static func _maximumCapacity(forScale scale: Int) -> Int {
    _HashTable.maximumCapacity(forScale: scale)
  }


  @_alwaysEmitIntoClient
  static func _scale(forCapacity capacity: Int) -> Int {
    _HashTable.scale(forCapacity: capacity)
  }


  @_alwaysEmitIntoClient
  static func _biasRange(scale: Int) -> Range<Int> {
    guard scale != 0 else { return Range(uncheckedBounds: (0, 1)) }
    return Range(uncheckedBounds: (0, (1 &<< scale) - 1))
  }
}

extension OrderedSet._UnstableInternals {

  @_alwaysEmitIntoClient
  var hasHashTable: Bool { base._table != nil }


  @_alwaysEmitIntoClient
  var hashTableIdentity: ObjectIdentifier? {
    guard let storage = base.__storage else { return nil }
    return ObjectIdentifier(storage)
  }


  var hashTableContents: [Int?] {
    guard let table = base._table else { return [] }
    return table.read { hashTable in
      hashTable.debugContents()
    }
  }


  @_alwaysEmitIntoClient
  mutating func _regenerateHashTable(bias: Int) {
    base._ensureUnique()
    let new = base._table!.copy()
    base._table!.read { source in
      new.update { target in
        target.bias = bias
        var it = source.bucketIterator(startingAt: _Bucket(offset: 0))
        repeat {
          target[it.currentBucket] = it.currentValue
          it.advance()
        } while it.currentBucket.offset != 0
      }
    }
    base._table = new
    base._checkInvariants()
  }


  @_alwaysEmitIntoClient
  mutating func reserveCapacity(
    _ minimumCapacity: Int,
    persistent: Bool
  ) {
    base._reserveCapacity(minimumCapacity, persistent: persistent)
    base._checkInvariants()
  }
}

extension OrderedSet {

  init<S: Sequence>(
    _scale scale: Int,
    bias: Int,
    contents: S
  ) where S.Element == Element {
    let contents = ContiguousArray(contents)
    precondition(scale >= _HashTable.scale(forCapacity: contents.count))
    precondition(scale <= _HashTable.maximumScale)
    precondition(bias >= 0 && Self._biasRange(scale: scale).contains(bias))
    precondition(scale >= _HashTable.minimumScale || bias == 0)
    let table = _HashTable(scale: Swift.max(scale, _HashTable.minimumScale))
    table.header.bias = bias
    let (success, index) = table.update { hashTable in
      hashTable.fill(untilFirstDuplicateIn: contents)
    }
    precondition(success, "Duplicate element at index \(index)")
    self.init(
      _uniqueElements: contents,
      scale < _HashTable.minimumScale ? nil : table)
    precondition(self._scale == scale)
    precondition(self._bias == bias)
    _checkInvariants()
  }
}
