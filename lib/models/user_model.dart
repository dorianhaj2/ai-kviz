/// User model representing user data and statistics
class User {
  final String id;
  final String username;
  final String email;
  final int quizzesCompleted;
  final int totalCorrect;
  final int totalAnswers;
  final double averageScore;
  final bool isAdmin;
  final int rating;

  User({
    required this.id,
    required this.username,
    required this.email,
    this.quizzesCompleted = 0,
    this.totalCorrect = 0,
    this.totalAnswers = 0,
    this.averageScore = 0.0,
    this.isAdmin = false,
    this.rating = 1000,
  });

  /// Creates a User from a Firestore document
  factory User.fromFirestore(String id, Map<String, dynamic> data) {
    return User(
      id: id,
      username: data['username'] as String? ?? 'Guest',
      email: data['email'] as String? ?? '',
      quizzesCompleted: data['quizzes'] as int? ?? 0,
      totalCorrect: data['total_correct'] as int? ?? 0,
      totalAnswers: data['total_answers'] as int? ?? 0,
      averageScore: (data['avg_score'] as num? ?? 0.0).toDouble(),
      isAdmin: data['is_admin'] as bool? ?? false,
      rating: data['rating'] as int? ?? 1000,
    );
  }

  /// Converts User to a map for Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'username': username,
      'email': email,
      'quizzes': quizzesCompleted,
      'total_correct': totalCorrect,
      'total_answers': totalAnswers,
      'avg_score': averageScore,
      'is_admin': isAdmin,
      'rating': rating,
    };
  }

  /// Creates a copy of User with updated fields
  User copyWith({
    String? id,
    String? username,
    String? email,
    int? quizzesCompleted,
    int? totalCorrect,
    int? totalAnswers,
    double? averageScore,
    bool? isAdmin,
    int? rating,
  }) {
    return User(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      quizzesCompleted: quizzesCompleted ?? this.quizzesCompleted,
      totalCorrect: totalCorrect ?? this.totalCorrect,
      totalAnswers: totalAnswers ?? this.totalAnswers,
      averageScore: averageScore ?? this.averageScore,
      isAdmin: isAdmin ?? this.isAdmin,
      rating: rating ?? this.rating,
    );
  }

  /// Creates a guest user
  factory User.guest() {
    return User(
      id: '',
      username: 'Guest',
      email: 'guest@example.com',
      rating: 1000,
    );
  }
}
