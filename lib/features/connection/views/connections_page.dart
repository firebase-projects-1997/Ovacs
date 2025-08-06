import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:new_ovacs/features/connection/views/non_connections_page.dart';
import 'package:new_ovacs/l10n/app_localizations.dart';
import 'package:new_ovacs/main.dart';
import 'package:provider/provider.dart';
import '../providers/connection_provider.dart';
import '../widgets/connections_list_view.dart';
import 'connection_requests_page.dart';

class ConnectionsPage extends StatefulWidget {
  const ConnectionsPage({super.key});

  @override
  State<ConnectionsPage> createState() => _ConnectionsPageState();
}

class _ConnectionsPageState extends State<ConnectionsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<ConnectionProvider>().fetchConnections();
    });

    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Consumer<ConnectionProvider>(
      builder: (context, provider, child) {
        return Scaffold(
          appBar: AppBar(
            title: Text(AppLocalizations.of(context)!.connections),
            bottom: TabBar(
              controller: _tabController,
              tabs: [
                Tab(text: l10n.following(provider.totalFollowing.toString())),
                Tab(text: l10n.followers(provider.totalFollowers.toString())),
              ],
            ),
            actions: [
              IconButton(
                onPressed: () {
                  navigatorKey.currentState!.push(
                    MaterialPageRoute(
                      builder: (context) => ConnectionRequestsPage(),
                    ),
                  );
                },
                icon: Icon(Iconsax.people),
              ),
            ],
          ),
          body: provider.isLoading
              ? const Center(child: CircularProgressIndicator())
              : provider.failure != null
              ? Center(child: Text(provider.failure!.message))
              : TabBarView(
                  controller: _tabController,
                  children: [
                    ConnectionsListView(connections: provider.following),
                    ConnectionsListView(connections: provider.followers),
                  ],
                ),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              navigatorKey.currentState!.push(
                MaterialPageRoute(builder: (context) => NonConnectionsPage()),
              );
            },
            child: Icon(Iconsax.add),
          ),
        );
      },
    );
  }
}
