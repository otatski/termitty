// import 'package:flutter/services.dart';
import 'package:dart_openai/openai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<String> callApi({required String question}) async {
    await dotenv.load(fileName: "assets/.env");
    // print(dotenv.env['KEY']);
    print("Question: $question");

    OpenAI.apiKey = dotenv.env['KEY']!;

    // final completion = await OpenAI.instance.completion.create(
        // model: 'text-davinci-003',
        // prompt: "Convert natural language to shell commands for the Debian Linux operating system. Only show the commands.\n\nUser: list files\nAI: ls\nUser: change directory\nAI: cd",
        // temperature: 0.1,
        // maxTokens: 15,
        // topP: 1,
        // frequencyPenalty: 0,
        // presencePenalty: 0,
    // );
    
    // print('completion: ${completion.choices[0].text}');

    OpenAIChatCompletionModel chatCompletion = await OpenAI.instance.chat.create(
        model: "gpt-3.5-turbo",
        messages: [
            OpenAIChatCompletionChoiceMessageModel(
            role: OpenAIChatMessageRole.user,
            content: "Giving only the command, what is the Debian Linux shell command for: $question",
            ),
        ],
    );

    print('completion: ${chatCompletion.choices.first.message.content}');
    return chatCompletion.choices.first.message.content;

}
