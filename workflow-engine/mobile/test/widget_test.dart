import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:workflow_mobile/main.dart';

void main() {
  testWidgets('App launches correctly', (WidgetTester tester) async {
    await tester.pumpWidget(const WorkflowMobileApp());
    expect(find.text('Workflow Engine'), findsOneWidget);
  });
}
