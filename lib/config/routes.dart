import 'package:flutter/material.dart';
import 'package:bytequeens_adm/config/app_constants.dart';
import 'package:bytequeens_adm/features/splash/presentation/pages/splash_page.dart';

class AppRoutes {
  static const String initial = AppConstants.splashRoute;

  static Map<String, WidgetBuilder> get routes => {
    AppConstants.splashRoute: (context) => const SplashPage(),
  };

  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppConstants.splashRoute:
        return MaterialPageRoute(
          builder: (context) => const SplashPage(),
          settings: settings,
        );
      default:
        return null;
    }
  }

  
  static Route<dynamic> onUnknownRoute(RouteSettings settings) {
    return MaterialPageRoute(
      builder: (context) => Scaffold(
        appBar: AppBar(
          title: const Text('Page Not Found'),
        ),
        body: Center(
          child: Text('No route defined for ${settings.name}'),
        ),
      ),
    );
  }
}
