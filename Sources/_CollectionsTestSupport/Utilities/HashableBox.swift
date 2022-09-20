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

final class HashableBox<T: Hashable>: Hashable {
  init(_ value: T) { self.value = value }
  var value: T

  static func ==(left: HashableBox, right: HashableBox) -> Bool {
    left.value == right.value
  }

  func hash(into hasher: inout Hasher) {
    hasher.combine(value)
  }
}
