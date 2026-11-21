import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:penguin_search/main.dart';

void main() {
  testWidgets('demo is explicitly labeled and opens the feed', (tester) async {
    await tester.pumpWidget(const PenguinApp());
    expect(find.textContaining('DEVELOPMENT DEMO'), findsOneWidget);
    await tester.tap(find.text('Open local demo'));
    await tester.pumpAndSettle();
    expect(find.text('Report Lost Item'), findsOneWidget);
    expect(find.text('Report Found Item'), findsOneWidget);
    expect(find.byType(NavigationBar), findsOneWidget);
  });
}
