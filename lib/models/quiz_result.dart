/// Quiz result model representing the outcome of a completed quiz
class QuizResult {
  final int score;
  final int totalQuestions;
  final DateTime completedAt;
  final String topic;

  QuizResult({
    required this.score,
    required this.totalQuestions,
    required this.completedAt,
    this.topic = '',
  });

  /// Calculates the percentage score
  double get percentage {
    if (totalQuestions == 0) return 0.0;
    return (score / totalQuestions) * 100;
  }

  /// Checks if the quiz was passed (60% or higher)
  bool get isPassed => percentage >= 60;

  /// Gets a grade letter based on percentage
  String get grade {
    if (percentage >= 90) return 'A';
    if (percentage >= 80) return 'B';
    if (percentage >= 70) return 'C';
    if (percentage >= 60) return 'D';
    return 'F';
  }

  /// Converts to a map for storage
  Map<String, dynamic> toMap() {
    return {
      'score': score,
      'total_questions': totalQuestions,
      'completed_at': completedAt.toIso8601String(),
      'topic': topic,
      'percentage': percentage,
    };
  }

  /// Creates a QuizResult from a map
  factory QuizResult.fromMap(Map<String, dynamic> map) {
    return QuizResult(
      score: map['score'] as int? ?? 0,
      totalQuestions: map['total_questions'] as int? ?? 0,
      completedAt: DateTime.parse(map['completed_at'] as String),
      topic: map['topic'] as String? ?? '',
    );
  }
}
