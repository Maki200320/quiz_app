import 'package:quiz_app/models/question.dart';
import 'package:quiz_app/models/quiz.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  // Private constructor
  DatabaseHelper._internal();

  // Singleton instance
  static final DatabaseHelper _instance = DatabaseHelper._internal();

  // Factory constructor returns the singleton instance
  factory DatabaseHelper() => _instance;

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'quiz_database.db');
    return await openDatabase(
      path,
      onCreate: (db, version) async {
        await db.execute('''
        CREATE TABLE quiz(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        quizName TEXT
        )
        ''');
        await db.execute('''
          CREATE TABLE questions (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            quizId INTEGER,
            question TEXT,
            choice1 TEXT,
            choice2 TEXT,
            choice3 TEXT,
            correctAnswer INTEGER,
            FOREIGN KEY (quizId) REFERENCES quiz(id)
          )
        ''');
      },
      version: 1,
    );
  }

  Future<void> deleteQuiz(int quizId) async {
    final db = await database;

    // Delete questions associated with the quiz
    await db.delete(
      'questions',
      where: 'quizId = ?',
      whereArgs: [quizId],
    );

    // Delete the quiz itself
    await db.delete(
      'quiz',
      where: 'id = ?',
      whereArgs: [quizId],
    );
  }

  //delete specific question
  Future<void> deleteQuestion(int questionId) async {
    final db = await database;

    await db.delete('questions', where: 'id = ?', whereArgs: [questionId]);
  }

  Future<int> createQuiz(Quiz quiz) async {
    final db = await database;
    return await db.insert('quiz', quiz.toMap());
  }

  Future<int> createQuestion(Question question) async {
    final db = await database;
    return db.insert('questions', question.toMap());
  }

  Future<List<Quiz>> fetchQuiz() async {
    final db = await database;

    List<Map<String, dynamic>> map = await db.query('quiz');

    return List.generate(map.length, (i) {
      return Quiz.fromJson(map[i]);
    });
  }

  Future<List<Question>> fetchQuestions(int quizId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'questions',
      where: 'quizId = ?',
      whereArgs: [quizId],
    );

    return List.generate(maps.length, (i) {
      return Question.fromJson(maps[i]);
    });
  }

  int calculateScore(List<Question> questions, List<int> selectedAnswers) {
    int score = 0;
    for (int i = 0; i < questions.length; i++) {
      if (questions[i].correctAnswer == selectedAnswers[i]) {
        score += 1;
      }
    }
    return score;
  }
}
