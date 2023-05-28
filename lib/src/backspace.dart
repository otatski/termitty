import 'package:xterm/xterm.dart';

class BackspaceHandler extends TerminalInputHandler {
  final TerminalInputHandler _inputHandler;

  BackspaceHandler(this._inputHandler);

  @override
  String? call(TerminalKeyboardEvent event) {
      print("BackspaceHandler: ${event.key}");
    return _inputHandler.call(event);
  }
}
