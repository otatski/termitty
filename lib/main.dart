import 'package:termitty/src/platform_menu.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_acrylic/flutter_acrylic.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:termitty/src/home.dart';
import 'package:termitty/simple_bloc_observer.dart';
import 'package:termitty/src/cache/cache_cubit.dart';
import 'package:termitty/src/cache/cache_repo.dart';
import 'package:termitty/src/translate/translate_cubit.dart';
import 'package:termitty/src/mode/mode_cubit.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  Bloc.observer = SimpleBlocObserver();

  final cacheRepository = CacheRepository();

  if (isDesktop) {
    setupAcrylic();
  }

  return runApp(
    MyApp(cacheRepository: cacheRepository),
  );
}

bool get isDesktop {
  if (kIsWeb) return false;
  return [
    TargetPlatform.windows,
    TargetPlatform.linux,
    TargetPlatform.macOS,
  ].contains(defaultTargetPlatform);
}

Future<void> setupAcrylic() async {
  await Window.initialize();
  await Window.makeTitlebarTransparent();
  await Window.setEffect(effect: WindowEffect.aero, color: Color(0xFFFFFFFF));
  await Window.setBlurViewState(MacOSBlurViewState.active);
}

class MyApp extends StatelessWidget {
  const MyApp({
    required CacheRepository cacheRepository,
    super.key,
  }) : _cacheRepository = cacheRepository;

  final CacheRepository _cacheRepository;

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider.value(
      value: _cacheRepository,
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => CacheCubit(CacheRepository())..loadCache(),
          ),
          BlocProvider(
            create: (context) => TranslateCubit(),
          ),
          BlocProvider(
            create: (context) => ModeCubit(),
          ),
        ],
        child: MaterialApp(
          title: 'Termitty',
          debugShowCheckedModeBanner: false,
          home: AppPlatformMenu(child: Home()),
        ),
      ),
    );
  }
}

