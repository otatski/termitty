import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'translate_state.dart';

class TranslateCubit extends Cubit<TranslateState> {
  TranslateCubit() : super(TranslateInitial());

  void doTranslate() {
    emit(TranslateDo());
  }

  void dontTranslate() {
    emit(TranslateDont());
  }

  bool get translate => state.translate;

  TranslateStatus get status => state.status;

  bool get isTranslate => state.status == TranslateStatus.doTranslate;

  bool get isDontTranslate => state.status == TranslateStatus.dontTranslate;

}


