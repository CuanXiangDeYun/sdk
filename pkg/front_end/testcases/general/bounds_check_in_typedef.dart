// Copyright (c) 2021, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.
// @dart=2.9
class A<X extends String> {}

typedef F = Function<Z extends A<Y>>() Function<Y extends num>();
typedef G = void Function<Y extends num>(Function<Z extends A<Y>>());

main() {}
