import 'package:flutter/material.dart';
import '../cores/config/app_config.dart';
import 'di/injection.dart';
import 'routes/app_router.dart';
import 'routes/app_routes.dart';
import 'theme/app_theme.dart';

class HouseChoreApp extends StatelessWidget {
  HouseChoreApp({super.key, required AppDependencies dependencies}) : _router = AppRouter(dependencies);

  final AppRouter _router;

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: AppConfig.appName,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        initialRoute: AppRoutes.main,
        onGenerateRoute: _router.onGenerateRoute,
        // Layar lebar (768 / 1280 px): konten dibatasi 560 px dan diletakkan di tengah.
        builder: (context, child) => ColoredBox(
          color: AppColors.background,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: AppConfig.maxContentWidth),
              child: SizedBox.expand(child: child),
            ),
          ),
        ),
      );
}
