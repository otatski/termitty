part of 'mode_cubit.dart';

enum ModeStatus { command, hybrid, nlp }

class ModeState extends Equatable {
  final ModeStatus status;
  final bool command;
  final bool hybrid;
  final bool nlp;

  ModeState({
    this.status = ModeStatus.command,
    bool? command,
    bool? hybrid,
    bool? nlp,
  })  : command = command ?? false,
        hybrid = hybrid ?? false,
        nlp = nlp ?? false;

  @override
  List<Object> get props => [command, hybrid, nlp];
}

class ModeInitial extends ModeState {
  ModeInitial() : super(status: ModeStatus.command);
}

class ModeCommand extends ModeState {
  ModeCommand() : super(status: ModeStatus.command);
}

class ModeHybrid extends ModeState {
  ModeHybrid() : super(status: ModeStatus.hybrid);
}

class ModeNlp extends ModeState {
  ModeNlp() : super(status: ModeStatus.nlp);
}
