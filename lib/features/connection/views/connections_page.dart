import 'package:flutter/material.dart';
import 'package:new_ovacs/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import '../../../core/di/injection.dart';
import '../../../data/repositories/connection_repository.dart';
import '../providers/connection_provider.dart';
import '../providers/send_invitation_provider.dart';
import '../widgets/connections_list_view.dart';
import 'send_invitation_page.dart';

class ConnectionsPage extends StatefulWidget {
  const ConnectionsPage({super.key});

  @override
  State<ConnectionsPage> createState() => _ConnectionsPageState();
}

class _ConnectionsPageState extends State<ConnectionsPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<ConnectionProvider>().fetchFollowing();
      context.read<ConnectionProvider>().fetchFollowers();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Consumer<ConnectionProvider>(
      builder: (context, provider, child) {
        return Scaffold(
          appBar: AppBar(
            title: Text(l10n.connections),
            actions: [
              IconButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => ChangeNotifierProvider(
                        create: (context) => SendInvitationProvider(
                          getIt<ConnectionsRepository>(),
                        ),
                        child: const SendInvitationPage(),
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.share_outlined),
                tooltip: l10n.sendInvitations,
              ),
            ],
          ),
          body: provider.isLoadingFollowing
              ? const Center(child: CircularProgressIndicator())
              : provider.followingFailure != null
              ? Center(child: Text(provider.followingFailure!.message))
              : provider.following.isEmpty
              ? _buildEmptyState(context)
              : ConnectionsListView(connections: provider.following),
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(height: MediaQuery.of(context).size.height * 0.2),
          Text(
            l10n.nothingToDisplayHere,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 8),
          Text(
            l10n.peopleMustFollowYouToSeeThemHere,
            style: Theme.of(context).textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
