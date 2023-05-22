// import 'package:flutter/services.dart';
import 'package:dart_openai/openai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_gpt_tokenizer/flutter_gpt_tokenizer.dart';
// import 'package:termitty/src/cache/cache_model.dart';

Future<Map<String, Object>> callApi({required String question}) async {
  await dotenv.load(fileName: "assets/.env");
  // print(dotenv.env['KEY']);
  print("Question: $question");

  OpenAI.apiKey = dotenv.env['KEY']!;
  
  final model = "gpt-3.5-turbo";

  final prompt = "Returning only the command, what is the Debian Linux shell command for: $question\n";

  final tokens = await Tokenizer().count(prompt, modelName: model);

  OpenAIChatCompletionModel chatCompletion = await OpenAI.instance.chat.create(
    model: model,
    messages: [
      OpenAIChatCompletionChoiceMessageModel(
        role: OpenAIChatMessageRole.user,
        content: prompt,
      ),
    ],
  );

  print('completion: ${chatCompletion.choices.first.message.content}');
  return {"answer": chatCompletion.choices.first.message.content, "tokens": tokens};
}
