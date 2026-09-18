import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'core/dependencies/app_dependencies.dart';
import 'core/routing/app_router.dart';
import 'core/theme/app_theme.dart';

class PcjApp extends StatefulWidget {
  const PcjApp({super.key, required this.dependencies});

  final AppDependencies dependencies;

  @override
  State<PcjApp> createState() => _PcjAppState();
}

class _PcjAppState extends State<PcjApp> {
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _router = createAppRouter(widget.dependencies);
    widget.dependencies.authController.restoreSession();
  }

  @override
  void dispose() {
    _router.dispose();
    widget.dependencies.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      routerConfig: _router,
    );
  }
}
