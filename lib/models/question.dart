class Question {
  int? id;
  int? quizId;
  String? question;
  List<String>? choices;
  int? correctAnswer;

  Question(
      {required this.id,
      required this.quizId,
      required this.question,
      required this.choices,
      required this.correctAnswer});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'quizId': quizId,
      'question': question,
      'choices': choices,
      'correctAnswer': correctAnswer
    };
  }

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
        id: json['id'],
        quizId: json['quizId'],
        question: json['question'],
        choices: json['choices'],
        correctAnswer: json['correctAnswer']);
  }
}
