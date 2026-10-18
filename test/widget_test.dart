import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fitbase/main.dart';
import 'package:fitbase/presentation/screens/admin/admin_dashboard_screen.dart';
import 'package:fitbase/presentation/screens/admin/admin_settings_screen.dart';
import 'package:fitbase/presentation/screens/user/user_home_screen.dart';
import 'package:fitbase/presentation/screens/common/profile_screen.dart';
import 'package:fitbase/presentation/screens/common/settings_screen.dart';

void main() {
  testWidgets('Fitbase smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const FitbaseApp());
    expect(find.text('FITBASE'), findsOneWidget);
  });

  testWidgets('AdminDashboardScreen responsive test', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: AdminDashboardScreen()),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Panel de Administración'), findsOneWidget);
    expect(find.text('Total Usuarios'), findsOneWidget);
  });

  testWidgets('UserHomeScreen responsive test', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: UserHomeScreen()),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Hola, Carlos 👋'), findsOneWidget);
  });

  testWidgets('AdminSettingsScreen logout button test', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: AdminSettingsScreen()),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Configuración del Administrador'), findsOneWidget);
    expect(find.text('Cerrar Sesión'), findsOneWidget);

    await tester.tap(find.text('Cerrar Sesión'));
    await tester.pumpAndSettle();
    expect(find.text('¿Cerrar sesión?'), findsOneWidget);
  });

  testWidgets('ProfileScreen render test', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: ProfileScreen()),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Perfil'), findsOneWidget);
    expect(find.text('Datos Personales'), findsOneWidget);
  });

  testWidgets('SettingsScreen render test', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: SettingsScreen()),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Configuración'), findsOneWidget);
    expect(find.text('Notificaciones Push'), findsOneWidget);
  });
}
