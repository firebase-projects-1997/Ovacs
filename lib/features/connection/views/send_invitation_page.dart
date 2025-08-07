import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:new_ovacs/common/widgets/labeled_text_field.dart';
import 'package:new_ovacs/common/widgets/rounded_container.dart';
import 'package:provider/provider.dart';

import '../../../core/functions/show_snackbar.dart';
import '../../../data/models/invitation_model.dart';
import '../../../l10n/app_localizations.dart';
import '../providers/send_invitation_provider.dart';

class SendInvitationPage extends StatefulWidget {
  const SendInvitationPage({super.key});

  @override
  State<SendInvitationPage> createState() => _SendInvitationPageState();
}

class _SendInvitationPageState extends State<SendInvitationPage> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();

  // For each invitation, two controllers (email and name)
  final List<TextEditingController> _emailControllers = [];
  final List<TextEditingController> _nameControllers = [];

  @override
  void initState() {
    super.initState();
    final provider = context.read<SendInvitationProvider>();
    for (var invitation in provider.invitations) {
      _emailControllers.add(TextEditingController(text: invitation.email));
      _nameControllers.add(TextEditingController(text: invitation.name));
    }
    _attachListeners();
  }

  void _attachListeners() {
    for (final controller in _emailControllers) {
      controller.removeListener(_onTextChanged);
      controller.addListener(_onTextChanged);
    }
    for (final controller in _nameControllers) {
      controller.removeListener(_onTextChanged);
      controller.addListener(_onTextChanged);
    }
  }

  void _onTextChanged() {
    setState(() {});
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    for (var c in _emailControllers) {
      c.dispose();
    }
    for (var c in _nameControllers) {
      c.dispose();
    }
    super.dispose();
  }

  void _addInvitationControllers() {
    _emailControllers.add(TextEditingController());
    _nameControllers.add(TextEditingController());
  }

  void _removeInvitationControllers(int index) {
    _emailControllers[index].dispose();
    _nameControllers[index].dispose();
    _emailControllers.removeAt(index);
    _nameControllers.removeAt(index);
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(localizations.sendInvitations)),
      body: Consumer<SendInvitationProvider>(
        builder: (context, provider, _) {
          while (_emailControllers.length < provider.invitations.length) {
            _addInvitationControllers();
          }
          while (_emailControllers.length > provider.invitations.length) {
            _removeInvitationControllers(_emailControllers.length - 1);
          }

          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      RoundedContainer(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Iconsax.info_circle, size: 20),
                                const SizedBox(width: 5),
                                Text(
                                  localizations.instructions,
                                  style: Theme.of(context).textTheme.titleSmall,
                                ),
                              ],
                            ),
                            const SizedBox(height: 5),
                            Text(
                              localizations.invitationInstructions,
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 10),

                      // Invitation entries
                      ...provider.invitations.asMap().entries.map(
                        (entry) =>
                            _buildInvitationEntry(context, entry.key, provider),
                      ),

                      const SizedBox(height: 5),

                      // Add more button
                      Center(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            provider.addInvitationEntry();
                            _addInvitationControllers();

                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              _scrollController.animateTo(
                                _scrollController.position.maxScrollExtent,
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeOut,
                              );
                            });
                          },
                          icon: const Icon(Iconsax.add),
                          label: Text(localizations.addMore),
                        ),
                      ),

                      const SizedBox(height: 15),

                      // Custom message
                      Text(
                        localizations.customMessageOptional,
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      const SizedBox(height: 5),
                      LabeledTextField(
                        controller: _messageController,
                        maxLines: 3,
                        hint: localizations.addPersonalMessage,
                        label: '',
                      ),

                      const SizedBox(height: 15),

                      Row(
                        children: [
                          Expanded(
                            child: TextButton(
                              onPressed: () {
                                provider.clearAll();
                                for (var c in _emailControllers) {
                                  c.dispose();
                                }
                                for (var c in _nameControllers) {
                                  c.dispose();
                                }
                                _emailControllers.clear();
                                _nameControllers.clear();

                                _messageController.clear();

                                _addInvitationControllers();
                              },
                              child: Text(localizations.clearAll),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed:
                                  !provider.isLoading &&
                                      _hasValidInputs(provider)
                                  ? () => _sendInvitations(context, provider)
                                  : null,
                              icon: provider.isLoading
                                  ? const SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Icon(Iconsax.send_1),
                              label: Text(localizations.send),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  bool _hasValidInputs(SendInvitationProvider provider) {
    for (int i = 0; i < _emailControllers.length; i++) {
      final email = _emailControllers[i].text.trim();
      final name = _nameControllers[i].text.trim();

      if (email.isEmpty || name.isEmpty) return false;
    }
    return true;
  }

  Widget _buildInvitationEntry(
    BuildContext context,
    int index,
    SendInvitationProvider provider,
  ) {
    final localizations = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '${localizations.invitation} ${index + 1}',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              ),
              if (provider.invitations.length > 1)
                IconButton(
                  onPressed: () {
                    provider.removeInvitationEntry(index);
                    _removeInvitationControllers(index);
                  },
                  icon: const Icon(Iconsax.trash, color: Colors.red),
                  tooltip: localizations.remove,
                ),
            ],
          ),
          const SizedBox(height: 5),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: Directionality(
                  textDirection: TextDirection.ltr,
                  child: LabeledTextField(
                    keyboardType: TextInputType.emailAddress,
                    controller: _emailControllers[index],
                    label: localizations.email,
                    hint: 'example@email.com',
                    // validation inside widget
                  ),
                ),
              ),
              const SizedBox(width: 5),
              Expanded(
                child: LabeledTextField(
                  controller: _nameControllers[index],
                  label: localizations.name,
                  hint: localizations.fullName,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _sendInvitations(
    BuildContext context,
    SendInvitationProvider provider,
  ) async {
    // Update provider invitations from controllers
    final updatedInvitations = List.generate(_emailControllers.length, (i) {
      return InvitationEntry(
        email: _emailControllers[i].text.trim(),
        name: _nameControllers[i].text.trim(),
        isValid: true, // Let provider or backend do validation if needed
      );
    });

    provider.items = updatedInvitations;
    provider.updateCustomMessage(_messageController.text);

    final localizations = AppLocalizations.of(context)!;

    final success = await provider.sendInvitations();

    if (!mounted) return;

    if (success) {
      final response = provider.lastResponse!;
      showAppSnackBar(
        context,
        '${response.successCount} invitations sent successfully!',
        type: SnackBarType.success,
      );

      if (response.failureCount > 0) {
        showAppSnackBar(
          context,
          '${response.failureCount} invitations failed to send',
          type: SnackBarType.warning,
        );
      }

      Navigator.of(context).pop();
    } else {
      showAppSnackBar(
        context,
        provider.errorMessage ?? localizations.failedToSendInvitations,
        type: SnackBarType.error,
      );
    }
  }
}
