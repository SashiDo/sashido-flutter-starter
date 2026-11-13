import 'package:flutter_test/flutter_test.dart';

import 'package:sashido_flutter_starter/main.dart' as app;

void main() {
  testWidgets('without keys it says how to add them instead of failing', (tester) async {
    // no --dart-define-from-file: the keys are empty
    await app.main();
    await tester.pumpAndSettle();
    expect(find.textContaining('config.example.json'), findsOneWidget);
  });
}
