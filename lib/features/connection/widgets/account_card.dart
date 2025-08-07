import 'package:flutter/material.dart';
import 'package:new_ovacs/common/widgets/rounded_container.dart';
import '../../../data/models/space_account_model.dart';
import '../../../l10n/app_localizations.dart';

class AccountCard extends StatelessWidget {
  final SpaceAccountModel account;

  const AccountCard({super.key, required this.account});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return RoundedContainer(
      child: ListTile(
        title: Text(account.name),
        subtitle: Text(l10n.idWithValue(account.id.toString())),
      ),
    );
  }
}
