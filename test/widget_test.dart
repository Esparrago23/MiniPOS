import 'package:flutter_test/flutter_test.dart';

import 'package:minipos/app.dart';

void main() {
  testWidgets('Login page smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const App());

    expect(find.text('Iniciar sesion'), findsOneWidget);
    expect(find.text('Correo electronico'), findsOneWidget);
    expect(find.text('Entrar'), findsOneWidget);
  });
}
