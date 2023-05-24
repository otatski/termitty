import 'package:equatable/equatable.dart';

class CacheModel extends Equatable {
  final Map<CacheQuestionModel, CacheAnswerModel> cache;

  CacheModel({
    required this.cache,
  });

  @override
  List<Object> get props => [
        cache,
      ];

  CacheModel copyWith({
    Map<CacheQuestionModel, CacheAnswerModel>? cache,
  }) {
    return CacheModel(
      cache: cache ?? this.cache,
    );
  }

  bool get isEmpty => cache.isEmpty;

  bool get isNotEmpty => cache.isNotEmpty;

  int get length => cache.length;

  Map<CacheQuestionModel, CacheAnswerModel> get getCache => cache;

  Map<CacheQuestionModel, CacheAnswerModel> theCache() {
    return cache;
  }

  static CacheModel get empty => CacheModel(cache: {});

  static CacheModel emptyCache() {
    return CacheModel(
      cache: {},
    );
  }

  static CacheModel newCache() {
    return CacheModel(
      cache: cacheDefault,
    );
  }

  void add(CacheQuestionModel question, CacheAnswerModel answer) {
    cache[question] = answer;
  }

  void remove(CacheQuestionModel question) {
    cache.remove(question);
  }

  void clear() {
    cache.clear();
  }

  bool containsKey(CacheQuestionModel question) {
    return cache.containsKey(question);
  }

  bool containsValue(CacheAnswerModel answer) {
    return cache.containsValue(answer);
  }

  CacheAnswerModel? operator [](CacheQuestionModel question) {
    return cache[question];
  }

  void operator []=(CacheQuestionModel question, CacheAnswerModel answer) {
    cache[question] = answer;
  }

}

class CacheQuestionModel extends Equatable {
  final String question;

  CacheQuestionModel({
    required this.question,
  });

  @override
  List<Object> get props => [
        question,
      ];

  CacheQuestionModel copyWith({
    String? question,
  }) {
    return CacheQuestionModel(
      question: question ?? this.question,
    );
  }

  bool get isEmpty => question.isEmpty;

  bool get isNotEmpty => question.isNotEmpty;

  int get length => question.length;

  String get getQuestion => question;

  static CacheQuestionModel get empty => CacheQuestionModel(question: '');

  static CacheQuestionModel emptyQuestion() {
    return CacheQuestionModel(
      question: '',
    );
  }
}

class CacheAnswerModel extends Equatable {
  final String answer;
  final int tokens;

  CacheAnswerModel({
    required this.answer,
    this.tokens = 0,
  });

  @override
  List<Object> get props => [
        answer,
        tokens,
      ];

  CacheAnswerModel copyWith({
    String? answer,
    int? tokens,
  }) {
    return CacheAnswerModel(
      answer: answer ?? this.answer,
      tokens: tokens ?? this.tokens,
    );
  }

  bool get isEmpty => answer.isEmpty;

  bool get isNotEmpty => answer.isNotEmpty;

  int get length => answer.length;

  int get getTokens => tokens;

  String get getAnswer => answer;

  static CacheAnswerModel get empty => CacheAnswerModel(answer: '');

  static CacheAnswerModel emptyAnswer() {
    return CacheAnswerModel(
      answer: '',
    );
  }

}

Map<CacheQuestionModel, CacheAnswerModel> cacheDefault = {
  CacheQuestionModel(question: 'clear'): CacheAnswerModel(answer: 'clear'),
  CacheQuestionModel(question: 'exit'): CacheAnswerModel(answer: 'exit'),
  CacheQuestionModel(question: 'help'): CacheAnswerModel(answer: 'help'),
  CacheQuestionModel(question: 'history'): CacheAnswerModel(answer: 'history'),
  CacheQuestionModel(question: 'ls'): CacheAnswerModel(answer: 'ls'),
  CacheQuestionModel(question: 'pwd'): CacheAnswerModel(answer: 'pwd'),
  CacheQuestionModel(question: 'whoami'): CacheAnswerModel(answer: 'whoami'),
};
