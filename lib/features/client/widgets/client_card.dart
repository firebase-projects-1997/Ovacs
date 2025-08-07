import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:new_ovacs/core/functions/show_snackbar.dart';
import 'package:new_ovacs/main.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../common/widgets/rounded_container.dart';
import '../../../data/models/client_model.dart';
import '../../../l10n/app_localizations.dart';
import '../providers/clients_provider.dart';
import '../providers/update_client_provider.dart';
import '../views/client_info_page.dart';
import '../views/update_client_page.dart';

class ClientCard extends StatelessWidget {
  const ClientCard({super.key, required this.client});

  final ClientModel client;

  @override
  Widget build(BuildContext context) {
    return Consumer<UpdateClientProvider>(
      builder: (context, updateProvider, _) {
        return RoundedContainer(
          onTap: () => navigatorKey.currentState!.push(
            MaterialPageRoute(
              builder: (context) => ClientDetailsPage(clientId: client.id),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildInfo(
                      context,
                      AppLocalizations.of(context)!.clientName,
                      client.name,
                      valueColor: Theme.of(context).primaryColor,
                    ),
                    const SizedBox(height: 10),
                    _buildInfo(
                      context,
                      "${AppLocalizations.of(context)!.email}: ",
                      client.email,
                    ),
                    const SizedBox(height: 10),
                    _buildInfo(
                      context,
                      "${AppLocalizations.of(context)!.phone}: ",
                      client.mobile,
                    ),
                    const SizedBox(height: 10),
                    _buildInfo(
                      context,
                      "${AppLocalizations.of(context)!.country}: ",
                      client.country.name ?? '',
                      valueColor: Theme.of(context).primaryColor,
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'edit') {
                    navigatorKey.currentState!.push(
                      MaterialPageRoute(
                        builder: (context) => EditClientPage(client: client),
                      ),
                    );
                  } else if (value == 'delete') {
                    _showDeleteConfirmationDialog(context, client);
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem<String>(
                    value: 'edit',
                    child: Text(AppLocalizations.of(context)!.edit),
                  ),
                  PopupMenuItem<String>(
                    value: 'delete',
                    child: Text(AppLocalizations.of(context)!.delete),
                  ),
                ],
                icon: Icon(Iconsax.more_circle),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInfo(
    BuildContext context,
    String label,
    String value, {
    Color? valueColor,
  }) {
    return Text.rich(
      TextSpan(
        text: label,
        style: Theme.of(
          context,
        ).textTheme.bodyMedium!.copyWith(color: AppColors.mediumGrey),
        children: [
          TextSpan(
            text: value,
            style: Theme.of(
              context,
            ).textTheme.bodySmall!.copyWith(color: valueColor),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmationDialog(BuildContext context, ClientModel client) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(
            AppLocalizations.of(context)!.delete,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium!.copyWith(color: AppColors.red),
          ),
          content: Text(
            AppLocalizations.of(context)!.areYouSureYouWantToDeleteThisClient,
            style: Theme.of(
              context,
            ).textTheme.bodySmall!.copyWith(color: AppColors.charcoalGrey),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(AppLocalizations.of(context)!.cancel),
            ),
            Consumer<UpdateClientProvider>(
              builder: (context, provider, _) {
                final isLoading = provider.status == UpdateClientStatus.loading;
                return TextButton(
                  onPressed: isLoading
                      ? null
                      : () async {
                          // Store context references before async operation
                          final navigator = Navigator.of(dialogContext);
                          final clientsProvider = context
                              .read<ClientsProvider>();
                          final localizations = AppLocalizations.of(context)!;

                          // Use optimistic delete - UI updates immediately
                          final success = await clientsProvider
                              .deleteClientOptimistic(client.id);

                          // Close the dialog regardless of success/failure
                          navigator.pop();

                          if (success) {
                            if (context.mounted) {
                              showAppSnackBar(
                                context,
                                localizations
                                    .clientAddedSuccessfully, // Reusing existing localization
                                type: SnackBarType.success,
                              );
                            }
                          } else {
                            // Error message is already set in the provider
                            if (context.mounted) {
                              showAppSnackBar(
                                context,
                                clientsProvider.errorMessage ??
                                    'Failed to delete client',
                              );
                            }
                          }
                        },
                  child: isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(AppLocalizations.of(context)!.delete),
                );
              },
            ),
          ],
        );
      },
    );
  }
}
