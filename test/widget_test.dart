import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:app_vision/main.dart';
import 'package:app_vision/providers/vision_provider.dart';

void main() {
  testWidgets('App Vision smoke test — renders HomeScreen', (WidgetTester tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => VisionProvider(),
        child: const AppVision(),
      ),
    );

    // La app debe mostrar el título
    expect(find.text('App Vision'), findsWidgets);
    expect(find.text('Analizar imagen'), findsOneWidget);
  });
}
