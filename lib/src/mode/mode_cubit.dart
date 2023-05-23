import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'mode_state.dart';

class ModeCubit extends Cubit<ModeState> {
  ModeCubit() : super(ModeInitial());

  void command() {
    emit(ModeCommand());
  }

  void hybrid() {
    emit(ModeHybrid());
  }

  void nlp() {
    emit(ModeNlp());
  }

  void changeMode() {
    state.status == ModeStatus.command
        ? emit(ModeHybrid())
        : state.status == ModeStatus.hybrid
            ? emit(ModeNlp())
            : emit(ModeCommand());
  }

  ModeStatus get status => state.status;

  bool get commandMode => state.status == ModeStatus.command;

  bool get hybridMode => state.status == ModeStatus.hybrid;

  bool get nlpMode => state.status == ModeStatus.nlp;
}
