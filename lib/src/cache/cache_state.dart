part of 'cache_cubit.dart';

enum CacheStatus { initial, loaded, error }

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
  CacheInitial() : super();
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



