import 'package:flutter/material.dart';
import 'quiz/result.dart';
import 'home/home.dart';
import 'profile/profile.dart';
import './constants.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'services/auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await authService.value.signOut();
  runApp(const QuizScreen());
}

class QuizScreen extends StatefulWidget {
  const QuizScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _QuizScreenState();
  }
}

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class _QuizScreenState extends State<QuizScreen> {
  void _resetQuiz() {
    setState(() {
      questionIndex = 0;
      totalScore = 0;
    });
  }

  void _answerQuestion(bool isCorrect) {
    if (isCorrect) {
      totalScore += 1;
    }

    setState(() {
      questionIndex = questionIndex + 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget screenWidget = HomeScreen(
      answerQuestion: _answerQuestion,
      resetQuiz: _resetQuiz,
    );

    switch (currentScreenIndex) {
      case 0:
        screenWidget = HomeScreen(
          answerQuestion: _answerQuestion,
          resetQuiz: _resetQuiz,
        );
      case 1:
        screenWidget = ProfileScreen();
    }

    return MaterialApp(
      navigatorKey: navigatorKey,
      home: Scaffold(
        backgroundColor: primaryBackgroundColor,
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: currentScreenIndex > 1 ? 0 : currentScreenIndex,
          type: BottomNavigationBarType.fixed,
          backgroundColor: cardBackgroundColor,
          selectedItemColor: selectedItemColor,
          unselectedItemColor: secondaryTextColor,
          showUnselectedLabels: true,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
          ],
          onTap: (value) {
            setState(() {
              currentScreenIndex = value;
            });
          },
        ),
        body: screenWidget,
      ),
      routes: <String, WidgetBuilder>{
        '/results': (BuildContext context) =>
            Result(totalScore, questions.length, _resetQuiz),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}
