import 'package:get_it/get_it.dart';
import 'package:new_ovacs/common/providers/country_provider.dart';
import 'package:new_ovacs/core/network/dio_client.dart';
import 'package:new_ovacs/core/network/app_interceptors.dart';
import 'package:new_ovacs/data/repositories/auth_repository.dart';
import 'package:new_ovacs/data/repositories/case_repository.dart';
import 'package:new_ovacs/data/repositories/client_dashboard.dart';
import 'package:new_ovacs/data/repositories/connection_repository.dart';
import 'package:new_ovacs/data/repositories/dashboard_repository.dart';
import 'package:new_ovacs/data/repositories/document_repository.dart';
import 'package:new_ovacs/data/repositories/message_repository.dart';
import 'package:new_ovacs/data/repositories/session_repository.dart';
import 'package:new_ovacs/features/case/provider/add_case_provider.dart';
import 'package:new_ovacs/features/case/provider/case_details_provider.dart';
import 'package:new_ovacs/features/case/provider/cases_provider.dart';
import 'package:new_ovacs/features/case/providers/assigned_accounts_provider.dart';
import 'package:new_ovacs/features/client/providers/add_client_provider.dart';
import 'package:new_ovacs/features/client/providers/client_details_provider.dart';
import 'package:new_ovacs/features/client/providers/clients_provider.dart';
import 'package:new_ovacs/features/client/providers/update_client_provider.dart';
import 'package:new_ovacs/features/dashboard/providers/dashboard_provider.dart';
import 'package:new_ovacs/features/document/providers/documents_provider.dart';
import 'package:new_ovacs/features/document/providers/group_details_provider.dart';
import 'package:new_ovacs/features/document/providers/groups_provider.dart';
import 'package:new_ovacs/features/message/providers/messages_provider.dart';
import 'package:new_ovacs/features/session/providers/add_session_provider.dart';
import 'package:new_ovacs/features/session/providers/session_details_provider.dart';
import 'package:new_ovacs/features/session/providers/sessions_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../common/providers/locale_provider.dart';
import '../../common/providers/theme_provider.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../../features/case/provider/cases_search_provider.dart';
import '../../features/client/providers/client_search_provider.dart';
import '../../features/connection/providers/connection_provider.dart';
import '../../features/connection/providers/send_invitation_provider.dart';
import '../../features/document/providers/upload_documents_provider.dart';
import '../../features/message/providers/edit_delete_message_provider.dart';
import '../../features/message/providers/message_details_provider.dart';
import '../../features/message/providers/send_message_provider.dart';
import '../../services/storage_service.dart';

final getIt = GetIt.instance;

Future<void> setupLocator() async {
  // storage
  final prefs = await SharedPreferences.getInstance();
  getIt.registerLazySingleton(() => StorageService(prefs));

  // theme & locale
  getIt.registerLazySingleton(() => ThemeProvider(getIt<StorageService>()));
  getIt.registerLazySingleton(() => LocaleProvider(getIt<StorageService>()));

  // networking and authentication
  getIt.registerLazySingleton(() => DioClient());

  getIt.registerLazySingleton(() => AuthRepository(getIt<DioClient>()));

  getIt.registerLazySingleton(
    () => AuthProvider(getIt<StorageService>(), getIt<AuthRepository>()),
  );

  getIt<DioClient>().dio.interceptors.add(
    AppInterceptors(getIt<AuthProvider>()),
  );

  // repositories
  getIt.registerLazySingleton(() => DashboardRepository(getIt<DioClient>()));
  getIt.registerLazySingleton(() => ClientRepository(getIt<DioClient>()));
  getIt.registerLazySingleton(() => CaseRepository(getIt<DioClient>()));
  getIt.registerLazySingleton(() => SessionRepository(getIt<DioClient>()));
  getIt.registerLazySingleton(
    () => MessageRepository(getIt<DioClient>(), getIt<StorageService>()),
  );
  getIt.registerLazySingleton(() => DocumentRepository(getIt<DioClient>()));
  getIt.registerLazySingleton(() => ConnectionsRepository(getIt<DioClient>()));

  // providers
  //-> country
  getIt.registerLazySingleton(() => CountryProvider(getIt<AuthRepository>()));
  //-> dashboard
  getIt.registerLazySingleton(
    () => DashboardProvider(getIt<DashboardRepository>()),
  );
  //-> clients
  getIt.registerLazySingleton(() => ClientsProvider(getIt<ClientRepository>()));
  getIt.registerLazySingleton(
    () => AddClientProvider(getIt<ClientRepository>()),
  );
  getIt.registerLazySingleton(
    () => UpdateClientProvider(getIt<ClientRepository>()),
  );
  getIt.registerLazySingleton(
    () => ClientDetailProvider(getIt<ClientRepository>()),
  );
  getIt.registerLazySingleton(
    () => ClientsSearchProvider(getIt<ClientRepository>()),
  );
  //-> cases
  getIt.registerLazySingleton(() => CasesProvider(getIt<CaseRepository>()));
  getIt.registerLazySingleton(() => AddCaseProvider(getIt<CaseRepository>()));
  getIt.registerLazySingleton(
    () => CasesSearchProvider(getIt<CaseRepository>()),
  );
  getIt.registerLazySingleton(
    () => CaseDetailProvider(getIt<CaseRepository>()),
  );
  getIt.registerLazySingleton(
    () => AssignedAccountsProvider(getIt<CaseRepository>()),
  );
  //-> sessions
  getIt.registerLazySingleton(
    () => SessionsProvider(getIt<SessionRepository>()),
  );
  getIt.registerLazySingleton(
    () => AddSessionProvider(getIt<SessionRepository>()),
  );
  getIt.registerLazySingleton(
    () => SessionDetailProvider(getIt<SessionRepository>()),
  );
  // messages
  getIt.registerLazySingleton(
    () => AllMessagesProvider(getIt<MessageRepository>()),
  );
  getIt.registerLazySingleton(
    () => EditDeleteMessageProvider(getIt<MessageRepository>()),
  );
  getIt.registerLazySingleton(
    () => MessageDetailProvider(getIt<MessageRepository>()),
  );
  getIt.registerLazySingleton(
    () => SendMessageProvider(getIt<MessageRepository>()),
  );
  // documents
  getIt.registerLazySingleton(
    () => DocumentsProvider(getIt<DocumentRepository>()),
  );
  getIt.registerLazySingleton(
    () => UploadDocumentsProvider(getIt<DocumentRepository>()),
  );
  getIt.registerLazySingleton(
    () => GroupsProvider(getIt<DocumentRepository>()),
  );
  getIt.registerLazySingleton(
    () => GroupDetailsProvider(getIt<DocumentRepository>()),
  );
  // connections
  getIt.registerLazySingleton(
    () => ConnectionProvider(getIt<ConnectionsRepository>()),
  );
  getIt.registerLazySingleton(
    () => SendInvitationProvider(getIt<ConnectionsRepository>()),
  );
}
