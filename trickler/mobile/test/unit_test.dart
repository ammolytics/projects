/// Copyright (c) Ammolytics and contributors. All rights reserved.
/// Released under the MIT license. See LICENSE file in the project root for details.

import 'package:test/test.dart';
import 'package:scale_controller/helpers.dart';
import 'package:scale_controller/globals.dart';

void main() {

  /// This is an example unit test.
  test('roundWeight has acurrate results', () {
    // Test GRAINS round up
    expect(roundWeight(2.235, GRAINS), equals(2.24));

    // Test GRAINS round down
    expect(roundWeight(4.444, GRAINS), equals(4.44));

    // Test GRAMS round up
    expect(roundWeight(12.1159, GRAMS), equals(12.116));

    // Test GRAMS round down
    expect(roundWeight(3.4452, GRAMS), equals(3.445));
  });
}