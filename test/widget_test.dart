import 'package:flutter_test/flutter_test.dart';

import 'package:e_team/app/app.dart';
import 'package:e_team/app/app_providers.dart';

void main() {
  testWidgets('app starts with provider scope', (WidgetTester tester) async {
    await tester.pumpWidget(const AppProviders(child: ETeamApp()));

    expect(find.byType(ETeamApp), findsOneWidget);
  });
}
