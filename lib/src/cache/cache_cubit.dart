import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:termitty/src/cache/cache_model.dart';
import 'package:termitty/src/cache/cache_repo.dart';

part 'cache_state.dart';

class CacheCubit extends Cubit<CacheState> {
  final CacheRepository _cacheRepository;

  CacheCubit(this._cacheRepository) : super(CacheInitial());

  CacheModel loadCache() {
    emit(CacheLoaded(cache: _cacheRepository.getCache()));

    try {
      final cache = _cacheRepository.getCache();
      emit(CacheState(status: CacheStatus.loaded, cache: cache));
      return cache;
    } on Exception {
      emit(
        CacheState(
          status: CacheStatus.error,
          cache: CacheModel.empty,
          tokens: 0,
          error: Exception('Error loading cache'),
        ),
      );
      return CacheModel.empty;
    }
  }

  void addCache(CacheQuestionModel question, CacheAnswerModel answer) {
    _cacheRepository.addCache(question, answer);
    emit(
      CacheLoaded(
        cache: _cacheRepository.getCache(),
      ),
    );
  }

  void updateCache(CacheQuestionModel question, CacheAnswerModel answer) {
    _cacheRepository.updateCache(question, answer);
    emit(
      CacheLoaded(
        cache: _cacheRepository.getCache(),
      ),
    );
  }

  void removeCacheItem(CacheQuestionModel question) {
    _cacheRepository.removeCacheItem(question);
    emit(
      CacheLoaded(
        cache: _cacheRepository.getCache(),
      ),
    );
  }

  CacheAnswerModel checkCache(CacheQuestionModel question) {
    final answer = _cacheRepository.checkCache(question);
    try {
      emit(
        CacheState(
          status: CacheStatus.loaded,
          answer: answer,
        ),
      );
      return answer;
    } on Exception {
      emit(
        CacheState(
          status: CacheStatus.error,
          answer: CacheAnswerModel.empty,
          error: Exception('Error loading cache'),
        ),
      );
      return CacheAnswerModel.empty;
    }
    
  }

  Future<CacheAnswerModel> callApi({required String question}) async {
    emit(
      CacheLoading(),
    );

    try {
      final cache = _cacheRepository.getCache();
      final answer = _cacheRepository.checkCache(
        CacheQuestionModel(question: question),
      );

      if (answer.answer == '') {
        final apiAnswer = await _cacheRepository.callApi(question: question);
        // final answer = apiAnswer.answer;
        if (apiAnswer.isEmpty) {
          _cacheRepository.addCache(
            CacheQuestionModel(question: question),
            CacheAnswerModel(
              answer: answer.toString(),
              tokens: apiAnswer.tokens,
            ),
          );
        }
        emit(
          CacheState(
            status: CacheStatus.loaded,
            cache: cache,
            answer: CacheAnswerModel(
              answer: answer.toString(),
            ),
            tokens: state.tokens + apiAnswer.tokens,
          ),
        );
        return CacheAnswerModel(
          answer: answer.toString(),
        );
      } else {
        emit(
          CacheState(
            status: CacheStatus.loaded,
            cache: cache,
            answer: answer,
          ),
        );
        return answer;
      }
    } on Exception {
      emit(
        CacheState(
          status: CacheStatus.error,
          cache: CacheModel.empty,
          answer: CacheAnswerModel.empty,
          error: Exception('Error loading cache'),
        ),
      );
      return CacheAnswerModel.empty;
    }
  }
}
