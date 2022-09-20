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

@usableFromInline
internal struct _DequeSlot {
  @usableFromInline
  internal var position: Int


  @inline(__always)
  init(at position: Int) {
    assert(position >= 0)
    self.position = position
  }
}

extension _DequeSlot {

  @inline(__always)
  internal static var zero: Self { Self(at: 0) }


  @inline(__always)
  internal func advanced(by delta: Int) -> Self {
    Self(at: position &+ delta)
  }


  @inline(__always)
  internal func orIfZero(_ value: Int) -> Self {
    guard position > 0 else { return Self(at: value) }
    return self
  }
}

extension _DequeSlot: CustomStringConvertible {
  @usableFromInline
  internal var description: String {
    "@\(position)"
  }
}

extension _DequeSlot: Equatable {
  @usableFromInline
  static func ==(left: Self, right: Self) -> Bool {
    left.position == right.position
  }
}

extension _DequeSlot: Comparable {
  @usableFromInline
  static func <(left: Self, right: Self) -> Bool {
    left.position < right.position
  }
}

extension Range where Bound == _DequeSlot {

  @inline(__always)
  internal var _count: Int { upperBound.position - lowerBound.position }
}
