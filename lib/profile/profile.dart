import 'package:aikviz/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'profile_logged_in.dart';
import 'profile_not_logged_in.dart';
import '../constants.dart';
import '../services/database_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _ProfileScreenState();
  }
}

class _ProfileScreenState extends State<ProfileScreen> {
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

                    return ProfileLoggedInScreen();
                  } else {
                    return ProfileLoggedInScreen();
                  }
                },
              );
            } else {
              return ProfileNotLoggedInScreen();
            }
          },
        );
      },
    );
  }
}
