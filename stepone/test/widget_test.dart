import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:stepone_app/main.dart';

void main() {
  testWidgets('App initialization test', (WidgetTester tester) async {
    await tester.pumpWidget(const StepONEApp());
    
    expect(find.text('StepONE'), findsOneWidget);
  });
}
