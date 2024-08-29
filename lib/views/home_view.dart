import 'package:flutter/material.dart';
import 'package:quiz_app/helper/database_helper.dart';
import 'package:quiz_app/models/question.dart';
import 'package:quiz_app/models/quiz.dart';
import 'package:quiz_app/views/quiz_question_screen.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  List<Quiz> quizes = [];
  final database = DatabaseHelper();

  @override
  void initState() {
    super.initState();
    fetchQuizes();
  }

  // Load quizzes
  void fetchQuizes() async {
    List<Quiz> quiz = await database.fetchQuiz();
    setState(() {
      quizes = quiz;
    });
  }

  // Delete a quiz
  void deleteQuiz(int quizId) async {
    await database.deleteQuiz(quizId);
    fetchQuizes(); // Refresh the list after deletion
  }

  void addQuiz() {
    TextEditingController _quizNameController = TextEditingController();
    final database = DatabaseHelper();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Quiz'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _quizNameController,
                decoration: const InputDecoration(labelText: 'Quiz Name'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                String quizName = _quizNameController.text.trim();
                if (quizName.isNotEmpty) {
                  Quiz quiz = Quiz(quizName: quizName);
                  await database.createQuiz(quiz);
                  fetchQuizes(); // Refresh the quiz list after adding a new quiz
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        backgroundColor: Colors.green,
        onPressed: () async {
          //add quiz and questions
          addQuiz();
        },
      ),
      body: quizes.isEmpty
          ? const Center(
              child: Center(
                child: Text('NO QUIZ AVAILABLE'),
              ),
            )
          : ListView.builder(
              itemCount: quizes.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(quizes[index].quizName),
                  onTap: () {
                    // Navigate to the quiz questions screen
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) {
                      return QuizQuestionScreen(
                        quiz: quizes[index],
                      );
                    }));
                  },
                  trailing: IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () {
                      deleteQuiz(quizes[index].id!);
                    },
                  ),
                );
              },
            ),
    ));
  }
}
