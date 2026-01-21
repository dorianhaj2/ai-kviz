import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'services/auth_service.dart';
import 'services/database_service.dart';
import 'services/gemini_service.dart';
import 'services/pinecone_service.dart';
import 'services/question_service.dart';
import 'services/leaderboard_service.dart';
import 'services/achievement_service.dart';
import 'firebase_options.dart';

/// Global service locator instance
final getIt = GetIt.instance;

/// Sets up dependency injection for the application
Future<void> setupServiceLocator() async {
  // Register Logger first since other services depend on it
  getIt.registerLazySingleton<Logger>(
    () => Logger(
      printer: PrettyPrinter(
        methodCount: 0,
        errorMethodCount: 5,
        lineLength: 50,
        colors: true,
        printEmojis: true,
      ),
    ),
  );

  // Register services as singletons with logger injection
  getIt.registerLazySingleton<AuthService>(
    () => AuthService(logger: getIt<Logger>()),
  );

  getIt.registerLazySingleton<DatabaseService>(
    () => DatabaseService(logger: getIt<Logger>()),
  );

  // Register Gemini service (requires API key)
  getIt.registerLazySingleton<GeminiService>(
    () => GeminiService(apiKey: geminiApiKey),
  );

  // Register Pinecone service (requires configuration)
  getIt.registerLazySingleton<PineconeService>(
    () => PineconeService(
      apiKey: pineconeApiKey,
      indexName: pineconeIndexName,
      projectId: pineconeProjectId,
      environment: pineconeEnvironment,
    ),
  );

  // Register QuestionService with all dependencies
  getIt.registerLazySingleton<QuestionService>(
    () => QuestionService(
      geminiService: getIt<GeminiService>(),
      databaseService: getIt<DatabaseService>(),
      pineconeService: getIt<PineconeService>(),
      logger: getIt<Logger>(),
    ),
  );

  // Register LeaderboardService
  getIt.registerLazySingleton<LeaderboardService>(
    () => LeaderboardService(logger: getIt<Logger>()),
  );

  // Register AchievementService
  getIt.registerLazySingleton<AchievementService>(
    () => AchievementService(logger: getIt<Logger>()),
  );
}
