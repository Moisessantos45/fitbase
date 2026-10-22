import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fitbase/presentation/providers/auth_provider.dart';

class RoleGuard {
  static bool canAccess(WidgetRef ref, List<int> allowedRoles) {
    final user = ref.read(authProvider).value?.authData;
    final roleId = user?.roleId ?? 0;
    return allowedRoles.contains(roleId);
  }
}

class CustomNavigator {
  static Future<T?> pushFade<T>(
    BuildContext context,
    Widget page, {
    Duration duration = const Duration(milliseconds: 300),
  }) {
    return Navigator.push<T>(
      context,
      PageRouteBuilder(
        transitionDuration: duration,
        reverseTransitionDuration: duration,
        pageBuilder: (context, animation, secondaryAnimation) => page,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  static Future<T?> pushReplacementFade<T, TO>(
    BuildContext context,
    Widget page, {
    Duration duration = const Duration(milliseconds: 300),
  }) {
    return Navigator.pushReplacement<T, TO>(
      context,
      PageRouteBuilder(
        transitionDuration: duration,
        reverseTransitionDuration: duration,
        pageBuilder: (context, animation, secondaryAnimation) => page,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  static Future<T?> pushAndRemoveUntilFade<T>(
    BuildContext context,
    Widget page, {
    Duration duration = const Duration(milliseconds: 300),
  }) {
    return Navigator.pushAndRemoveUntil<T>(
      context,
      PageRouteBuilder(
        transitionDuration: duration,
        reverseTransitionDuration: duration,
        pageBuilder: (context, animation, secondaryAnimation) => page,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
      (route) => false,
    );
  }

  static Future<T?> pushProtectedFade<T>(
    BuildContext context,
    WidgetRef ref,
    Widget page, {
    required List<int> allowedRoles,
    String deniedMessage = 'No tienes permisos para acceder a esta sección',
    Duration duration = const Duration(milliseconds: 300),
  }) {
    if (!RoleGuard.canAccess(ref, allowedRoles)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(deniedMessage)),
      );
      return Future.value(null);
    }
    return pushFade<T>(context, page, duration: duration);
  }

  static Future<T?> pushPublicOnlyFade<T>(
    BuildContext context,
    WidgetRef ref,
    Widget page, {
    Duration duration = const Duration(milliseconds: 300),
  }) {
    final auth = ref.read(authProvider).value;
    if (auth != null && auth.authenticated) {
      return Future.value(null);
    }
    return pushFade<T>(context, page, duration: duration);
  }
}
