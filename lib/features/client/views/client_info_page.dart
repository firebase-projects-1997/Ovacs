import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:new_ovacs/common/widgets/rounded_container.dart';
import 'package:provider/provider.dart';
import 'package:iconsax/iconsax.dart';

import '../../../core/constants/app_colors.dart';
import '../../../l10n/app_localizations.dart';
import '../providers/client_details_provider.dart';

class ClientDetailsPage extends StatefulWidget {
  final int clientId;

  const ClientDetailsPage({super.key, required this.clientId});

  @override
  State<ClientDetailsPage> createState() => _ClientDetailsPageState();
}

class _ClientDetailsPageState extends State<ClientDetailsPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ClientDetailProvider>().fetchClientDetail(widget.clientId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final local = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Iconsax.arrow_left),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(local.clientDetails),
        centerTitle: true,
        elevation: 0,
      ),
      body: Consumer<ClientDetailProvider>(
        builder: (context, provider, _) {
          if (provider.status == ClientDetailStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.status == ClientDetailStatus.error) {
            return Center(child: Text(provider.errorMessage ?? 'Error'));
          }

          final client = provider.client;
          if (client == null) {
            return Center(child: Text(local.clientNotFound));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                RoundedContainer(
                  child: Column(
                    children: [
                      Text(
                        client.name,
                        style: theme.textTheme.titleLarge?.copyWith(),
                      ),
                      Divider(),
                      _InfoRow(
                        icon: Iconsax.card,
                        label: local.id,
                        value: client.id.toString(),
                      ),
                      _InfoRow(
                        icon: Iconsax.profile_tick,
                        label: local.accountNumber,
                        value: client.account.toString(),
                      ),
                      _InfoRow(
                        icon: Iconsax.sms,
                        label: local.email,
                        value: client.email,
                      ),
                      _InfoRow(
                        icon: Iconsax.call,
                        label: local.phone,
                        value: client.mobile,
                      ),
                      _InfoRow(
                        icon: Iconsax.flag,
                        label: local.country,
                        value: client.country.name ?? '-',
                      ),
                      _InfoRow(
                        icon: Iconsax.calendar,
                        label: local.createdAt,
                        value: DateFormat.yMMMMd().format(
                          client.createdAt.toLocal(),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              color: AppColors.primaryBlue.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.all(10),
            child: Icon(icon, color: AppColors.primaryBlue, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.mediumGrey,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value.isNotEmpty ? value : '-',
                  style: theme.textTheme.bodyLarge?.copyWith(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
