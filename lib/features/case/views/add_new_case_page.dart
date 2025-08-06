import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:new_ovacs/common/widgets/labeled_text_field.dart';
import 'package:new_ovacs/core/functions/show_snackbar.dart';
import 'package:new_ovacs/features/case/provider/cases_provider.dart';
import 'package:new_ovacs/features/client/views/add_client_page.dart';
import 'package:new_ovacs/main.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../common/widgets/rounded_container.dart';
import '../../../data/models/client_model.dart';
import '../../../l10n/app_localizations.dart';
import '../../client/providers/clients_provider.dart';
import '../provider/add_case_provider.dart';

class AddNewCasePage extends StatefulWidget {
  const AddNewCasePage({super.key});

  @override
  State<AddNewCasePage> createState() => _AddNewCasePageState();
}

class _AddNewCasePageState extends State<AddNewCasePage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _caseNameController;
  late final TextEditingController _caseDescriptionController;
  late final TextEditingController _dateController;
  ClientModel? _selectedClient;

  @override
  void initState() {
    super.initState();
    _caseNameController = TextEditingController();
    _caseDescriptionController = TextEditingController();
    _dateController = TextEditingController();
    Future.microtask(() => context.read<ClientsProvider>().fetchClients());
  }

  @override
  void dispose() {
    _caseNameController.dispose();
    _caseDescriptionController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    FocusScope.of(context).requestFocus(FocusNode());

    final pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).primaryColor,
              onPrimary: AppColors.pureWhite,
              onSurface: AppColors.black,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).primaryColor,
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null) {
      _dateController.text = DateFormat('yyyy-MM-dd').format(pickedDate);
    }
  }

  void _addCase(BuildContext context) async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedClient == null) {
      showAppSnackBar(
        context,
        AppLocalizations.of(context)!.pleaseSelectAClient,
        type: SnackBarType.warning,
      );
      return;
    }

    final provider = context.read<AddCaseProvider>();
    final success = await provider.addCase(
      clientId: _selectedClient!.id,
      title: _caseNameController.text.trim(),
      description: _caseDescriptionController.text.trim(),
      date: _dateController.text.trim(),
    );

    if (success) {
      context.read<CasesProvider>().fetchCases();
      Navigator.of(context).pop();
      showAppSnackBar(
        context,
        AppLocalizations.of(context)!.caseCreatedSuccessfully,
        type: SnackBarType.success,
      );
    } else {
      showAppSnackBar(context, provider.errorMessage);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          AppLocalizations.of(context)!.addNewCase,
          style: Theme.of(context).textTheme.titleLarge,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: RoundedContainer(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
              child: Container(
                color: Colors.transparent,
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      LabeledTextField(
                        controller: _caseNameController,
                        hint: AppLocalizations.of(context)!.enterCaseName,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return AppLocalizations.of(
                              context,
                            )!.caseNameIsRequired;
                          }
                          return null;
                        },
                        label: AppLocalizations.of(context)!.caseName,
                      ),
                      const SizedBox(height: 20),
                      _buildClientSelectionField(),
                      const SizedBox(height: 20),
                      LabeledTextField(
                        controller: _caseDescriptionController,
                        label: AppLocalizations.of(context)!.description,
                        maxLines: 5,
                        hint: AppLocalizations.of(
                          context,
                        )!.enterCaseDescription,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return AppLocalizations.of(
                              context,
                            )!.descriptionIsRequired;
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      GestureDetector(
                        onTap: () => _selectDate(context),

                        child: LabeledTextField(
                          controller: _dateController,
                          enabled: false,
                          hint: AppLocalizations.of(context)!.dateFormatHint,
                          label: AppLocalizations.of(context)!.date,
                        ),
                      ),
                      const SizedBox(height: 20),
                      _buildAddButton(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildClientSelectionField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          AppLocalizations.of(context)!.addClient,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: Consumer<ClientsProvider>(
                builder: (context, provider, _) {
                  if (provider.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (provider.errorMessage != null) {
                    return Text(
                      'Error loading clients: ${provider.errorMessage}',
                    );
                  } else {
                    return DropdownButtonFormField<ClientModel>(
                      isExpanded: true,
                      value: _selectedClient,

                      decoration: const InputDecoration(
                        hintText: 'Choose your client',
                        border: OutlineInputBorder(borderSide: BorderSide.none),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                      ),
                      items: provider.clients.map((client) {
                        return DropdownMenuItem<ClientModel>(
                          value: client,
                          child: Text(client.name),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedClient = value;
                        });
                      },
                      validator: (value) {
                        if (value == null) {
                          return AppLocalizations.of(
                            context,
                          )!.pleaseSelectAClient;
                        }
                        return null;
                      },
                    );
                  }
                },
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              onPressed: () {
                navigatorKey.currentState!.push(
                  MaterialPageRoute(builder: (context) => AddNewClientPage()),
                );
              },
              icon: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  border: Border.all(color: Theme.of(context).primaryColor),
                ),
                padding: const EdgeInsets.all(2),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    color: Theme.of(context).primaryColor,
                  ),
                  child: Icon(Iconsax.add, color: AppColors.mediumGrey),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAddButton() {
    return Consumer<AddCaseProvider>(
      builder: (context, provider, _) {
        final isLoading = provider.isLoading;

        return GestureDetector(
          onTap: isLoading ? null : () => _addCase(context),
          child: Opacity(
            opacity: isLoading ? 0.6 : 1,
            child: Container(
              width: 113,
              height: 44,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [Theme.of(context).primaryColor, AppColors.tealGreen],
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                    : Text(
                        'Add',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.offWhite,
                        ),
                      ),
              ),
            ),
          ),
        );
      },
    );
  }
}
