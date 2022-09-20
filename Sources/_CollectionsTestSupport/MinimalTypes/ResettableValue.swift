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

// Loosely adapted from https://github.com/apple/swift/tree/main/stdlib/private/StdlibUnittest

class ResettableValue<Value> {
  init(_ value: Value) {
    self.defaultValue = value
    self.value = value
  }

  func reset() {
    value = defaultValue
  }

  let defaultValue: Value
  var value: Value
}

extension ResettableValue where Value: Strideable {
  func increment(by delta: Value.Stride = 1) {
    value = value.advanced(by: delta)
  }
}

extension ResettableValue: CustomStringConvertible {
  var description: String { "\(value)" }
}
