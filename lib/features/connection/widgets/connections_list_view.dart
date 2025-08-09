import 'package:flutter/material.dart';
import '../../../data/models/space_account_model.dart';
import 'account_card.dart';

class ConnectionsListView extends StatelessWidget {
  final List<SpaceAccountModel> connections;

  const ConnectionsListView({super.key, required this.connections});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      separatorBuilder: (context, index) => SizedBox(height: 10),
      itemCount: connections.length,
      itemBuilder: (context, index) {
        return AccountCard(account: connections[index]);
      },
    );
  }
}
