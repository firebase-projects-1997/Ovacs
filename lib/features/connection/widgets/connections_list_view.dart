import 'package:flutter/material.dart';
import '../../../data/models/account_model.dart';
import 'account_card.dart';

class ConnectionsListView extends StatelessWidget {
  final List<AccountModel> connections;

  const ConnectionsListView({super.key, required this.connections});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: EdgeInsets.all(20),
      separatorBuilder: (context, index) => SizedBox(height: 10),
      itemCount: connections.length,
      itemBuilder: (context, index) {
        return AccountCard(account: connections[index]);
      },
    );
  }
}
