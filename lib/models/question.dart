class Question {
  int? id;
  int? quizId;
  String? question;
  List<String> choices;
  int? correctAnswer;

  Question({
    this.id,
    required this.quizId,
    required this.question,
    required this.choices,
    required this.correctAnswer,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'quizId': quizId,
      'question': question,
      'choice1': choices[0],
      'choice2': choices[1],
      'choice3': choices[2],
      'correctAnswer': correctAnswer,
    };
  }

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      id: json['id'],
      quizId: json['quizId'],
      question: json['question'],
      choices: [
        json['choice1'],n 
        json['choice2'],
        json['choice3'],
      ],
      correctAnswer: json['correctAnswer'],
    );
  }
}
