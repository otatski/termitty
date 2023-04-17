// import 'package:flutter/services.dart';
import 'package:dart_openai/openai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> callApi({required String question}) async {
    await dotenv.load(fileName: "assets/.env");
    // print(dotenv.env['KEY']);

    OpenAI.apiKey = dotenv.env['KEY']!;

    final completion = await OpenAI.instance.completion.create(
        model: 'text-davinci-003',
        prompt: "Given a description of an action, provide the corresponding Linux shell command. Here are some examples:\n\n"
            "Action: List files\n"
            "Command: ls\n\n"
            "Action: Change directory to /home/user\n"
            "Command: cd /home/user\n\n"
            "Action: Print the contents of the file foo.txt\n"
            "Command: cat foo.txt\n\n"
            "Action: Make a new directory named foo\n"
            "Command: mkdir foo\n\n"
            "Action: Remove the file foo.txt\n"
            "Command: rm foo.txt\n\n"
            "Now, provide the Linux shell command for the following action:\n\n"
            "Action: $question\n\n"
            "Command: ",
        temperature: 0.1,
        maxTokens: 15,
        topP: 1,
        frequencyPenalty: 0,
        presencePenalty: 0,
    );
    
    print('completion: ${completion.choices[0].text}');

}
