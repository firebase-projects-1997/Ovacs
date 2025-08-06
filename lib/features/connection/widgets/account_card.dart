import 'package:flutter/material.dart';
import 'package:new_ovacs/common/widgets/rounded_container.dart';
import '../../../data/models/account_model.dart';
import '../../../l10n/app_localizations.dart';

class AccountCard extends StatelessWidget {
  final AccountModel account;

  const AccountCard({super.key, required this.account});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return RoundedContainer(
      child: ListTile(
        title: Text(account.name ?? l10n.noName),
        subtitle: Text(l10n.idWithValue(account.id.toString())),
        trailing: Icon(
          account.isActive == true ? Icons.check_circle : Icons.cancel,
          color: account.isActive == true ? Colors.green : Colors.red,
        ),
      ),
    );
  }
}
