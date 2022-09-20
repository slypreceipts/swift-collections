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

struct StringConvertibleValue {
  var value: Int
  init(_ value: Int) { self.value = value }
}

extension StringConvertibleValue: ExpressibleByIntegerLiteral {
  init(integerLiteral value: Int) {
    self.init(value)
  }
}

extension StringConvertibleValue: CustomStringConvertible {
  var description: String {
    "description(\(value))"
  }
}

extension StringConvertibleValue: CustomDebugStringConvertible {
  var debugDescription: String {
    "debugDescription(\(value))"
  }
}
