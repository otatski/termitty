import 'package:termitty/src/platform_menu.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_acrylic/flutter_acrylic.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:termitty/src/home.dart';
import 'package:termitty/simple_bloc_observer.dart';
import 'package:termitty/src/cache/cache_cubit.dart';
import 'package:termitty/src/cache/cache_repo.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  Bloc.observer = SimpleBlocObserver();

  if (isDesktop) {
    setupAcrylic();
  }

  return runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => CacheCubit(CacheRepository())..loadCache(),
        ),
      ],
      child: MyApp(),
    ),
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
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Termitty',
      debugShowCheckedModeBanner: false,
      home: AppPlatformMenu(child: Home()),
      // shortcuts: ,
    );
  }
}

