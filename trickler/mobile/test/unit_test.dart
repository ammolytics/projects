import 'package:test/test.dart';
import 'package:scale_controller/home.dart';

void main() {
  test('Counter Value Updates', () {
    final String t = 'Scale Controller';

    final controller = HomePage();
    expect(controller.title, t);
  });
}