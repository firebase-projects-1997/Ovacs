import 'dart:io';

import 'package:device_preview/device_preview.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:new_ovacs/features/document/providers/group_details_provider.dart';
import 'package:new_ovacs/features/document/providers/upload_documents_provider.dart';
import 'common/providers/country_provider.dart';
import 'core/constants/app_routes.dart';
import 'core/utils/app_theme.dart';
import 'features/auth/views/login_page.dart';
import 'features/case/provider/add_case_provider.dart';
import 'features/case/provider/case_details_provider.dart';
import 'features/case/provider/cases_provider.dart';
import 'features/client/providers/add_client_provider.dart';
import 'features/client/providers/client_details_provider.dart';
import 'features/client/providers/clients_provider.dart';
import 'features/client/providers/update_client_provider.dart';
import 'features/client/views/add_client_page.dart';
import 'features/connection/providers/connection_provider.dart';
import 'features/dashboard/providers/dashboard_provider.dart';
import 'features/dashboard/views/navigation_menu.dart';
import 'features/document/providers/documents_provider.dart';
import 'features/document/providers/groups_provider.dart';
import 'features/session/providers/add_session_provider.dart';
import 'features/session/providers/session_details_provider.dart';
import 'features/session/providers/sessions_provider.dart';
import 'package:provider/provider.dart';

import 'common/providers/locale_provider.dart';
import 'common/providers/theme_provider.dart';
import 'core/di/injection.dart';
import 'features/auth/providers/auth_provider.dart';
import 'features/auth/views/forget_password_page.dart';
import 'features/auth/views/register_page.dart';
import 'features/case/provider/cases_search_provider.dart';
import 'features/client/providers/client_search_provider.dart';
import 'features/dashboard/views/dashboard_page.dart';
import 'features/message/providers/edit_delete_message_provider.dart';
import 'features/message/providers/message_details_provider.dart';
import 'features/message/providers/messages_provider.dart';
import 'features/message/providers/send_message_provider.dart';
import 'features/onboarding/views/welcome_page.dart';
import 'l10n/app_localizations.dart';

final navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await setupLocator();

  final authProvider = getIt<AuthProvider>();
  await authProvider.init();

  runApp(
    DevicePreview(
      enabled: kIsWeb || Platform.isWindows,
      builder: (context) => MainApp(authProvider: authProvider),
    ),
  );
}

class MainApp extends StatefulWidget {
  final AuthProvider authProvider;

  const MainApp({super.key, required this.authProvider});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  late Future<void> _initFuture;

  @override
  void initState() {
    super.initState();
    _initFuture = widget.authProvider.init();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _initFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const MaterialApp(
            home: Scaffold(body: Center(child: CircularProgressIndicator())),
          );
        }

        final themeProvider = getIt<ThemeProvider>()..init();
        final localeProvider = getIt<LocaleProvider>()..init();

        return MultiProvider(
          providers: [
            // settings
            ChangeNotifierProvider(create: (_) => themeProvider),
            ChangeNotifierProvider(create: (_) => localeProvider),
            // auth
            ChangeNotifierProvider(create: (_) => widget.authProvider),
            ChangeNotifierProvider(
              create: (context) => getIt<CountryProvider>(),
            ),
            // dashboard
            ChangeNotifierProvider(
              create: (context) => getIt<DashboardProvider>(),
            ),
            // clients
            ChangeNotifierProvider(
              create: (context) => getIt<ClientsProvider>(),
            ),
            ChangeNotifierProvider(
              create: (context) => getIt<AddClientProvider>(),
            ),
            ChangeNotifierProvider(
              create: (context) => getIt<UpdateClientProvider>(),
            ),
            ChangeNotifierProvider(
              create: (context) => getIt<ClientDetailProvider>(),
            ),
            ChangeNotifierProvider(
              create: (context) => getIt<ClientsSearchProvider>(),
            ),
            //cases
            ChangeNotifierProvider(create: (context) => getIt<CasesProvider>()),
            ChangeNotifierProvider(
              create: (context) => getIt<AddCaseProvider>(),
            ),
            ChangeNotifierProvider(
              create: (context) => getIt<CasesSearchProvider>(),
            ),
            ChangeNotifierProvider(
              create: (context) => getIt<CaseDetailProvider>(),
            ),
            // sessions
            ChangeNotifierProvider(
              create: (context) => getIt<SessionsProvider>(),
            ),
            ChangeNotifierProvider(
              create: (context) => getIt<AddSessionProvider>(),
            ),
            ChangeNotifierProvider(
              create: (context) => getIt<SessionDetailProvider>(),
            ),
            // messages
            ChangeNotifierProvider(
              create: (context) => getIt<AllMessagesProvider>(),
            ),
            ChangeNotifierProvider(
              create: (context) => getIt<EditDeleteMessageProvider>(),
            ),
            ChangeNotifierProvider(
              create: (context) => getIt<MessageDetailProvider>(),
            ),
            ChangeNotifierProvider(
              create: (context) => getIt<SendMessageProvider>(),
            ),

            // documents
            ChangeNotifierProvider(
              create: (context) => getIt<DocumentsProvider>(),
            ),
            ChangeNotifierProvider(
              create: (context) => getIt<UploadDocumentsProvider>(),
            ),
            ChangeNotifierProvider(
              create: (context) => getIt<GroupsProvider>(),
            ),
            ChangeNotifierProvider(
              create: (context) => getIt<GroupDetailsProvider>(),
            ),
            // connections
            ChangeNotifierProvider(
              create: (context) => getIt<ConnectionProvider>(),
            ),
          ],
          child: Consumer2<ThemeProvider, LocaleProvider>(
            builder: (context, themeProvider, localeProvider, _) {
              return MaterialApp(
                navigatorKey: navigatorKey,
                debugShowCheckedModeBanner: false,
                locale: localeProvider.locale,
                supportedLocales: const [Locale('en'), Locale('ar')],
                localizationsDelegates: [
                  AppLocalizations.delegate,
                  GlobalMaterialLocalizations.delegate,
                  GlobalWidgetsLocalizations.delegate,
                  GlobalCupertinoLocalizations.delegate,
                ],
                theme: themeProvider.isDarkMode
                    ? AppTheme.darkTheme(
                        context,
                        fontFamily: localeProvider.locale.languageCode == 'en'
                            ? 'Poppins'
                            : 'Fustat',
                        primaryColor: themeProvider.primaryColor,
                      )
                    : AppTheme.lightTheme(
                        context,
                        fontFamily: localeProvider.locale.languageCode == 'en'
                            ? 'Poppins'
                            : 'Fustat',
                        primaryColor: themeProvider.primaryColor,
                      ),
                initialRoute: '/',
                routes: {
                  '/': widget.authProvider.accessToken != null
                      ? (context) => const NavigationMenu()
                      : (context) => const WelcomePage(),
                  AppRoutes.loginRoute: (_) => const LoginPage(),
                  AppRoutes.navigationMenuRoute: (_) => const NavigationMenu(),
                  AppRoutes.forgetPasswordRoute: (_) =>
                      const ForgetPasswordPage(),
                  AppRoutes.registerRoute: (_) => const RegisterPage(),
                  AppRoutes.homeRoute: (_) => const DashboardPage(),
                  AppRoutes.addClientRoute: (_) => const AddNewClientPage(),
                },
              );
            },
          ),
        );
      },
    );
  }
}
