import 'package:flutter/material.dart';
import 'package:new_ovacs/core/constants/app_sizes.dart';
import '../../../data/models/account_model.dart';
import 'account_card.dart';

class ConnectionsListView extends StatelessWidget {
  final List<AccountModel> connections;

  const ConnectionsListView({super.key, required this.connections});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: AppSizes.noAppBarPadding(context),
      separatorBuilder: (context, index) => SizedBox(height: 10),
      itemCount: connections.length,
      itemBuilder: (context, index) {
        return AccountCard(account: connections[index]);
      },
    );
  }
}
