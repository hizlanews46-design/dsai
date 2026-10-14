import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:nexus_comm/l10n/app_localizations.dart';
import 'core/theme/nexus_theme.dart';
import 'features/auth/auth_cubit.dart';
import 'features/auth/auth_screen.dart';
import 'features/auth/auth_state.dart';
import 'features/chats/chats_cubit.dart';
import 'features/dialer/dialer_cubit.dart';
import 'features/locale/locale_cubit.dart';
import 'features/locale/locale_state.dart';
import 'features/mesh/mesh_cubit.dart';
import 'features/settings/settings_cubit.dart';
import 'features/shell/main_navigation_screen.dart';

class NexusApp extends StatelessWidget {
  const NexusApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => LocaleCubit()..load()),
        BlocProvider(create: (_) => SettingsCubit()..load()),
        BlocProvider(create: (_) => AuthCubit()..bootstrap()),
        BlocProvider(create: (_) => ChatsCubit()),
        BlocProvider(create: (_) => MeshCubit()),
        BlocProvider(create: (_) => DialerCubit()),
      ],
      child: BlocBuilder<LocaleCubit, LocaleState>(
        builder: (context, localeState) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: NexusTheme.dark(),
            darkTheme: NexusTheme.dark(),
            themeMode: ThemeMode.dark,
            locale: localeState.locale,
            supportedLocales: AppLocalizations.supportedLocales,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            home: BlocBuilder<AuthCubit, AuthState>(
              builder: (context, auth) {
                if (auth.status == AuthStatus.authenticated) {
                  return const MainNavigationScreen();
                }
                if (auth.status == AuthStatus.unknown) {
                  return const Scaffold(body: Center(child: CircularProgressIndicator()));
                }
                return const AuthScreen();
              },
            ),
          );
        },
      ),
    );
  }
}
