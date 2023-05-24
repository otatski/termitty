import 'package:termitty/src/cache/cache_model.dart';
import 'package:dart_openai/dart_openai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_gpt_tokenizer/flutter_gpt_tokenizer.dart';

class CacheRepository {
  CacheModel cache = CacheModel(cache: {
    CacheQuestionModel(question: 'clear'): CacheAnswerModel(answer: 'clear'),
    CacheQuestionModel(question: 'exit'): CacheAnswerModel(answer: 'exit'),
    CacheQuestionModel(question: 'help'): CacheAnswerModel(answer: 'help'),
    CacheQuestionModel(question: 'history'):
        CacheAnswerModel(answer: 'history'),
    CacheQuestionModel(question: 'ls'): CacheAnswerModel(answer: 'ls'),
    CacheQuestionModel(question: 'pwd'): CacheAnswerModel(answer: 'pwd'),
    CacheQuestionModel(question: 'whoami'): CacheAnswerModel(answer: 'whoami'),
  });

  /// Returns the cache
  CacheModel getCache() {
    return cache;
  }

  /// Adds a new cache item
  void addCache(CacheQuestionModel question, CacheAnswerModel answer) {
    if (answer.answer == '') {
      return;
    }
    cache.cache[question] = answer;
  }

  /// Checks if the cache contains the question
  CacheAnswerModel checkCache(CacheQuestionModel question) {
    try {
      return cache.cache[question]!;
    } catch (e) {
      return CacheAnswerModel(answer: '');
    }
  }

  /// Updates the cache
  void updateCache(CacheQuestionModel question, CacheAnswerModel answer) {
    if (answer.answer == '') {
      return;
    }
    cache.cache[question] = answer;
  }

  /// Removes a cache item
  void removeCacheItem(CacheQuestionModel question) {
    cache.cache.remove(question);
  }

  /// Calls OpenAI API to get the answer for the question
  Future<CacheAnswerModel> callApi({required String question}) async {
    try {
      await dotenv.load(fileName: "assets/.env");
      // print(dotenv.env['KEY']);
      print("Question: $question");

      OpenAI.apiKey = dotenv.env['KEY']!;

      final model = "gpt-3.5-turbo";

      final prompt =
          "Returning only the command, what is the Debian Linux shell command for: $question\n";

      final tokens = await Tokenizer().count(prompt, modelName: model);

      OpenAIChatCompletionModel chatCompletion =
          await OpenAI.instance.chat.create(
        model: model,
        messages: [
          OpenAIChatCompletionChoiceMessageModel(
            role: OpenAIChatMessageRole.user,
            content: prompt,
          ),
        ],
      );

      print('completion: ${chatCompletion.choices.first.message.content}');
      CacheAnswerModel answer = CacheAnswerModel(answer: chatCompletion.choices.first.message.content, tokens: tokens);
      return answer;
    } catch (e) {
      print(e);
      return CacheAnswerModel(answer: '', tokens: 0);
    }
  }
}


