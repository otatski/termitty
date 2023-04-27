import 'dart:convert';
import 'dart:io';

import 'package:termitty/src/platform_menu.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_acrylic/flutter_acrylic.dart';
import 'package:flutter_pty/flutter_pty.dart';
import 'package:xterm/xterm.dart';
import 'package:termitty/src/api.dart';
import 'package:termitty/src/utf8_constants.dart' as utf8;

enum Mode {
    command,
    hybrid,
    nlp
}

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  if (isDesktop) {
    setupAcrylic();
  }

  runApp(MyApp());
}

bool get isDesktop {
  if (kIsWeb) return false;
  return [
    TargetPlatform.windows,
    TargetPlatform.linux,
    TargetPlatform.macOS,
  ].contains(defaultTargetPlatform);
}

Future<void> setupAcrylic() async {
  await Window.initialize();
  await Window.makeTitlebarTransparent();
  await Window.setEffect(effect: WindowEffect.aero, color: Color(0xFFFFFFFF));
  await Window.setBlurViewState(MacOSBlurViewState.active);
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Termitty',
      debugShowCheckedModeBanner: false,
      home: AppPlatformMenu(child: Home()),
      // shortcuts: ,
    );
  }
}

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

  var buff = StringBuffer();

  late final Pty pty;

  var mode = Mode.command;

  @override
  void initState() {
    super.initState();

   mode = Mode.command; 

    WidgetsBinding.instance.endOfFrame.then(
      (_) {
        if (mounted) _startPty();
      },
    );
  } 

  void changeMode() {
      setState(() {
        // Sets the mode to the next one in the enum
        mode = Mode.values[(mode.index + 1) % Mode.values.length];
      });
  }

    void _startPty() {
      pty = Pty.start(
        shell,
        columns: terminal.viewWidth,
        rows: terminal.viewHeight,
      );

      pty.output
          .cast<List<int>>()
          .transform(Utf8Decoder())
          .listen((text) {
            terminal.write(text);
            // print("Buffer: ${terminal.mainBuffer}");
          });

      pty.exitCode.then((code) {
        terminal.write('the process exited with exit code $code');
        exit(code);
      });

      terminal.onOutput = (data) {
        var out = const Utf8Encoder().convert(data);

        switch(out[out.length - 1]) {
          case utf8.backspace:
            // Remove the Backspace character
            buff.write(buff.toString().substring(0, buff.length - 1));
            // Remove the last character that would be removed by the Backspace character
            buff.write(buff.toString().substring(0, buff.length - 1));
            break;
          case utf8.carriageReturn:
            callApi(question: buff.toString());
            buff.clear();
            break;
          default:
            buff.write(data);
        }

        pty.write(const Utf8Encoder().convert(data));
      };

      terminal.onResize = (w, h, pw, ph) {
        pty.resize(h, w);
      };
    }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent, 
      body: SafeArea(
      child: RawKeyboardListener(
        focusNode: FocusNode(),
        onKey: (event) {
          if (event is RawKeyUpEvent &&
            event.logicalKey == LogicalKeyboardKey.keyM &&
            event.isControlPressed) {
            // create a new tab here
            changeMode();
            terminal.write('Mode: ${mode.toString()}');
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

String get shell {
  if (Platform.isMacOS || Platform.isLinux) {
    return Platform.environment['SHELL'] ?? 'bash';
  }

  if (Platform.isWindows) {
    return 'cmd.exe';
  }

  return 'sh';
}
