import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'home/home.dart';
import 'profile/profile.dart';
import 'leaderboard/leaderboard.dart';
import 'core/theme/app_colors.dart';
import 'firebase_options.dart';
import 'service_locator.dart';
import 'providers/user_provider.dart';
import 'providers/quiz_provider.dart';
import 'providers/navigation_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }

  // Setup dependency injection
  await setupServiceLocator();

  runApp(const QuizApp());
}

class QuizApp extends StatelessWidget {
  const QuizApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => QuizProvider()),
        ChangeNotifierProvider(create: (_) => NavigationProvider()),
      ],
      child: const QuizScreen(),
    );
  }
}

class QuizScreen extends StatelessWidget {
  const QuizScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AI Quiz',
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: AppColors.primaryButton,
        scaffoldBackgroundColor: AppColors.primaryBackground,
      ),
      home: const MainScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MainScreen extends StatelessWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final navigationProvider = Provider.of<NavigationProvider>(context);

    Widget currentScreen;
    switch (navigationProvider.currentIndex) {
      case 0:
        currentScreen = const HomeScreen();
        break;
      case 1:
        currentScreen = const LeaderboardScreen();
        break;
      case 2:
        currentScreen = const ProfileScreen();
        break;
      default:
        currentScreen = const HomeScreen();
    }

    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: navigationProvider.currentIndex,
        type: BottomNavigationBarType.fixed,
        backgroundColor: AppColors.cardBackground,
        selectedItemColor: AppColors.selectedItem,
        unselectedItemColor: AppColors.secondaryText,
        showUnselectedLabels: true,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(
            icon: Icon(Icons.leaderboard),
            label: "Leaderboard",
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
        onTap: (index) => navigationProvider.setIndex(index),
      ),
      body: currentScreen,
    );
  }
}
