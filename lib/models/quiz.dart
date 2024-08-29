

class Quiz {
  int? id;
  String quizName = "";

  Quiz({this.id, required this.quizName});

  Map<String, dynamic> toMap() {
    return {'id': id, 'quizName': quizName};
  }

  factory Quiz.fromJson(Map<String, dynamic> json) {
    return Quiz(id: json['id'], quizName: json['quizName']);
  }
}
