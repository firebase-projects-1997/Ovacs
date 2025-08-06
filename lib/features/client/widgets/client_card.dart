import 'package:flutter/material.dart';
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
                      valueColor: AppColors.primaryBlue,
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
                      valueColor: AppColors.primaryBlue,
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
                icon: const Icon(Icons.more_vert),
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
                          // Call the delete function
                          await provider.deleteClient(client.id);

                          // After the deletion is complete, check the status
                          if (provider.status == UpdateClientStatus.success) {
                            // Close the dialog and refresh the list
                            Navigator.of(dialogContext).pop();
                            context.read<ClientsProvider>().fetchClients();
                            showAppSnackBar(
                              context,
                              AppLocalizations.of(
                                context,
                              )!.clientAddedSuccessfully,
                              type: SnackBarType.success,
                            );
                          } else if (provider.status ==
                              UpdateClientStatus.error) {
                            // If there's an error, just show the snackbar
                            showAppSnackBar(context, provider.errorMessage);
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
