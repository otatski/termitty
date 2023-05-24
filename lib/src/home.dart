import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_pty/flutter_pty.dart';
// import 'package:termitty/src/api.dart';
import 'package:termitty/src/cache/cache_model.dart';
import 'package:termitty/src/utf8_constants.dart' as utf8;
import 'package:xterm/xterm.dart';
import 'package:termitty/src/shell.dart';
import 'package:termitty/src/cache/cache_cubit.dart';
import 'package:termitty/src/mode/mode_cubit.dart';
import 'package:termitty/src/translate/translate_cubit.dart';

// import 'package:termitty/src/pty/pty.dart';

class Home extends StatefulWidget {
  Home({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final terminal = Terminal(
    maxLines: 10000,
  );

  final terminalController = TerminalController();

  // StringBuffer buff = StringBuffer();

  late final Pty pty;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.endOfFrame.then(
      (_) {
        if (mounted) startPty(context);
      },
    );
  }

  void startPty(BuildContext context) {
    // CacheRepository cacheRepository = RepositoryProvider.of<CacheRepository>(context);
    // final cache = context.read<CacheCubit>();
    final cache = BlocProvider.of<CacheCubit>(context);
    // final mode = context.read<ModeCubit>();
    final mode = BlocProvider.of<ModeCubit>(context);
    // final translate = context.read<TranslateCubit>();
    final translate = BlocProvider.of<TranslateCubit>(context);

    final terminal = Terminal(
      maxLines: 10000,
    );

    late final Pty pty;

    pty = Pty.start(
      shell,
      columns: terminal.viewWidth,
      rows: terminal.viewHeight,
    );

    StringBuffer buff = StringBuffer();

    pty.output.cast<List<int>>().transform(Utf8Decoder()).listen((text) {
      terminal.write(text);
      // print("Buffer: ${terminal.mainBuffer}");
    });

    pty.exitCode.then((code) {
      terminal.write('the process exited with exit code $code');
      exit(code);
    });

    terminal.onOutput = (data) async {
      var out = const Utf8Encoder().convert(data);

      switch (out[out.length - 1]) {
        case utf8.backspace:
          // Remove the Backspace character
          buff.write(buff.toString().substring(0, buff.length - 1));
          // Remove the last character that would be removed by the Backspace character
          buff.write(buff.toString().substring(0, buff.length - 1));
          break;
        case utf8.carriageReturn:
          print("Buffer: ${buff.toString()} | Length: ${buff.length}"); // Debug
          if (!mode.commandMode && translate.isTranslate) {
            if (buff.length == 0) {
              buff.clear();
              break;
            }
            await cache.callApi(question: data);
            // final answer = cache.state.answer;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                duration: Duration(seconds: 10),
                content: Text(
                  cache.state.answer.toString(),
                ),
                action: SnackBarAction(
                  label: 'Copy',
                  onPressed: () {
                    Clipboard.setData(
                      ClipboardData(
                        text: cache.state.answer.toString(),
                      ),
                    );
                    translate.dontTranslate();
                  },
                ),
              ),
            );
            if (cache
                .checkCache(CacheQuestionModel(question: buff.toString()))
                .isNotEmpty) {
              cache.addCache(
                CacheQuestionModel(
                  question: buff.toString(),
                ),
                CacheAnswerModel(
                  answer: cache.state.answer.toString(),
                ),
              );
            }
            buff.clear();
          } else if (!mode.commandMode && !translate.isTranslate) {
            // translateOn();
            translate.doTranslate();
            buff.clear();
          }
          break;
        default:
          buff.write(data);
        // print("Buffer: ${buff.toString()}"); // Debug
      }
      pty.write(const Utf8Encoder().convert(data));
      // print("Data: $data"); // Debug
    };

    terminal.onResize = (w, h, pw, ph) {
      pty.resize(h, w);
    };
  }

  @override
  Widget build(BuildContext context) {
    final cache = context.watch<CacheCubit>().state;
    final mode = context.watch<ModeCubit>().state;
    final translate = context.watch<TranslateCubit>().state;
    return Scaffold(
      bottomSheet: Container(
        height: 30,
        color: Colors.blueGrey,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: EdgeInsets.only(left: 10),
              child: BlocBuilder(
                builder: (context, modeState) {
                  return Text(
                    mode.status.toString().split('.').last.toUpperCase(),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: EdgeInsets.only(right: 10),
              child: BlocBuilder(
                builder: (context, translateState) {
                  return Text(
                    'Translate: ${translate.translate ? 'On' : 'Off'}',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: RawKeyboardListener(
          focusNode: FocusNode(),
          onKey: (event) {
            if (event is RawKeyUpEvent &&
                event.logicalKey == LogicalKeyboardKey.keyM &&
                event.isControlPressed) {
              // changeMode();
              context.read<ModeCubit>().changeMode();
              // Clear the buffer
              // buff.clear();
            }
            if (event is RawKeyUpEvent &&
                event.logicalKey == LogicalKeyboardKey.keyN &&
                event.isControlPressed) {
              showDialog(
                context: context,
                builder: (context) {
                  return SimpleDialog(
                    title: Center(
                      child: Text('Termitty'),
                    ),
                    children: [
                      Padding(
                        padding: EdgeInsets.all(10),
                        child: SizedBox(
                          width: MediaQuery.of(context).size.width / 2,
                          height: MediaQuery.of(context).size.height / 2,
                          child: GridView.count(
                            primary: false,
                            padding: const EdgeInsets.all(20),
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                            crossAxisCount: 2,
                            children: <Widget>[
                              Container(
                                padding: const EdgeInsets.all(8),
                                color: Colors.teal[100],
                                child: Column(
                                  children: [
                                    Text(
                                      'Amount of tokens used for translation, this session: ${cache.tokens.toString()}',
                                    ),
                                    const Spacer(),
                                    const Text(
                                      'Total cost of all translation, this session:',
                                    ),
                                    // $0.002 / 1K tokens
                                    Text(
                                      "\$${((cache.tokens / 1000) * 0.002).toStringAsFixed(4)}",
                                    ),
                                    const Spacer(),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.all(8),
                                color: Colors.teal[200],
                                child: ListView.builder(
                                  itemCount: cache.cache.length,
                                  itemBuilder: (context, index) {
                                    return ListTile(
                                      title: Text(
                                        cache.cache.getCache.keys
                                            .elementAt(index)
                                            .toString(),
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      subtitle: Text(
                                        cache.cache.getCache.values
                                            .elementAt(index)
                                            .toString(),
                                      ),
                                      trailing: IconButton(
                                        icon: Icon(
                                          Icons.delete,
                                          color: Colors.red,
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            cache.cache.remove(
                                              cache.cache.getCache.keys
                                                  .elementAt(index),
                                            );
                                          });
                                        },
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                },
              );
              // Clear the buffer
              // buff.clear();
            }
          },
          child: TerminalView(
            terminal,
            controller: terminalController,
            autofocus: true,
            backgroundOpacity: 0.7,
            onSecondaryTapDown: (details, offset) async {
              final selection = terminalController.selection;
              if (selection != null) {
                final text = terminal.buffer.getText(selection);
                terminalController.clearSelection();
                await Clipboard.setData(ClipboardData(text: text));
              } else {
                final data = await Clipboard.getData('text/plain');
                final text = data?.text;
                if (text != null) {
                  terminal.paste(text);
                }
              }
            },
          ),
        ),
      ),
    );
  }
}
