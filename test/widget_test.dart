import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:dl_ritsumeikan_mobile/main.dart';

void main() {
  testWidgets('App renders without crash', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: BikeParkApp()));
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
