import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'home_not_logged_in.dart';
import 'home_logged_in.dart';
import '../constants.dart';
import '../services/database_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomeScreen extends StatefulWidget {
  final Function(bool) answerQuestion;
  final Function() resetQuiz;

  const HomeScreen({
    Key? key,
    required this.answerQuestion,
    required this.resetQuiz,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _HomeScreenState();
  }
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: authService,
      builder: (context, asyncSnapshot, child) {
        return StreamBuilder(
          stream: authService.value.authStateChanges,
          builder: (context, asyncSnapshot) {
            if (asyncSnapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (asyncSnapshot.hasError) {
              return Center(child: Text('Error: ${asyncSnapshot.error}'));
            } else if (asyncSnapshot.hasData && asyncSnapshot.data != null) {
              String email = authService.value.currentUser?.email ?? '';

              return FutureBuilder<QuerySnapshot?>(
                future: DatabaseService().read(path: 'UserData'),
                builder: (context, userSnapshot) {
                  if (userSnapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (userSnapshot.hasError) {
                    return Center(child: Text('Error: ${userSnapshot.error}'));
                  } else if (userSnapshot.hasData &&
                      userSnapshot.data != null) {
                    var userdata = userSnapshot.data;
                    if (userdata == null) {
                      username = 'Guest';
                      useremail = 'guest@example.com';
                    } else {
                      var user = userdata.docs
                          .where((doc) => doc['email'] == email)
                          .toList();
                      username = user.isNotEmpty
                          ? user.first['username']
                          : 'Guest';
                      useremail = email;
                      userId = user.isNotEmpty ? user.first.id : '';

                      quizzesCompleted = user.isNotEmpty
                          ? user.first['quizzes']
                          : 0;
                      averageScore = user.isNotEmpty
                          ? user.first['avg_score']
                          : 0.0;
                      totalAnswers = user.isNotEmpty
                          ? user.first['total_answers']
                          : 0;
                      totalCorrect = user.isNotEmpty
                          ? user.first['total_correct']
                          : 0;
                    }
                    return HomeLoggedInScreen(
                      answerQuestion: widget.answerQuestion,
                      resetQuiz: widget.resetQuiz,
                    );
                  } else {
                    return HomeLoggedInScreen(
                      answerQuestion: widget.answerQuestion,
                      resetQuiz: widget.resetQuiz,
                    );
                  }
                },
              );
            } else {
              return HomeNotLoggedInScreen(
                answerQuestion: widget.answerQuestion,
                resetQuiz: widget.resetQuiz,
              );
            }
          },
        );
      },
    );
  }
}
