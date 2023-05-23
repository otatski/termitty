part of 'cache_cubit.dart';

enum CacheStatus { initial, loaded, loading, fetching, error }

class CacheState extends Equatable {
  final CacheStatus status;
  final CacheModel cache;
  final Exception? error;

  CacheState({
    this.status = CacheStatus.initial,
    CacheModel? cache,
    this.error,
  }) : cache = cache ?? CacheModel.empty;

  @override
  List<Object> get props => [];
}

class CacheInitial extends CacheState {
  CacheInitial() : super(status: CacheStatus.initial);
}

class CacheLoading extends CacheState {
  CacheLoading() : super(status: CacheStatus.loading);
}

class CacheFetching extends CacheState {
  CacheFetching() : super(status: CacheStatus.fetching);
}

class CacheLoaded extends CacheState {
  CacheLoaded({required CacheModel cache})
      : super(
          status: CacheStatus.loaded,
          cache: cache,
        );

  @override
  List<Object> get props => [cache];

  CacheLoaded copyWith({
    CacheModel? cache,
  }) {
    return CacheLoaded(
      cache: cache ?? this.cache,
    );
  }
}



