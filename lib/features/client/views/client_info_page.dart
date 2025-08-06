import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../l10n/app_localizations.dart';
import '../../../common/widgets/rounded_container.dart';
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

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(local.clientDetails),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Consumer<ClientDetailProvider>(
        builder: (context, provider, child) {
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
            child: RoundedContainer(
              padding: const EdgeInsets.all(24),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _ClientDetailItem(
                    icon: Icons.badge,
                    label: local.id,
                    value: client.id.toString(),
                  ),
                  _ClientDetailItem(
                    icon: Icons.account_box,
                    label: local.accountNumber,
                    value: client.account.toString(),
                  ),
                  _ClientDetailItem(
                    icon: Icons.person,
                    label: local.name,
                    value: client.name,
                  ),
                  _ClientDetailItem(
                    icon: Icons.email,
                    label: local.email,
                    value: client.email,
                  ),
                  _ClientDetailItem(
                    icon: Icons.phone,
                    label: local.phone,
                    value: client.mobile,
                  ),
                  _ClientDetailItem(
                    icon: Icons.flag,
                    label: local.country,
                    value: client.country.name ?? '-',
                  ),
                  _ClientDetailItem(
                    icon: Icons.calendar_today,
                    label: local.createdAt,
                    value: DateFormat.yMMMMd().format(
                      client.createdAt.toLocal(),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ClientDetailItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _ClientDetailItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.primaryBlue, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.mediumGrey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value.isNotEmpty ? value : '-',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
