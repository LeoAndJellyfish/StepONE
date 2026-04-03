import 'package:flutter/material.dart';
import '../pages/home_page.dart';
import '../pages/achievement_list_page.dart';
import '../pages/achievement_form_page.dart';

class AppRouter {
  static const String home = '/';
  static const String achievementList = '/achievements';
  static const String achievementForm = '/achievement-form';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case home:
        return MaterialPageRoute(
          builder: (_) => const HomePage(),
        );
      
      case achievementList:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => AchievementListPage(
            categoryId: args?['categoryId'],
            categoryName: args?['categoryName'],
          ),
        );
      
      case achievementForm:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => AchievementFormPage(
            achievement: args?['achievement'],
          ),
        );
      
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('No route defined for ${settings.name}'),
            ),
          ),
        );
    }
  }
}
