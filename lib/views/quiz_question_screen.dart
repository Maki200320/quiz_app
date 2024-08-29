import 'package:flutter/material.dart';
import 'package:quiz_app/helper/database_helper.dart';
import 'package:quiz_app/models/question.dart';
import 'package:quiz_app/models/quiz.dart';

class QuizQuestionScreen extends StatefulWidget {
  final Quiz quiz;
  QuizQuestionScreen({required this.quiz});

  @override
  State<QuizQuestionScreen> createState() => _QuizQuestionScreenState();
}

class _QuizQuestionScreenState extends State<QuizQuestionScreen> {
  List<Question> questions = [];
  Map<int, int?> selectedAnswers = {};
  final database = DatabaseHelper();

  //create questions
  void _addQuestion(int quizId, String question, String choice1, String choice2,
      String choice3, int correctAnswer) async {
    Question questions = Question(
        quizId: quizId,
        question: question,
        choices: [choice1, choice2, choice3],
        correctAnswer: correctAnswer);

    await database.createQuestion(questions);
    print("Question Added...$quizId");
  }

  //ui show dialog to enter new question
  void showAddQuestionDialog(int quizId) {
    final questionController = TextEditingController();
    final choice1Controller = TextEditingController();
    final choice2Controller = TextEditingController();
    final choice3Controller = TextEditingController();
    int? correctAnswer;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add a Question'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: questionController,
                decoration: InputDecoration(labelText: 'Question'),
              ),
              TextField(
                controller: choice1Controller,
                decoration: InputDecoration(labelText: 'Choice 1'),
              ),
              TextField(
                controller: choice2Controller,
                decoration: InputDecoration(labelText: 'Choice 2'),
              ),
              TextField(
                controller: choice3Controller,
                decoration: InputDecoration(labelText: 'Choice 3'),
              ),
              DropdownButtonFormField<int>(
                value: correctAnswer,
                decoration: InputDecoration(labelText: 'Correct Answer'),
                items: const [
                  DropdownMenuItem(value: 0, child: Text('Choice 1')),
                  DropdownMenuItem(value: 1, child: Text('Choice 2')),
                  DropdownMenuItem(value: 2, child: Text('Choice 3')),
                ],
                onChanged: (value) {
                  setState(() {
                    correctAnswer = value;
                  });
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Save'),
              onPressed: () {
                _addQuestion(
                    quizId,
                    questionController.text,
                    choice1Controller.text,
                    choice2Controller.text,
                    choice3Controller.text,
                    correctAnswer!);
                Navigator.of(context).pop();
                fetchQuestions();
              },
            ),
          ],
        );
      },
    );
  }

  //fetch all questions using quiz id not question id
  void fetchQuestions() async {
    List<Question> fetchQuestions =
        await database.fetchQuestions(widget.quiz.id!);

    setState(() {
      questions = fetchQuestions;
    });
  }

  void deleteQuestion(int questionId) async {
    await database.deleteQuestion(questionId);

    print('Deleted $questionId');
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchQuestions();
  }

  // Track selected answers for each question

  void _handleRadioValueChange(int questionIndex, int? value) {
    setState(() {
      selectedAnswers[questionIndex] = value;
    });
  }

  bool isAnswerCorrect(int questionIndex) {
    final question = questions[questionIndex];
    final selectedAnswer = selectedAnswers[questionIndex];
    return selectedAnswer != null && question.correctAnswer == selectedAnswer;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: questions.isEmpty
            ? Center(child: Text("No questions yet"))
            : ListView.builder(
                itemCount: questions.length,
                itemBuilder: (context, index) {
                  final question = questions[index];
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          question.question!,
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      Column(
                        children: List.generate(question.choices.length,
                            (choiceIndex) {
                          final choice = question.choices[choiceIndex];
                          return RadioListTile<int>(
                            title: Text(choice),
                            value: choiceIndex,
                            groupValue: selectedAnswers[index],
                            onChanged: (value) {
                              _handleRadioValueChange(index, value);
                            },
                          );
                        }),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          isAnswerCorrect(index) ? 'Correct' : 'Incorrect',
                          style: TextStyle(
                            color: isAnswerCorrect(index)
                                ? Colors.green
                                : Colors.red,
                          ),
                        ),
                      ),
                      Divider(),
                    ],
                  );
                },
              ),
        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.add),
          onPressed: () {
            showAddQuestionDialog(widget.quiz.id!);
          },
        ),
      ),
    );
  }
}
