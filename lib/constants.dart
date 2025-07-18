import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'services/database_service.dart';

const primaryTextColor = Colors.white;
const secondaryTextColor = Color(0xffc4b5fd);
const cardBackgroundColor = Color(0xff271845);
const buttonBackgroundColor = Color.fromARGB(164, 60, 44, 90);
const primaryButtonColor = Color(0xff6a2ae5);
const primaryBackgroundColor = Color(0xff1a0d2e);
const selectedItemColor = Color(0xff7c3aed);

int currentScreenIndex = 0;

String username = 'Guest';
String useremail = 'guest@example.com';
String userId = '';
bool isAdmin = false;

int quizzesCompleted = 0;
int totalCorrect = 0;
int totalAnswers = 0;
double averageScore = 0.0;

int questionIndex = 0;
var totalScore = 0;
var questions = <Map<String, dynamic>>[];

Future<void> initializeQuestions() async {
  questions.clear();

  QuerySnapshot? snapshot = await DatabaseService().read(path: 'Questions');

  if (snapshot != null) {
    List<dynamic> docs = snapshot.docs.map((doc) => doc.data()).toList();
    for (var doc in docs) {
      questions.add({
        'questionText': doc['question'],
        'answers': Map<String, bool>.from(doc['answers']),
      });
    }
    questions.shuffle();
    questions = questions.take(10).toList(); // Limit to 10 questions
    questionIndex = 0;
    totalScore = 0;
  }
}

// A reusable widget for the statistic cards to keep the code clean.
class StatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color iconColor;

  const StatCard({
    Key? key,
    required this.icon,
    required this.value,
    required this.label,
    this.iconColor = Colors.white,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: const Color(0xff271845),
        borderRadius: BorderRadius.circular(15.0),
      ),
      child: Column(
        children: [
          Icon(icon, size: 30, color: iconColor),
          const SizedBox(height: 10),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 2,
            style: const TextStyle(color: Color(0xffc4b5fd), fontSize: 14),
          ),
        ],
      ),
    );
  }
}
