import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:konbis/main.dart';

void main() {
  testWidgets('KonbisApp smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const KonbisApp());
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
