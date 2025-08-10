import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:new_ovacs/features/document/providers/group_details_provider.dart';
import 'package:new_ovacs/features/document/providers/upload_documents_provider.dart';
import 'common/providers/country_provider.dart';
import 'common/providers/workspace_provider.dart';
import 'common/providers/permission_provider.dart';
import 'core/utils/app_theme.dart';
import 'features/case/providers/add_case_provider.dart';
import 'features/case/providers/case_details_provider.dart';
import 'features/case/providers/cases_provider.dart';
import 'features/case/providers/assigned_accounts_provider.dart';
import 'features/client/providers/add_client_provider.dart';
import 'features/client/providers/client_details_provider.dart';
import 'features/client/providers/clients_provider.dart';
import 'features/client/providers/update_client_provider.dart';
import 'features/connection/providers/connection_provider.dart';
import 'features/connection/providers/send_invitation_provider.dart';
import 'features/dashboard/providers/dashboard_provider.dart';
import 'features/dashboard/views/navigation_menu.dart';
import 'features/document/providers/document_detail_provider.dart';
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
import 'features/case/providers/cases_search_provider.dart';
import 'features/client/providers/client_search_provider.dart';
import 'features/message/providers/edit_delete_message_provider.dart';
import 'features/message/providers/message_details_provider.dart';
import 'features/message/providers/messages_provider.dart';
import 'features/message/providers/send_message_provider.dart';
import 'features/onboarding/views/welcome_page.dart';
import 'l10n/app_localizations.dart';
import 'services/trial_service.dart';

final navigatorKey = GlobalKey<NavigatorState>();
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await setupLocator();
  final authProvider = getIt<AuthProvider>();
  await authProvider.init();
  final trialService = getIt<TrialService>();
  await trialService.init();

  runApp(MainApp(authProvider: authProvider));
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

  StatefulWidget _getInitialRoute(AuthProvider authProvider) {
    if (authProvider.accessToken != null) {
      return const NavigationMenu();
    } else {
      return const WelcomePage();
    }
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
        final workspaceProvider = getIt<WorkspaceProvider>()..init();
        final trialService = getIt<TrialService>();

        return MultiProvider(
          providers: [
            // settings
            ChangeNotifierProvider(create: (_) => themeProvider),
            ChangeNotifierProvider(create: (_) => localeProvider),
            ChangeNotifierProvider(create: (_) => workspaceProvider),
            // trial
            ChangeNotifierProvider(create: (_) => trialService),
            // auth
            ChangeNotifierProvider(create: (_) => widget.authProvider),
            ChangeNotifierProvider(
              create: (context) => getIt<CountryProvider>(),
            ),
            // permissions
            ChangeNotifierProvider(
              create: (context) => getIt<PermissionProvider>(),
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
            ChangeNotifierProvider(
              create: (context) => getIt<AssignedAccountsProvider>(),
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
              create: (context) => getIt<DocumentDetailProvider>(),
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
            ChangeNotifierProvider(
              create: (context) => getIt<SendInvitationProvider>(),
            ),
          ],
          child: Consumer3<ThemeProvider, LocaleProvider, TrialService>(
            builder: (context, themeProvider, localeProvider, trialService, _) {
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
                home: _getInitialRoute(widget.authProvider),
              );
            },
          ),
        );
      },
    );
  }
}
