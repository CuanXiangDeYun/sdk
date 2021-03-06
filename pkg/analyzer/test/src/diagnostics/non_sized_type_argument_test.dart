// Copyright (c) 2021, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:analyzer/src/dart/error/ffi_code.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

import '../dart/resolution/context_collection_resolution.dart';

main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(NonSizedTypeArgument);
  });
}

@reflectiveTest
class NonSizedTypeArgument extends PubPackageResolutionTest {
  test_one() async {
    await assertNoErrorsInCode(r'''
import 'dart:ffi';

class C extends Struct {
  @Array(8)
  Array<Uint8> a0;
}
''');
  }

  test_two() async {
    await assertErrorsInCode(r'''
import 'dart:ffi';

class C extends Struct {
  @Array(8)
  Array<Array<Uint8>> a0;
}
''', [
      error(FfiCode.NON_SIZED_TYPE_ARGUMENT, 59, 19),
    ]);
  }
}
