import 'dart:io';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_pty/flutter_pty.dart';
import 'package:termitty/src/cache/cache_cubit.dart';
import 'package:termitty/src/mode/mode_cubit.dart';
import 'package:termitty/src/translate/translate_cubit.dart';
import 'package:termitty/src/api.dart';
import 'package:termitty/src/cache/cache_model.dart';
import 'package:termitty/src/utf8_constants.dart' as utf8;
import 'package:xterm/xterm.dart';
import 'package:termitty/src/shell.dart';


void startPty(BuildContext context) {
  final terminal = Terminal(
    maxLines: 10000,
  );

  late final Pty pty;

  Mode mode = Mode.command;

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
        if (mode != Mode.command && translate) {
          if (buff.length == 0) {
            buff.clear();
            break;
          }
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              duration: Duration(seconds: 10),
              content: Text(answer['answer'].toString()),
              action: SnackBarAction(
                label: 'Copy',
                onPressed: () {
                  Clipboard.setData(
                    ClipboardData(
                      text: answer['answer'].toString(),
                    ),
                  );
                  translateOff();
                },
              ),
            ),
          );
          if (cache.containsKey(buff.toString())) {
            // cache[buff.toString()] = answer['answer'].toString();
            addToCache(buff.toString(), answer['answer'].toString());
          } else {
            setState(() {
              cache.addAll(
                {buff.toString(): answer['answer'].toString()},
              );
            });
          }
          buff.clear();
        } else if (mode != Mode.command && !translate) {
          translateOn();
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
