import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';

void main() {
  testWidgets('Clear all Hive data', (WidgetTester tester) async {
    await Hive.initFlutter();
    await Hive.deleteFromDisk();
    print('HIVE_DATA_DELETED_SUCCESSFULLY');
  });
}
