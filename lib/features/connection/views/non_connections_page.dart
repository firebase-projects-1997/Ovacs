import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import '../../../generated/l10n.dart';

import '../../../common/widgets/rounded_container.dart';
import '../providers/non_connections_provider.dart';

class NonConnectionsPage extends StatefulWidget {
  const NonConnectionsPage({super.key});

  @override
  State<NonConnectionsPage> createState() => _NonConnectionsPageState();
}

class _NonConnectionsPageState extends State<NonConnectionsPage> {
  @override
  void initState() {
    super.initState();
    final provider = Provider.of<NonConnectionsProvider>(
      context,
      listen: false,
    );
    Future.microtask(() {
      provider.fetchSuggestions();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = S.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.connectionSuggestions)),
      body: Consumer<NonConnectionsProvider>(
        builder: (context, value, child) => value.isLoading
            ? const Center(child: CircularProgressIndicator())
            : value.failure != null
            ? Center(child: Text(value.failure!.message))
            : ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 10),
                itemCount: value.users.length,
                itemBuilder: (context, index) {
                  final user = value.users[index];
                  return RoundedContainer(
                    child: ListTile(
                      key: ValueKey(user.id),
                      title: Text(user.name ?? l10n.noName),
                      subtitle: Text(l10n.idWithValue(user.id.toString())),
                      trailing: value.loadingIds.contains(user.id)
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : IconButton(
                              icon: const Icon(Iconsax.add_circle),
                              onPressed: () async {
                                final isSuccess = await value.sendRequest(
                                  index,
                                );
                                if (!mounted) return;

                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      isSuccess
                                          ? l10n.connectionRequestSentSuccess
                                          : l10n.connectionRequestSentFailure(
                                              value
                                                      .sendRequestfailure
                                                      ?.message ??
                                                  l10n.somethingWentWrong,
                                            ),
                                    ),
                                    backgroundColor: isSuccess
                                        ? Colors.green
                                        : Colors.red,
                                  ),
                                );

                                if (isSuccess) {
                                  context
                                      .read<NonConnectionsProvider>()
                                      .fetchSuggestions();
                                }
                              },
                            ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
