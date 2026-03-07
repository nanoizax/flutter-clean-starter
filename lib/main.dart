// main.dart — Leandro Perez — SonhoLab
// App entry point.  SharedPreferences is initialised before the widget tree
// so it can be provided synchronously via ProviderScope overrides.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter_clean_starter/core/router/app_router.dart';
import 'package:flutter_clean_starter/core/theme/app_theme.dart';
import 'package:flutter_clean_starter/features/auth/presentation/providers/auth_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: [
        // Provide the already-initialised SharedPreferences instance so that
        // all providers that depend on it receive a concrete value immediately.
        sharedPreferencesProvider.overrideWithValue(prefs),
      ],
      child: const CleanStarterApp(),
    ),
  );
}

class CleanStarterApp extends ConsumerWidget {
  const CleanStarterApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'Flutter Clean Starter',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      routerConfig: router,
    );
  }
}
