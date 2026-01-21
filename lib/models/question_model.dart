/// Question model representing a quiz question with answers
class Question {
  final String text;
  final Map<String, bool> answers;

  Question({
    required this.text,
    required this.answers,
  });

  /// Creates a Question from a map (from API or Firestore)
  factory Question.fromMap(Map<String, dynamic> map) {
    return Question(
      text: map['questionText'] as String? ?? map['text'] as String? ?? '',
      answers: Map<String, bool>.from(map['answers'] as Map? ?? {}),
    );
  }

  /// Converts Question to a map
  Map<String, dynamic> toMap() {
    return {
      'questionText': text,
      'answers': answers,
    };
  }

  /// Gets the correct answer text
  String? get correctAnswer {
    try {
      return answers.entries.firstWhere((entry) => entry.value).key;
    } catch (e) {
      return null;
    }
  }

  /// Gets all answer options as a list
  List<String> get answerOptions => answers.keys.toList();

  /// Checks if a given answer is correct
  bool isCorrect(String answer) => answers[answer] ?? false;
}
