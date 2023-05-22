import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:termitty/src/cache/cache_model.dart';
import 'package:termitty/src/cache/cache_repo.dart';

part 'cache_state.dart';

class CacheCubit extends Cubit<CacheState> {
  final CacheRepository _cacheRepository;

  CacheCubit(this._cacheRepository) : super(CacheInitial());

  void loadCache() {
    emit(CacheLoaded(cache: _cacheRepository.getCache()));

    try {
      final cache = _cacheRepository.getCache();
      emit(CacheState(status: CacheStatus.loaded, cache: cache));
    } on Exception {
      emit(
        CacheState(
          status: CacheStatus.error,
          cache: CacheModel.empty,
          error: Exception('Error loading cache'),
        ),
      );
    }
  }

  void addCache(CacheQuestionModel question, CacheAnswerModel answer) {
    _cacheRepository.addCache(question, answer);
    emit(CacheLoaded(cache: _cacheRepository.getCache()));
  }


}
