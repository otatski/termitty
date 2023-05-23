part of 'translate_cubit.dart';

enum TranslateStatus { doTranslate, dontTranslate }

class TranslateState extends Equatable {
  final TranslateStatus status;
  final bool translate;

  TranslateState({
    this.status = TranslateStatus.dontTranslate,
    bool? translate,
  }) : translate = translate ?? false;

  @override
  List<Object> get props => [translate];
}

class TranslateInitial extends TranslateState {
  TranslateInitial() : super(status: TranslateStatus.dontTranslate);
}

class TranslateDo extends TranslateState {
  TranslateDo() : super(status: TranslateStatus.doTranslate);
}

class TranslateDont extends TranslateState {
  TranslateDont() : super(status: TranslateStatus.dontTranslate);
}
