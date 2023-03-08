import 'package:flutter_gen/gen_l10n/l10n.dart';


/// This class is used to represent a question.
/// ech question has a question text, 4 answer texts and a correct answer
class Question {
  String questionText;
  String answerText01;
  String answerText02;
  String answerText03;
  String answerText04;
  int correctAnswer;

  Question(this.questionText, this.answerText01, this.answerText02, this.answerText03, this.answerText04, this.correctAnswer);

  /// returns the correct answer as a string
  String getRealAnswer(context){
    switch (correctAnswer) {
      case 1:
        return answerText01;
      case 2:
        return answerText02;
      case 3:
        return answerText03;
      case 4:
        return answerText04;
      default:// this can happen if the question answer is not set correctly
        return AppLocalizations.of(context)!.answerIndexOutOfBound;
    }
  }

  /// returns a string with all the incorrect answer
  String getWrongAnswers(){
    String wrongAnswers = "";
    if(correctAnswer != 1){
      wrongAnswers += "$answerText01, ";
    }
    if(correctAnswer != 2){
      wrongAnswers += "$answerText02, ";
    }
    if(correctAnswer != 3){
      wrongAnswers += "$answerText03, ";
    }
    if(correctAnswer != 4){
      wrongAnswers += "$answerText04, ";
    }
    return wrongAnswers.substring(0, wrongAnswers.length - 2);
  }

  @override
  String toString(){
    return "questionText: $questionText\n answerText01: $answerText01\n answerText02: $answerText02\n answerText03: $answerText03\n answerText04: $answerText04\n correctAnswer: $correctAnswer";
  }
}